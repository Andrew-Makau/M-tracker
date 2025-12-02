import { Client } from 'pg';
import { User } from '../models/user';

export class UserService {
    private client: Client;

    constructor(client: Client) {
        this.client = client;
    }

    async createUser(userData: User): Promise<User> {
        const query = 'INSERT INTO users(name, email) VALUES($1, $2) RETURNING *';
        const values = [userData.name, userData.email];
        const res = await this.client.query(query, values);
        return res.rows[0];
    }

    async getUser(id: number): Promise<User | null> {
        const query = 'SELECT * FROM users WHERE id = $1';
        const values = [id];
        const res = await this.client.query(query, values);
        return res.rows.length ? res.rows[0] : null;
    }

    async updateUser(id: number, userData: Partial<User>): Promise<User | null> {
        const query = 'UPDATE users SET name = $1, email = $2 WHERE id = $3 RETURNING *';
        const values = [userData.name, userData.email, id];
        const res = await this.client.query(query, values);
        return res.rows.length ? res.rows[0] : null;
    }
}