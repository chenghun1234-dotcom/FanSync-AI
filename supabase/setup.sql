-- FanSync AI: Supabase Schema Setup

-- 1. Agencies Table (Owners of models and credits)
CREATE TABLE agencies (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  total_credits INT DEFAULT 100, -- Free trial credits
  grace_period_start TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Models Table (Individual creator profiles)
CREATE TABLE models (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  agency_id UUID REFERENCES agencies(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  persona_settings JSONB DEFAULT '{"tone": "Friendly & Flirty", "lang": "Japanese"}'::JSONB,
  gemini_api_key TEXT, -- Encrypted or stored locally in extension preferred, but can be here
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Credit Logs (Audit trail for credit usage)
CREATE TABLE credit_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  agency_id UUID REFERENCES agencies(id),
  model_id UUID REFERENCES models(id),
  amount INT NOT NULL,
  action_type TEXT NOT NULL, -- 'usage', 'topup', 'trial'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Enable RLS
ALTER TABLE agencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE models ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_logs ENABLE ROW LEVEL SECURITY;

-- 5. Policies
CREATE POLICY "Agencies can view their own data" ON agencies
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Agencies can manage their models" ON models
  FOR ALL USING (agency_id = auth.uid());

CREATE POLICY "Agencies can view their credit logs" ON credit_logs
  FOR SELECT USING (agency_id = auth.uid());
