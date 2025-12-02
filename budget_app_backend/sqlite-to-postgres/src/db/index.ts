import { Client } from 'pg';
import { config } from 'dotenv';

config();

const client = new Client({
  connectionString: process.env.DATABASE_URL,
});

client.connect()
  .then(() => console.log('Connected to PostgreSQL database'))
  .catch(err => console.error('Connection error', err.stack));

export const query = (text: string, params?: any[]) => {
  return client.query(text, params);
};

export const closeConnection = () => {
  return client.end();
};