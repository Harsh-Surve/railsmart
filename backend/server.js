require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./db');
const app = express();
app.use(cors());
app.use(express.json());

// Simple request logger for debugging
app.use((req, res, next) => {
  console.log('REQ', req.method, req.originalUrl);
  next();
});

app.get('/', (req, res) => res.send('RailSmart API running ✅'));

// Inspect registered routes at runtime
app.get('/_routes', (req, res) => {
  const routes = [];
  const mainStack = app._router && app._router.stack ? app._router.stack : [];
  mainStack.forEach(mw => {
    try {
      if (mw.route) {
        const methods = Object.keys(mw.route.methods).join(',').toUpperCase();
        routes.push({ method: methods, path: mw.route.path });
      } else if (mw.name === 'router' && mw.handle && mw.handle.stack) {
        mw.handle.stack.forEach(h => {
          if (h.route) {
            const methods = Object.keys(h.route.methods).join(',').toUpperCase();
            routes.push({ method: methods, path: h.route.path });
          }
        });
      }
    } catch (_) {}
  });
  res.json(routes);
});

/**
 * fetchTrainsFromDb
 * Reads trains from PostgreSQL; applies optional from/to filters in SQL.
 */
async function fetchTrainsFromDb({ from, to }) {
  const conditions = [];
  const params = [];
  if (from) {
    params.push(`%${from.toLowerCase()}%`);
    conditions.push(`LOWER(source) LIKE $${params.length}`);
  }
  if (to) {
    params.push(`%${to.toLowerCase()}%`);
    conditions.push(`LOWER(destination) LIKE $${params.length}`);
  }
  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const sql = `
    SELECT train_id AS id,
           train_name AS name,
           source,
           destination,
           departure::text AS departure,
           arrival::text AS arrival
    FROM trains
    ${where}
    ORDER BY departure ASC
    LIMIT 200
  `;
  const { rows } = await db.query(sql, params);
  return rows;
}

/**
 * bookTicketTransaction
 * Performs a seat lock and ticket insert inside a DB transaction.
 * Returns inserted ticket row or throws on failure.
 */
async function bookTicketTransaction({ trainId, seatNo, travelClass, passengerName, userName }) {
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');

    // Lock seat row
    const seatRes = await client.query(
      'SELECT * FROM seats WHERE train_id=$1 AND seat_no=$2 FOR UPDATE',
      [trainId, seatNo]
    );
    if (!seatRes.rows.length) {
      throw new Error('Seat not found');
    }
    const seat = seatRes.rows[0];
    if (seat.status !== 'available') {
      throw new Error('Seat not available');
    }

    // Mark seat booked
    await client.query(
      'UPDATE seats SET status=$1 WHERE seat_id=$2',
      ['booked', seat.seat_id]
    );

    // Simple PNR generator: RS-YYYYMMDD-XXXX
    const datePart = new Date().toISOString().substring(0,10).replace(/-/g,'');
    const randPart = Math.random().toString(16).substring(2,6).toUpperCase();
    const pnr = `RS-${datePart}-${randPart}`;

    // Insert ticket (assumes tickets table exists)
    const ticketRes = await client.query(
      `INSERT INTO tickets (user_id, train_id, seat_no, price, status, pnr)
       VALUES ($1,$2,$3,$4,$5,$6)
       RETURNING ticket_id, user_id, train_id, seat_no, price, status, pnr, booking_date`,
      [
        1,            // placeholder user_id (replace with real auth user id)
        trainId,
        seatNo,
        0,            // mock price (replace when fares implemented)
        'CONFIRMED',
        pnr
      ]
    );

    await client.query('COMMIT');
    const ticket = ticketRes.rows[0];
    return {
      ...ticket,
      passenger_name: passengerName,
      user_name: userName,
      class: travelClass
    };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

// Replace existing /api/trains route with DB + fallback
app.get('/api/trains', async (req, res) => {
  const { from, to } = req.query;

  // mock fallback
  const mock = [
    { id: 101, name: 'Mumbai–Pune Intercity', source: 'Mumbai', destination: 'Pune', departure: '07:30', arrival: '10:00' },
    { id: 102, name: 'Mumbai Express', source: 'Mumbai', destination: 'Delhi', departure: '19:00', arrival: '09:00' }
  ];

  try {
    const data = await fetchTrainsFromDb({ from, to });
    if (!data.length) {
      // if DB empty, return filtered mock
      const filtered = mock.filter(t => {
        const okFrom = from ? t.source.toLowerCase().includes(from.toLowerCase()) : true;
        const okTo = to ? t.destination.toLowerCase().includes(to.toLowerCase()) : true;
        return okFrom && okTo;
      });
      return res.json(filtered);
    }
    return res.json(data);
  } catch (err) {
    console.error('DB error /api/trains:', err.message);
    // graceful fallback
    const filtered = mock.filter(t => {
      const okFrom = from ? t.source.toLowerCase().includes(from.toLowerCase()) : true;
      const okTo = to ? t.destination.toLowerCase().includes(to.toLowerCase()) : true;
      return okFrom && okTo;
    });
    res.status(500).json({ error: 'DB error', fallback: filtered });
  }
});

app.post('/api/book', async (req, res) => {
  const { train_id, seat_no, class: travelClass, passenger_name, user_name } = req.body || {};

  if (!train_id || !seat_no || !travelClass || !passenger_name) {
    return res.status(400).json({ error: 'Missing required fields: train_id, seat_no, class, passenger_name' });
  }

  // Quick existence check for tables (graceful fallback if schema not ready)
  try {
    const tableCheck = await db.query(
      "SELECT to_regclass('public.seats') AS seats_exists, to_regclass('public.tickets') AS tickets_exists"
    );
    const { seats_exists, tickets_exists } = tableCheck.rows[0];
    if (!seats_exists || !tickets_exists) {
      return res.status(501).json({ error: 'Booking not implemented (DB tables missing)' });
    }
  } catch (e) {
    return res.status(500).json({ error: 'DB introspection failed' });
  }

  try {
    const ticket = await bookTicketTransaction({
      trainId: train_id,
      seatNo: seat_no,
      travelClass,
      passengerName: passenger_name,
      userName: user_name || 'Guest'
    });
    res.status(201).json(ticket);
  } catch (err) {
    res.status(409).json({ error: err.message });
  }
});

console.log('Registering POST /api/book');

// One-time init endpoint to seed a train + seats AFTER schema exists.
// Use: POST http://localhost:5000/api/init  (then remove or protect)
app.post('/api/init', async (req, res) => {
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');

    const trainRes = await client.query(
      `INSERT INTO trains (train_name, source, destination, departure, arrival)
       VALUES ('Mumbai–Pune Intercity','Mumbai','Pune','07:30','10:00')
       RETURNING train_id`
    );
    const trainId = trainRes.rows[0].train_id;

    const seatInserts = [];
    for (let i = 1; i <= 10; i++) {
      seatInserts.push(client.query(
        'INSERT INTO seats (train_id, seat_no) VALUES ($1,$2) ON CONFLICT DO NOTHING',
        [trainId, `A${i}`]
      ));
    }
    await Promise.all(seatInserts);
    await client.query('COMMIT');
    res.json({ status: 'ok', train_id: trainId, seats_created: 10 });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error initializing database:', err.message);
    res.status(500).json({ error: 'Init failed', detail: err.message });
  } finally {
    client.release();
  }
});

// JSON 404 fallback AFTER all routes so it doesn't swallow valid ones
app.use((req, res) => {
  res.status(404).json({ error: 'Not Found', method: req.method, path: req.originalUrl });
});

// Export app for testing; only listen when run directly
const PORT = process.env.PORT || 5000;
if (require.main === module) {
  const listRoutes = () => {
    const out = [];
    (app._router?.stack || []).forEach(layer => {
      if (layer.route) {
        const methods = Object.keys(layer.route.methods).map(m => m.toUpperCase()).join(',');
        out.push(`${methods} ${layer.route.path}`);
      }
    });
    return out;
  };
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log('Available routes:\n- ' + listRoutes().join('\n- '));
  });
}

module.exports = app;

