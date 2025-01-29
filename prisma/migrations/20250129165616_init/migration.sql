-- CreateEnum
CREATE TYPE "RequestTypeEnum" AS ENUM ('ADD', 'MUL');

-- CreateTable
CREATE TABLE "Request" (
    "id" SERIAL NOT NULL,
    "a" INTEGER NOT NULL,
    "b" INTEGER NOT NULL,
    "answer" INTEGER NOT NULL,
    "type" "RequestTypeEnum" NOT NULL,

    CONSTRAINT "Request_pkey" PRIMARY KEY ("id")
);
