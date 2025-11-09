const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL || 'postgres://rails:rails@localhost:5432/railsmart'
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool
};