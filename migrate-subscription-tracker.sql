-- Subscription Tracker tables
-- Run this in Supabase SQL Editor

CREATE TABLE IF NOT EXISTS sub_subscriptions (
  id BIGINT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  amount NUMERIC NOT NULL DEFAULT 0,
  cycle TEXT NOT NULL DEFAULT 'monthly' CHECK (cycle IN ('weekly','monthly','quarterly','yearly')),
  category TEXT NOT NULL DEFAULT 'other',
  currency TEXT NOT NULL DEFAULT 'TWD' CHECK (currency IN ('TWD','USD','JPY')),
  member TEXT,
  billing_day INTEGER DEFAULT 1 CHECK (billing_day >= 1 AND billing_day <= 31),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sub_members (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, name)
);

-- RLS
ALTER TABLE sub_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE sub_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own subscriptions" ON sub_subscriptions
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users manage own members" ON sub_members
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_sub_subscriptions_user ON sub_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_sub_members_user ON sub_members(user_id);
