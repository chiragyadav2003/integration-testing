import express from 'express';
import { z } from 'zod';
import { prisma } from './libs/db';
import { RequestTypeEnum } from '@prisma/client';

export const app = express();

app.use(express.json());

const inputSchema = z.object({
  a: z.number(),
  b: z.number(),
});

app.post('/sum', async (req, res) => {
  const parsedBody = inputSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(422).json({ message: 'Invalid input' });
    return;
  }

  const { a, b } = parsedBody.data;

  if (a > 1000000 || b > 1000000) {
    res.status(422).json({
      message: "Sorry we don't support big numbers",
    });
    return;
  }

  const result = a + b;

  const dbRes = await prisma.request.create({
    data: {
      a,
      b,
      answer: result,
      type: RequestTypeEnum.ADD,
    },
  });

  res.status(200).json({ answer: result, id: dbRes.id });
});

app.post('/multiply', async (req, res) => {
  const parsedBody = inputSchema.safeParse(req.body);

  if (!parsedBody.success) {
    res.status(422).json({ message: 'Invalid input' });
    return;
  }

  const { a, b } = parsedBody.data;

  if (a > 1000000 || b > 1000000) {
    res.status(422).json({
      message: "Sorry we don't support big numbers",
    });
    return;
  }

  const result = a * b;

  const dbRes = await prisma.request.create({
    data: {
      a,
      b,
      answer: result,
      type: RequestTypeEnum.MUL,
    },
  });

  res.status(200).json({ answer: result, id: dbRes.id });
});
