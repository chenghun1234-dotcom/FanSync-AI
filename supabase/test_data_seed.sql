-- FanSync AI: Realistic Test Data Seed Script
-- README: Run this in the Supabase SQL Editor to populate your dashboard.

-- Note: We use auth.uid() so the data is assigned to YOU when you run it.

-- 1. Ensure the Agency exists for the current user
INSERT INTO agencies (id, name, total_credits)
VALUES (auth.uid(), 'FanSync Elite Agency', 25000)
ON CONFLICT (id) DO UPDATE SET name = 'FanSync Elite Agency', total_credits = 25000;

-- 2. Create 3 Professional Models
-- We'll store the IDs in variables for later use (Postgres scratchpad style)
DO $$
DECLARE
    agency_id_raw UUID := auth.uid();
    model_1 UUID;
    model_2 UUID;
    model_3 UUID;
BEGIN
    -- Insert Models
    INSERT INTO models (agency_id, name, persona_settings)
    VALUES (agency_id_raw, 'Model_Sana (Tokyo)', '{"tone": "Gyaru", "style": "Playful/Cutesy", "sales_pitch": "High Energy"}'::JSONB)
    RETURNING id INTO model_1;

    INSERT INTO models (agency_id, name, persona_settings)
    VALUES (agency_id_raw, 'Model_Yui (Global)', '{"tone": "Mature", "style": "Elegant/Sophisticated", "sales_pitch": "Subtle Upsell"}'::JSONB)
    RETURNING id INTO model_2;

    INSERT INTO models (agency_id, name, persona_settings)
    VALUES (agency_id_raw, 'Model_Rei (Cyber)', '{"tone": "Tsundere", "style": "Sharp/Witty", "sales_pitch": "Challenge Fan"}'::JSONB)
    RETURNING id INTO model_3;

    -- 3. Insert Revenue Logs (Past 7 days trend)
    INSERT INTO revenue_logs (agency_id, model_id, amount, source_type, persona_at_time, created_at)
    VALUES 
    (agency_id_raw, model_1, 450.00, 'PPV', 'Sales', NOW() - INTERVAL '6 days'),
    (agency_id_raw, model_1, 120.00, 'Tip', 'Casual', NOW() - INTERVAL '5 days'),
    (agency_id_raw, model_2, 890.00, 'Subscription', 'Standard', NOW() - INTERVAL '4 days'),
    (agency_id_raw, model_3, 210.00, 'PPV', 'Aggressive', NOW() - INTERVAL '3 days'),
    (agency_id_raw, model_1, 550.00, 'Tip', 'Sales', NOW() - INTERVAL '2 days'),
    (agency_id_raw, model_2, 320.00, 'PPV', 'Standard', NOW() - INTERVAL '1 day'),
    (agency_id_raw, model_3, 1240.00, 'Subscription', 'Sales', NOW());

    -- 4. Initial Agency Member (Self as Owner)
    INSERT INTO agency_members (agency_id, user_id, role)
    VALUES (agency_id_raw, auth.uid(), 'owner')
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'Test Data Seeded Successfully for User %', agency_id_raw;
END $$;
