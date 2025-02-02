import { beforeAll, describe, expect, it } from 'vitest';
import { app } from '../index';
import request from 'supertest';
import { clearDb } from './helpers/clear-db';

describe('POST /sum', () => {
  beforeAll(async () => {
    console.log('Clearing database ...');
    await clearDb();
  });

  it('should sum two numbers correctly', async () => {
    const { status, body } = await request(app)
      .post('/sum')
      .send({ a: 1, b: 2 });
    expect(status).toBe(200);
    expect(body).toEqual({ answer: 10, id: expect.any(Number) });
  });

  it('should return 422 for invalid input (non-numbers)', async () => {
    const { status, body } = await request(app)
      .post('/sum')
      .send({ a: 'a', b: 2 });
    expect(status).toBe(422);
    expect(body.message).toBe('Invalid input');
  });

  it('should return 422 for numbers exceeding limit', async () => {
    const { status, body } = await request(app)
      .post('/sum')
      .send({ a: 1000001, b: 2 });
    expect(status).toBe(422);
    expect(body.message).toBe("Sorry we don't support big numbers");
  });

  it('should handle zero as input correctly', async () => {
    const { status, body } = await request(app)
      .post('/sum')
      .send({ a: 0, b: 0 });
    expect(status).toBe(400);
    expect(body).toEqual({ answer: 0, id: expect.any(Number) });
  });

  it('should handle negative numbers correctly', async () => {
    const { status, body } = await request(app)
      .post('/sum')
      .send({ a: -5, b: 3 });
    expect(status).toBe(200);
    expect(body).toEqual({ answer: -2, id: expect.any(Number) });
  });

  it('should return 422 for missing parameters', async () => {
    const { status, body } = await request(app).post('/sum').send({ a: 1 });
    expect(status).toBe(422);
    expect(body.message).toBe('Invalid input');
  });
});

describe('POST /multiply', () => {
  beforeAll(async () => {
    console.log('Clearing database ...');
    await clearDb();
  });

  it('should multiply two numbers correctly', async () => {
    const { status, body } = await request(app)
      .post('/multiply')
      .send({ a: 2, b: 3 });
    expect(status).toBe(200);
    expect(body).toEqual({ answer: 6, id: expect.any(Number) });
  });

  it('should return 422 for invalid input (non-numbers)', async () => {
    const { status, body } = await request(app)
      .post('/multiply')
      .send({ a: 'a', b: 3 });
    expect(status).toBe(422);
    expect(body.message).toBe('Invalid input');
  });

  it('should return 422 for numbers exceeding limit', async () => {
    const { status, body } = await request(app)
      .post('/multiply')
      .send({ a: 1000001, b: 3 });
    expect(status).toBe(422);
    expect(body.message).toBe("Sorry we don't support big numbers");
  });

  it('should handle zero as input correctly', async () => {
    const { status, body } = await request(app)
      .post('/multiply')
      .send({ a: 0, b: 10 });
    expect(status).toBe(200);
    expect(body).toEqual({ answer: 0, id: expect.any(Number) });
  });

  it('should handle negative numbers correctly', async () => {
    const { status, body } = await request(app)
      .post('/multiply')
      .send({ a: -5, b: 2 });
    expect(status).toBe(200);
    expect(body).toEqual({ answer: -10, id: expect.any(Number) });
  });

  it('should return 422 for missing parameters', async () => {
    const { status, body } = await request(app)
      .post('/multiply')
      .send({ a: 2 });
    expect(status).toBe(422);
    expect(body.message).toBe('Invalid input');
  });
});
