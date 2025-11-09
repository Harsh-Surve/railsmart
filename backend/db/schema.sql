-- PostgreSQL schema for RailSmart

CREATE TABLE IF NOT EXISTS trains (
  train_id SERIAL PRIMARY KEY,
  train_name TEXT NOT NULL,
  source TEXT NOT NULL,
  destination TEXT NOT NULL,
  departure TIME NOT NULL,
  arrival TIME NOT NULL
);

CREATE TABLE IF NOT EXISTS seats (
  seat_id SERIAL PRIMARY KEY,
  train_id INT NOT NULL REFERENCES trains(train_id) ON DELETE CASCADE,
  seat_no TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'available',
  UNIQUE(train_id, seat_no)
);

CREATE TABLE IF NOT EXISTS tickets (
  ticket_id SERIAL PRIMARY KEY,
  user_id INT,
  train_id INT REFERENCES trains(train_id),
  seat_no TEXT NOT NULL,
  price NUMERIC(10,2) DEFAULT 0,
  status TEXT NOT NULL,
  pnr TEXT NOT NULL UNIQUE,
  booking_date TIMESTAMP DEFAULT NOW()
);

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_trains_source ON trains (LOWER(source));
CREATE INDEX IF NOT EXISTS idx_trains_destination ON trains (LOWER(destination));
CREATE INDEX IF NOT EXISTS idx_seats_train_seat ON seats (train_id, seat_no);
