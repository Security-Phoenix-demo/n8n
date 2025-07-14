#!/bin/bash

# n8n Setup Script
# This script sets up and starts n8n with PostgreSQL

set -e  # Exit on any error

echo "🚀 n8n Setup Script"
echo "=================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
print_status "Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi
print_success "Docker is running"

# Check if Docker Compose is available
print_status "Checking Docker Compose..."
if ! docker compose version > /dev/null 2>&1; then
    print_error "Docker Compose is not available. Please install Docker Compose."
    exit 1
fi
print_success "Docker Compose is available"

# Create data directories
print_status "Creating data directories..."
mkdir -p data postgres-data
print_success "Data directories created"

# Set proper permissions
print_status "Setting directory permissions..."
if command -v sudo > /dev/null 2>&1; then
    sudo chown -R 999:999 postgres-data 2>/dev/null || true
    sudo chown -R 1000:1000 data 2>/dev/null || true
    print_success "Permissions set"
else
    print_warning "sudo not available, skipping permission setting"
fi

# Check if .env file exists
if [ ! -f .env ]; then
    print_status "Creating .env file..."
    cat > .env << 'EOF'
#n8n Settings

DOMAIN_NAME=securityphoenix.com 
SUBDOMAIN=n8n
GENERIC_TIMEZONE=Europe/London
N8N_HOST=n8n.securityphoenix.com
N8N_PROTOCOL=https
WEBHOOK_URL=https://n8n.securityphoenix.com/
N8N_PORT=5678
NODE_ENV=preproduction

# Postgres Settings
POSTGRES_DB=n8n
POSTGRES_USER=n8n
POSTGRES_PASSWORD=Phoenix1100
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# n8n Settings
N8N_HOST=0.0.0.0
N8N_PORT=5678

# n8n Encryption Key (auto-generated)
N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)
EOF
    print_success ".env file created with default settings"
else
    print_status ".env file already exists"
    
    # Check if encryption key exists, if not add it
    if ! grep -q "N8N_ENCRYPTION_KEY" .env; then
        print_status "Adding encryption key to .env..."
        echo "" >> .env
        echo "# n8n Encryption Key (auto-generated)" >> .env
        echo "N8N_ENCRYPTION_KEY=$(openssl rand -hex 32)" >> .env
        print_success "Encryption key added to .env"
    fi
fi

# Clean up any existing containers
print_status "Cleaning up existing containers..."
docker compose down -v 2>/dev/null || true
print_success "Cleanup completed"

# Pull latest images
print_status "Pulling latest Docker images..."
docker compose pull
print_success "Images pulled successfully"

# Start the services
print_status "Starting n8n and PostgreSQL..."
docker compose up -d

# Wait for services to start
print_status "Waiting for services to start..."
sleep 10

# Check if services are running
print_status "Checking service status..."
if docker compose ps | grep -q "Up"; then
    print_success "Services are running!"
else
    print_error "Services failed to start. Check logs with: docker compose logs"
    exit 1
fi

# Show final status
echo ""
echo "🎉 n8n Setup Complete!"
echo "====================="
echo ""
echo "📊 Service Status:"
docker compose ps
echo ""
echo "🌐 Access URLs:"
echo "   - Local: http://localhost:5678"
echo "   - Domain: https://n8n.securityphoenix.com"
echo ""
echo "📝 Useful Commands:"
echo "   - View logs: docker compose logs -f"
echo "   - Stop services: docker compose down"
echo "   - Restart: docker compose restart"
echo "   - Update: docker compose pull && docker compose up -d"
echo ""
echo "📁 Data Locations:"
echo "   - n8n data: ./data"
echo "   - PostgreSQL data: ./postgres-data"
echo ""
print_success "Setup completed successfully!" 