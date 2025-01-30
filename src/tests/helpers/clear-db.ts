import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const clearDb = async () => {
  await prisma.$transaction([prisma.request.deleteMany()]);
};
