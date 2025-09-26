#!/bin/bash
# Simple verification that the PostgreSQL upgrade is working

echo "🔍 Verifying PostgreSQL upgrade..."

# Test PostgreSQL connectivity
echo "📊 Testing PostgreSQL..."
psql -h localhost -U tyk_admin -d tyk_db -c "SELECT COUNT(*) as api_count FROM tyk_api_definitions;" || {
    echo "❌ PostgreSQL connection failed"
    exit 1
}

# Test Redis connectivity
echo "🔴 Testing Redis..."
redis-cli ping > /dev/null || {
    echo "❌ Redis connection failed"
    exit 1
}

# Test Tyk Gateway
echo "🚪 Testing Gateway..."
curl -sf http://localhost:8080/hello > /dev/null || {
    echo "❌ Gateway not responding"
    exit 1
}

# Test Tyk Dashboard
echo "📱 Testing Dashboard..."
curl -sf http://localhost:3000/admin/config > /dev/null || {
    echo "❌ Dashboard not responding"
    exit 1
}

echo "✅ All essential components working!"
echo "🎉 PostgreSQL hybrid upgrade successful!"
