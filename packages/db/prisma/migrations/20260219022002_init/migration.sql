-- CreateEnum
CREATE TYPE "Provider" AS ENUM ('gmail', 'outlook', 'proton');

-- CreateEnum
CREATE TYPE "AccountStatus" AS ENUM ('ok', 'needs_reauth', 'disabled');

-- CreateEnum
CREATE TYPE "SummaryImportance" AS ENUM ('low', 'med', 'high');

-- CreateEnum
CREATE TYPE "SummaryBucket" AS ENUM ('new', 'needs_response', 'waiting_response', 'archived');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Account" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "provider" "Provider" NOT NULL,
    "emailAddress" TEXT NOT NULL,
    "status" "AccountStatus" NOT NULL DEFAULT 'ok',
    "syncCursor" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProviderToken" (
    "id" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "accessToken" TEXT,
    "refreshToken" TEXT,
    "expiresAt" TIMESTAMP(3),
    "scopes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ProviderToken_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Email" (
    "id" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "providerMessageId" TEXT NOT NULL,
    "providerThreadId" TEXT,
    "internalThreadKey" TEXT NOT NULL,
    "fromName" TEXT,
    "fromEmail" TEXT,
    "to" JSONB,
    "cc" JSONB,
    "subject" TEXT,
    "snippet" TEXT,
    "bodyText" TEXT NOT NULL,
    "sentAt" TIMESTAMP(3),
    "receivedAt" TIMESTAMP(3),
    "labels" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Email_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ThreadSummary" (
    "id" TEXT NOT NULL,
    "accountId" TEXT NOT NULL,
    "internalThreadKey" TEXT NOT NULL,
    "latestEmailAt" TIMESTAMP(3),
    "summaryJson" JSONB NOT NULL,
    "model" TEXT,
    "promptVersion" TEXT,
    "importance" "SummaryImportance" NOT NULL,
    "bucket" "SummaryBucket" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ThreadSummary_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE INDEX "Account_userId_idx" ON "Account"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "Account_provider_emailAddress_key" ON "Account"("provider", "emailAddress");

-- CreateIndex
CREATE UNIQUE INDEX "ProviderToken_accountId_key" ON "ProviderToken"("accountId");

-- CreateIndex
CREATE INDEX "Email_accountId_internalThreadKey_idx" ON "Email"("accountId", "internalThreadKey");

-- CreateIndex
CREATE INDEX "Email_accountId_receivedAt_idx" ON "Email"("accountId", "receivedAt");

-- CreateIndex
CREATE UNIQUE INDEX "Email_accountId_providerMessageId_key" ON "Email"("accountId", "providerMessageId");

-- CreateIndex
CREATE INDEX "ThreadSummary_accountId_bucket_importance_idx" ON "ThreadSummary"("accountId", "bucket", "importance");

-- CreateIndex
CREATE INDEX "ThreadSummary_accountId_latestEmailAt_idx" ON "ThreadSummary"("accountId", "latestEmailAt");

-- CreateIndex
CREATE UNIQUE INDEX "ThreadSummary_accountId_internalThreadKey_key" ON "ThreadSummary"("accountId", "internalThreadKey");

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProviderToken" ADD CONSTRAINT "ProviderToken_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Email" ADD CONSTRAINT "Email_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ThreadSummary" ADD CONSTRAINT "ThreadSummary_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;
