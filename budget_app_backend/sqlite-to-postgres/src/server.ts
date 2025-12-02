import express from 'express';
import { connectToDatabase } from './db/client';

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

connectToDatabase()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server is running on http://localhost:${PORT}`);
    });
  })
  .catch((error) => {
    console.error('Database connection failed:', error);
    process.exit(1);
  });