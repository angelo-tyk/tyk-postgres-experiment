#!/usr/bin/env python3
"""
Essential data migration from Redis to PostgreSQL
Migrates only the critical data: APIs, certificates, portal users, admin keys
"""

import redis
import psycopg2
import json
import sys
import os

def migrate_essential_data():
    # Connect to Redis
    r = redis.Redis(host='localhost', port=6379, db=0, decode_responses=True)
    
    # Connect to PostgreSQL
    pg_conn = psycopg2.connect(
        host="localhost",
        database="tyk_db", 
        user="tyk_admin",
        password=os.getenv('POSTGRES_PASSWORD', 'your_password')
    )
    pg_cursor = pg_conn.cursor()
    
    print("🔄 Starting essential data migration...")
    
    # 1. Migrate API Definitions
    print("📡 Migrating API definitions...")
    api_keys = r.keys("apidef-*")
    for key in api_keys:
        try:
            api_data = json.loads(r.get(key))
            api_id = api_data.get('api_id', key.split('-')[-1])
            
            pg_cursor.execute("""
                INSERT INTO tyk_api_definitions (api_id, org_id, name, listen_path, target_url, definition)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (api_id) DO UPDATE SET
                    definition = EXCLUDED.definition,
                    updated_at = NOW()
            """, (
                api_id,
                api_data.get('org_id', 'default'),
                api_data.get('name', 'Unknown API'),
                api_data.get('proxy', {}).get('listen_path', '/'),
                api_data.get('proxy', {}).get('target_url', ''),
                json.dumps(api_data)
            ))
            print(f"  ✅ Migrated API: {api_id}")
        except Exception as e:
            print(f"  ❌ Failed to migrate API {key}: {e}")
    
    # 2. Migrate Certificates
    print("🔐 Migrating certificates...")
    cert_keys = r.keys("cert-*")
    for key in cert_keys:
        try:
            cert_data = r.hgetall(key)
            cert_id = key.replace('cert-', '')
            
            pg_cursor.execute("""
                INSERT INTO tyk_certificates (cert_id, org_id, certificate, private_key, fingerprint)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (cert_id) DO UPDATE SET
                    certificate = EXCLUDED.certificate,
                    updated_at = NOW()
            """, (
                cert_id,
                cert_data.get('org_id', 'default'),
                cert_data.get('certificate', ''),
                cert_data.get('private_key', ''),
                cert_data.get('fingerprint', '')
            ))
            print(f"  ✅ Migrated certificate: {cert_id}")
        except Exception as e:
            print(f"  ❌ Failed to migrate certificate {key}: {e}")
    
    # 3. Migrate Portal Users
    print("👥 Migrating portal users...")
    user_keys = r.keys("user-*")
    for key in user_keys:
        try:
            user_data = json.loads(r.get(key))
            user_id = user_data.get('id', key.replace('user-', ''))
            
            pg_cursor.execute("""
                INSERT INTO tyk_portal_developers (user_id, org_id, email, username, password_hash, user_data)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (user_id) DO UPDATE SET
                    user_data = EXCLUDED.user_data,
                    updated_at = NOW()
            """, (
                user_id,
                user_data.get('org_id', 'default'),
                user_data.get('email', ''),
                user_data.get('username', ''),
                user_data.get('password_hash', ''),
                json.dumps(user_data)
            ))
            print(f"  ✅ Migrated user: {user_id}")
        except Exception as e:
            print(f"  ❌ Failed to migrate user {key}: {e}")
    
    # 4. Migrate Admin Keys
    print("🔑 Migrating admin keys...")
    admin_keys = r.keys("admin-key-*")
    for key in admin_keys:
        try:
            key_data = json.loads(r.get(key))
            key_id = key_data.get('key', key.replace('admin-key-', ''))
            
            pg_cursor.execute("""
                INSERT INTO tyk_admin_keys (key_id, org_id, key_hash, permissions)
                VALUES (%s, %s, %s, %s)
                ON CONFLICT (key_id) DO UPDATE SET
                    permissions = EXCLUDED.permissions,
                    updated_at = NOW()
            """, (
                key_id,
                key_data.get('org_id', 'default'),
                key_data.get('hash', ''),
                json.dumps(key_data.get('permissions', {}))
            ))
            print(f"  ✅ Migrated admin key: {key_id}")
        except Exception as e:
            print(f"  ❌ Failed to migrate admin key {key}: {e}")
    
    # Commit all changes
    pg_conn.commit()
    pg_cursor.close()
    pg_conn.close()
    
    print("✅ Essential data migration completed!")
    print("🔄 Now restart your Tyk services with the new configuration")

if __name__ == "__main__":
    migrate_essential_data()
