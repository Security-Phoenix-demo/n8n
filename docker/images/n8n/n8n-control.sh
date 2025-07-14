#!/bin/bash

# n8n Control Script
# Simple script to start, stop, and manage n8n services

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "n8n Control Script"
    echo "================="
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start     - Start n8n and PostgreSQL services"
    echo "  stop      - Stop n8n and PostgreSQL services"
    echo "  restart   - Restart n8n and PostgreSQL services"
    echo "  status    - Show status of services"
    echo "  logs      - Show logs (use -f for follow)"
    echo "  update    - Pull latest images and restart"
    echo "  clean     - Stop services and remove volumes"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start"
    echo "  $0 logs -f"
    echo "  $0 status"
}

# Function to start services
start_services() {
    print_status "Starting n8n and PostgreSQL..."
    docker compose up -d
    print_success "Services started"
    echo ""
    echo "🌐 Access URLs:"
    echo "   - Local: http://localhost:5678"
    echo "   - Domain: https://n8n.securityphoenix.com"
}

# Function to stop services
stop_services() {
    print_status "Stopping n8n and PostgreSQL..."
    docker compose down
    print_success "Services stopped"
}

# Function to restart services
restart_services() {
    print_status "Restarting n8n and PostgreSQL..."
    docker compose restart
    print_success "Services restarted"
}

# Function to show status
show_status() {
    print_status "Service Status:"
    docker compose ps
}

# Function to show logs
show_logs() {
    if [ "$1" = "-f" ]; then
        print_status "Showing logs (following)..."
        docker compose logs -f
    else
        print_status "Showing recent logs..."
        docker compose logs --tail=50
    fi
}

# Function to update services
update_services() {
    print_status "Pulling latest images..."
    docker compose pull
    print_status "Restarting services with new images..."
    docker compose up -d
    print_success "Services updated and restarted"
}

# Function to clean up
clean_services() {
    print_warning "This will stop services and remove all data volumes!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Stopping services and removing volumes..."
        docker compose down -v
        print_success "Services stopped and volumes removed"
    else
        print_status "Cleanup cancelled"
    fi
}

# Main script logic
case "${1:-help}" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "$2"
        ;;
    update)
        update_services
        ;;
    clean)
        clean_services
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac 