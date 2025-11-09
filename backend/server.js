const express = require('express');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => res.send('RailSmart API running ✅'));

app.get('/api/trains', (req, res) => {
  const trains = [
    { id: 101, name: 'Mumbai–Pune Intercity', source: 'Mumbai', destination: 'Pune', departure: '07:30', arrival: '10:00' },
    { id: 102, name: 'Mumbai Express', source: 'Mumbai', destination: 'Delhi', departure: '19:00', arrival: '09:00' }
  ];
  res.json(trains);
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));;

