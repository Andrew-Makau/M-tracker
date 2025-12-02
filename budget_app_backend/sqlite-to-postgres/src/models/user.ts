import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class User {
  id: number;
  name: string;
  email: string;
  password: string;

  constructor(id: number, name: string, email: string, password: string) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.password = password;
  }

  static async createUser(data: { name: string; email: string; password: string }) {
    return await prisma.user.create({
      data,
    });
  }

  static async getUser(id: number) {
    return await prisma.user.findUnique({
      where: { id },
    });
  }

  static async updateUser(id: number, data: Partial<{ name: string; email: string; password: string }>) {
    return await prisma.user.update({
      where: { id },
      data,
    });
  }

  static async deleteUser(id: number) {
    return await prisma.user.delete({
      where: { id },
    });
  }
}