-- Essential PostgreSQL schema for Tyk DB-hybrid architecture
-- Run this on your PostgreSQL database

\c tyk_db;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. API Definitions (Core requirement)
CREATE TABLE tyk_api_definitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    api_id VARCHAR(255) UNIQUE NOT NULL,
    org_id VARCHAR(255) NOT NULL DEFAULT 'default',
    name VARCHAR(255) NOT NULL,
    listen_path VARCHAR(500) NOT NULL,
    target_url VARCHAR(500) NOT NULL,
    definition JSONB NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Certificates (Critical for mTLS)
CREATE TABLE tyk_certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cert_id VARCHAR(255) UNIQUE NOT NULL,
    org_id VARCHAR(255) NOT NULL DEFAULT 'default',
    certificate TEXT NOT NULL,
    private_key TEXT,
    fingerprint VARCHAR(128),
    not_after TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. Portal Users (For cross-DC sync)
CREATE TABLE tyk_portal_developers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(255) UNIQUE NOT NULL,
    org_id VARCHAR(255) NOT NULL DEFAULT 'default',
    email VARCHAR(255) NOT NULL,
    username VARCHAR(255),
    password_hash VARCHAR(255),
    user_data JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. Admin Keys (Persistent admin access)
CREATE TABLE tyk_admin_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key_id VARCHAR(255) UNIQUE NOT NULL,
    org_id VARCHAR(255) NOT NULL DEFAULT 'default',
    key_hash VARCHAR(255) NOT NULL,
    permissions JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Essential indexes for performance
CREATE INDEX idx_api_definitions_org_id ON tyk_api_definitions(org_id);
CREATE INDEX idx_api_definitions_updated_at ON tyk_api_definitions(updated_at);
CREATE INDEX idx_certificates_org_id ON tyk_certificates(org_id);
CREATE INDEX idx_portal_developers_email ON tyk_portal_developers(email);
CREATE INDEX idx_admin_keys_org_id ON tyk_admin_keys(org_id);

-- Configuration change notification function
CREATE OR REPLACE FUNCTION notify_config_changes()
RETURNS TRIGGER AS $$
BEGIN
    -- Notify MDCB of configuration changes
    PERFORM pg_notify('tyk_config_changes', 
                     json_build_object(
                         'table', TG_TABLE_NAME,
                         'action', TG_OP,
                         'id', COALESCE(NEW.api_id, OLD.api_id),
                         'timestamp', NOW()
                     )::text);
    
    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for automatic config propagation
CREATE TRIGGER api_definitions_notify_changes
    AFTER INSERT OR UPDATE OR DELETE ON tyk_api_definitions
    FOR EACH ROW EXECUTE FUNCTION notify_config_changes();

COMMIT;
