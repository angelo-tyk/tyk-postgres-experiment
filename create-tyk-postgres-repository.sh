#!/bin/bash
# create-tyk-postgres-repository.sh
# Creates the complete Tyk PostgreSQL upgrade repository structure

set -e

REPO_NAME="tyk-postgres-upgrade"

echo "Creating Tyk PostgreSQL Upgrade Repository..."

# Create base directory
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

# Create directory structure
echo "Creating directory structure..."
mkdir -p {logs,backups}
mkdir -p infrastructure/{terraform/{datacenter-a,datacenter-b,shared},k8s,docker}
mkdir -p configuration/{tyk-dashboard,tyk-gateway,mdcb,pump}
mkdir -p database/{schema,migration,maintenance}
mkdir -p scripts/{upgrade,monitoring,rollback,maintenance}
mkdir -p monitoring/{prometheus,grafana,health-checks}
mkdir -p documentation
mkdir -p testing/{integration,load-testing,disaster-recovery}
mkdir -p environments/{production,staging,development}
mkdir -p .github/workflows

echo "Creating main documentation files..."

# README.md
cat > README.md << 'EOF'
# Tyk PostgreSQL Upgrade - CP Active Active

> Transform your Tyk deployment from Redis-only to PostgreSQL hybrid architecture for enterprise-grade reliability

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tyk Version](https://img.shields.io/badge/Tyk-5.0+-blue.svg)](https://tyk.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-336791.svg)](https://www.postgresql.org/)

## 🎯 **What This Solves**

If you're running Tyk CP Active Active and experiencing these **critical issues**:

- ❌ **mTLS certificates & admin keys** stored only in Redis → replication headaches
- ❌ **Configuration changes** don't auto-propagate via MDCB → manual restarts required
- ❌ **Developer Portal** breaks in Active-Active mode → user sync failures  
- ❌ **Analytics data** lost if datacenter down >15 minutes → audit compliance issues

This upgrade **fixes all of them** by implementing a PostgreSQL hybrid architecture.

## ✅ **After Upgrade**

| Critical Issue | Status | Solution |
|----------------|--------|----------|
| **Persistent Storage** | ✅ **SOLVED** | PostgreSQL ACID compliance |
| **Config Propagation** | ✅ **SOLVED** | Automatic NOTIFY/LISTEN via MDCB |
| **Portal Active-Active** | ✅ **SOLVED** | PostgreSQL user replication |
| **Analytics Persistence** | ✅ **SOLVED** | No more 15-minute data loss |
| **GitOps Integration** | ✅ **SOLVED** | Auto gateway reloads (no restarts!) |

⚠️ **Rate limiting counters** remain Redis-dependent (architectural limitation)

## 🚀 **Quick Start**

```bash
git clone https://github.com/your-org/tyk-postgres-upgrade
cd tyk-postgres-upgrade

# Follow the complete installation guide
cat INSTALL.md

# Run upgrade process
./scripts/upgrade/01-pre-flight-check.sh
./scripts/upgrade/02-backup-current-setup.sh
./scripts/upgrade/03-deploy-postgresql.sh --setup="active-active"
# ... continue with remaining steps
```

## 📁 **Repository Structure**

```
tyk-postgres-upgrade/
├── README.md                 # This file
├── INSTALL.md               # Complete installation guide
├── UPGRADE-CHECKLIST.md     # Pre-upgrade verification
├── infrastructure/          # Infrastructure as Code
├── configuration/          # Tyk configuration templates
├── database/              # Database schema & migration
├── scripts/              # Automation scripts
├── monitoring/           # Observability
├── documentation/        # Detailed documentation
├── testing/             # Integration & load tests
└── environments/        # Environment-specific configs
```

## 🎯 **Success Criteria**

After upgrade completion, you should have:

- ✅ **Zero API downtime** during normal operations
- ✅ **Automatic config propagation** via GitOps (no manual restarts!)  
- ✅ **Developer Portal users** synchronized across both DCs
- ✅ **Analytics data** never lost (persistent PostgreSQL storage)
- ✅ **Certificate management** working across both DCs via PostgreSQL
- ✅ **< 30 second failover** between datacenters
- ✅ **< 100ms API latency** maintained for on-premise gateways
- ✅ **MDCB sync** working from CP to all data planes

## 📚 **Documentation**

- **[INSTALL.md](INSTALL.md)** - Complete installation guide
- **[ARCHITECTURE.md](documentation/ARCHITECTURE.md)** - Technical architecture details
- **[TROUBLESHOOTING.md](documentation/TROUBLESHOOTING.md)** - Common issues & solutions
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development guidelines

## 🚨 **Emergency Rollback**

If something goes wrong during upgrade:

```bash
# Emergency rollback to Redis-only
./scripts/rollback/emergency-rollback.sh

# Restores original configuration in < 5 minutes
```

## 📄 **License**

MIT License - see [LICENSE](LICENSE) file for details.

---

**Transform your Tyk deployment from fragile to enterprise-grade with PostgreSQL hybrid architecture.**
EOF

# INSTALL.md (abbreviated version - you'll need to copy the full content)
cat > INSTALL.md << 'EOF'
# Tyk PostgreSQL Upgrade - Installation Guide

> Complete step-by-step installation for transforming Redis-only Tyk to PostgreSQL hybrid architecture

## 📋 **Prerequisites Checklist**

### **Environment Requirements**
- [ ] Tyk Enterprise license with MDCB enabled
- [ ] Current Tyk deployment running (Dashboard + Gateway + MDCB)
- [ ] PostgreSQL 14+ installation capability
- [ ] Network connectivity between datacenters
- [ ] Maintenance window: 2-4 hours (depending on data size)

## 🚀 **Installation Steps**

### **Step 1: Environment Setup**

```bash
# Clone the repository
git clone https://github.com/your-org/tyk-postgres-upgrade
cd tyk-postgres-upgrade

# Set environment variables
export ENVIRONMENT=production
export TYK_LICENSE_KEY="your-enterprise-license-key"
export POSTGRES_PASSWORD="$(openssl rand -base64 32)"
export ADMIN_SECRET="$(openssl rand -base64 32)"

# Load environment-specific configuration
source environments/${ENVIRONMENT}/config.env

# Verify prerequisites
chmod +x scripts/upgrade/*.sh
./scripts/upgrade/01-pre-flight-check.sh
```

### **Step 2: Backup Current Setup**

```bash
./scripts/upgrade/02-backup-current-setup.sh
```

### **Step 3: Deploy PostgreSQL Infrastructure**

```bash
./scripts/upgrade/03-deploy-postgresql.sh \
  --setup="active-active" \
  --primary-dc="datacenter-a" \
  --secondary-dc="datacenter-b"
```

### **Step 4: Setup GitOps Integration**

```bash
./scripts/upgrade/04-setup-gitops-pipeline.sh \
  --postgres-host="${POSTGRES_PRIMARY_HOST}"
```

### **Step 5: Migrate Data**

```bash
./scripts/upgrade/05-migrate-data.sh
```

### **Step 6: Update Configurations**

```bash
./scripts/upgrade/06-update-configs.sh \
  --postgres-primary="${POSTGRES_PRIMARY_HOST}" \
  --postgres-secondary="${POSTGRES_SECONDARY_HOST}"
```

### **Step 7: Rolling Restart**

```bash
./scripts/upgrade/07-restart-services.sh --rolling --validate
```

### **Step 8: Verify Success**

```bash
./scripts/upgrade/08-verify-upgrade.sh
```

## ✅ **Success Criteria**

Your upgrade is successful when:

- [ ] **All API calls** work through gateways (< 100ms latency)
- [ ] **Dashboard accessible** from both datacenters
- [ ] **MDCB sync working** (configurations propagate within 30 seconds)  
- [ ] **PostgreSQL replication** healthy (< 5 second lag)
- [ ] **Portal users** can login from both datacenters
- [ ] **Analytics data** flowing to PostgreSQL
- [ ] **Certificate management** working via PostgreSQL
- [ ] **GitOps integration** triggers automatic gateway config updates
- [ ] **No manual restarts** needed for configuration changes

---

**Your Tyk deployment is now enterprise-ready with PostgreSQL hybrid architecture!**
EOF

# Create basic scripts directory structure and key files
echo "Creating upgrade scripts..."

# 01-pre-flight-check.sh
cat > scripts/upgrade/01-pre-flight-check.sh << 'EOF'
#!/bin/bash
# scripts/upgrade/01-pre-flight-check.sh
# Pre-flight checks before PostgreSQL upgrade

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging setup
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/pre-flight-check.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

# Check required environment variables
check_environment() {
    log "Checking environment variables..."
    
    required_vars=(
        "TYK_LICENSE_KEY"
        "POSTGRES_PASSWORD"
        "TYK_SECRET"
        "ADMIN_SECRET"
    )
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            error "Required environment variable $var not set"
            return 1
        fi
    done
    success "Environment variables check passed"
}

# Check required tools
check_tools() {
    log "Checking required tools..."
    
    required_tools=("curl" "jq" "psql" "redis-cli" "python3" "docker" "git")
    
    missing_tools=()
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -ne 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
        return 1
    fi
    success "Required tools check passed"
}

# Check Tyk services health
check_tyk_health() {
    log "Checking Tyk services health..."
    
    # Check Gateway
    if curl -sf -H "X-Tyk-Authorization: $TYK_SECRET" \
         http://localhost:8080/tyk/hello >/dev/null 2>&1; then
        success "Tyk Gateway healthy"
    else
        error "Tyk Gateway not responding"
        return 1
    fi
    
    # Check Dashboard
    if curl -sf -H "Authorization: $ADMIN_SECRET" \
         http://localhost:3000/admin/config >/dev/null 2>&1; then
        success "Tyk Dashboard healthy"
    else
        error "Tyk Dashboard not responding"
        return 1
    fi
}

# Main execution
main() {
    log "Starting Tyk PostgreSQL upgrade pre-flight check..."
    
    local checks=("check_environment" "check_tools" "check_tyk_health")
    local failed_checks=()
    
    for check in "${checks[@]}"; do
        if ! $check; then
            failed_checks+=("$check")
        fi
        echo
    done
    
    if [[ ${#failed_checks[@]} -eq 0 ]]; then
        success "All pre-flight checks passed! Ready to proceed with upgrade."
        log "Next step: ./scripts/upgrade/02-backup-current-setup.sh"
        exit 0
    else
        error "Pre-flight checks failed: ${failed_checks[*]}"
        exit 1
    fi
}

main "$@"
EOF

chmod +x scripts/upgrade/01-pre-flight-check.sh

# Create database schema files
echo "Creating database schema files..."

cat > database/schema/001_initial_schema.sql << 'EOF'
-- database/schema/001_initial_schema.sql
-- Initial PostgreSQL schema for Tyk hybrid architecture

\c tyk_db;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create schema version table
CREATE TABLE IF NOT EXISTS schema_version (
    version VARCHAR(50) PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT NOW(),
    description TEXT
);

INSERT INTO schema_version (version, description) 
VALUES ('001', 'Initial schema creation')
ON CONFLICT (version) DO NOTHING;

-- Organizations table
CREATE TABLE IF NOT EXISTS tyk_organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    org_id VARCHAR(255) UNIQUE NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    owner_slug VARCHAR(255) NOT NULL,
    cname_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- API definitions table
CREATE TABLE IF NOT EXISTS tyk_api_definitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    api_id VARCHAR(255) UNIQUE NOT NULL,
    org_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255),
    listen_path VARCHAR(500) NOT NULL,
    target_url VARCHAR(500) NOT NULL,
    definition JSONB NOT NULL,
    version VARCHAR(50) DEFAULT 'v1.0',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_api_definitions_org_id ON tyk_api_definitions(org_id);
CREATE INDEX IF NOT EXISTS idx_api_definitions_listen_path ON tyk_api_definitions(listen_path);
CREATE INDEX IF NOT EXISTS idx_api_definitions_updated_at ON tyk_api_definitions(updated_at);

-- Create trigger function for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER update_tyk_api_definitions_updated_at 
    BEFORE UPDATE ON tyk_api_definitions 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMIT;
EOF

# Create basic Terraform files
echo "Creating Terraform files..."

cat > infrastructure/terraform/datacenter-a/main.tf << 'EOF'
# infrastructure/terraform/datacenter-a/main.tf
# PostgreSQL primary setup for Datacenter A

terraform {
  required_version = ">= 1.0"
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.15"
    }
  }
}

variable "postgres_password" {
  description = "Password for PostgreSQL admin user"
  type        = string
  sensitive   = true
}

# PostgreSQL provider configuration
provider "postgresql" {
  host            = var.postgres_host
  port            = var.postgres_port
  database        = "postgres"
  username        = "postgres"
  password        = var.postgres_password
  sslmode         = "require"
  connect_timeout = 15
}

# Create Tyk database
resource "postgresql_database" "tyk_db" {
  name  = "tyk_db"
  owner = "postgres"
}

# Create Tyk admin user
resource "postgresql_role" "tyk_admin" {
  name     = "tyk_admin"
  login    = true
  password = var.postgres_password
}
EOF

# Create monitoring files
echo "Creating monitoring files..."

cat > monitoring/docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:v2.40.0
    container_name: tyk-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    restart: unless-stopped

  grafana:
    image: grafana/grafana:9.3.0
    container_name: tyk-grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
EOF

# Create environment configuration
echo "Creating environment configurations..."

cat > environments/production/config.env << 'EOF'
# Production Environment Configuration
export ENVIRONMENT=production

# PostgreSQL Configuration
export POSTGRES_PRIMARY_HOST="postgres-primary.production.internal"
export POSTGRES_SECONDARY_HOST="postgres-standby.production.internal"
export POSTGRES_PORT="5432"
export POSTGRES_DB="tyk_db"
export POSTGRES_USER="tyk_admin"

# Redis Configuration (Performance Cache)
export REDIS_HOST="redis-cluster.production.internal"
export REDIS_PORT="6379"
export REDIS_DATABASE="0"

# Tyk Configuration
export TYK_GATEWAY_HOST="http://tyk-gateway.production.internal"
export TYK_DASHBOARD_HOST="http://tyk-dashboard.production.internal"

# MDCB Configuration
export MDCB_ENDPOINTS="http://mdcb-dc1.internal:8181,http://mdcb-dc2.internal:8181"
EOF

cat > environments/staging/config.env << 'EOF'
# Staging Environment Configuration
export ENVIRONMENT=staging

# PostgreSQL Configuration (Single instance for staging)
export POSTGRES_PRIMARY_HOST="postgres-staging.internal"
export POSTGRES_PORT="5432"
export POSTGRES_DB="tyk_db"
export POSTGRES_USER="tyk_admin"

# Redis Configuration
export REDIS_HOST="redis-staging.internal"
export REDIS_PORT="6379"
export REDIS_DATABASE="0"

# Tyk Configuration
export TYK_GATEWAY_HOST="http://tyk-gateway-staging.internal"
export TYK_DASHBOARD_HOST="http://tyk-dashboard-staging.internal"
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Logs
logs/
*.log

# Environment files
.env
.env.local
environments/*/secrets.env

# Backup files
backups/
*.rdb
*.sql

# Temporary files
tmp/
*.tmp
*.swp
*~

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/

# Python
__pycache__/
*.pyc

# Terraform
*.tfstate
*.tfstate.*
.terraform/

# Sensitive data
*.key
*.crt
*.pem
EOF

# Create LICENSE
cat > LICENSE << 'EOF'
MIT License

Copyright (c) 2025 Tyk PostgreSQL Upgrade Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# Create basic migration requirements
cat > database/migration/requirements.txt << 'EOF'
psycopg2-binary>=2.9.0
redis>=4.0.0
requests>=2.28.0
EOF

# Create placeholder files for completeness
touch logs/.gitkeep
touch backups/.gitkeep

echo ""
echo "✅ Repository created successfully!"
echo ""
echo "📁 Repository: $REPO_NAME/"
echo "📄 Files created: $(find $REPO_NAME -type f | wc -l)"
echo "📂 Directories created: $(find $REPO_NAME -type d | wc -l)"
echo ""
echo "🚀 Next steps:"
echo "1. cd $REPO_NAME"
echo "2. Copy the remaining files from the conversation artifacts"
echo "3. Set up your environment variables"
echo "4. Run: ./scripts/upgrade/01-pre-flight-check.sh"
echo ""
echo "💡 Note: This script creates the basic structure."
echo "   You'll need to copy the full content for each file from the artifacts above."
EOF

chmod +x create-tyk-postgres-repository.sh
