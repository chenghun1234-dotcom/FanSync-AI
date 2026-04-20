-- FanSync AI: Agency Pro Tier Migration (Zero-Cost Architecture)

-- 1. Roles & Permissions
CREATE TYPE user_role AS ENUM ('owner', 'manager', 'chatter');

-- 2. Revenue Logs (Tracking earnings per model/persona)
CREATE TABLE IF NOT EXISTS revenue_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    agency_id UUID REFERENCES agencies(id) ON DELETE CASCADE,
    model_id UUID REFERENCES models(id) ON DELETE CASCADE,
    amount DECIMAL NOT NULL,
    currency TEXT DEFAULT 'USD',
    source_type TEXT, -- 'PPV', 'Tip', 'Subscription'
    persona_at_time TEXT, -- Which persona generated this sale
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Agency members (Team Structure)
CREATE TABLE IF NOT EXISTS agency_members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    agency_id UUID REFERENCES agencies(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role DEFAULT 'chatter',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(agency_id, user_id)
);

-- 4. Constraint: 5-Chatter Limit per Agency
CREATE OR REPLACE FUNCTION check_chatter_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM agency_members WHERE agency_id = NEW.agency_id AND role = 'chatter') >= 5 THEN
        RAISE EXCEPTION 'Agency has reached the 5-chatter limit for the Pro Tier.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_chatter_limit
BEFORE INSERT ON agency_members
FOR EACH ROW
WHEN (NEW.role = 'chatter')
EXECUTE FUNCTION check_chatter_limit();

-- 5. Model Assignments (Assigning staff to specific creators)
CREATE TABLE IF NOT EXISTS model_assignments (
    member_id UUID REFERENCES agency_members(id) ON DELETE CASCADE,
    model_id UUID REFERENCES models(id) ON DELETE CASCADE,
    PRIMARY KEY (member_id, model_id)
);

-- 6. Invitations (Secure onboarding)
CREATE TABLE IF NOT EXISTS invitations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    agency_id UUID REFERENCES agencies(id) ON DELETE CASCADE,
    role user_role DEFAULT 'chatter',
    token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '48 hours'),
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Row Level Security (RLS)
ALTER TABLE revenue_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE agency_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE model_assignments ENABLE ROW LEVEL SECURITY;

-- Policy: Owners can see everything in their agency
CREATE POLICY "Owners manage agency" ON agency_members
    FOR ALL USING (agency_id IN (SELECT agency_id FROM agency_members WHERE user_id = auth.uid() AND role = 'owner'));

-- Policy: Chatters can only see models assigned to them
CREATE POLICY "Chatters access assigned models" ON models
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM model_assignments ma
            JOIN agency_members am ON ma.member_id = am.id
            WHERE ma.model_id = models.id AND am.user_id = auth.uid()
        )
    );

-- Policy: Revenue logs only visible to Agency Owners/Managers
CREATE POLICY "Agency management view revenue" ON revenue_logs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM agency_members 
            WHERE agency_id = revenue_logs.agency_id 
            AND user_id = auth.uid() 
            AND role IN ('owner', 'manager')
        )
    );
