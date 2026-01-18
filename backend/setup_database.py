#!/usr/bin/env python3
"""
Database setup script for Nonprofit Learning Platform.
Helps create database and run initial migrations.
"""
import os
import sys
import subprocess
from pathlib import Path

def check_postgresql():
    """Check if PostgreSQL is available."""
    try:
        result = subprocess.run(['psql', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ PostgreSQL found: {result.stdout.strip()}")
            return True
    except FileNotFoundError:
        pass
    return False

def create_database_sqlite():
    """Create SQLite database for development."""
    db_path = Path("nonprofit_learning.db")
    if db_path.exists():
        print(f"⚠️  SQLite database already exists at {db_path}")
        response = input("Do you want to recreate it? (y/N): ")
        if response.lower() == 'y':
            db_path.unlink()
            print("✅ Removed existing database")
        else:
            print("✅ Using existing database")
            return str(db_path.absolute())
    
    # Create empty file
    db_path.touch()
    print(f"✅ Created SQLite database at {db_path.absolute()}")
    return str(db_path.absolute())

def setup_env_file(db_url):
    """Update or create .env file with database URL."""
    env_file = Path(".env")
    env_example = Path("env.example")
    
    if not env_file.exists():
        if env_example.exists():
            env_file.write_text(env_example.read_text())
            print("✅ Created .env file from template")
        else:
            env_file.write_text("")
            print("✅ Created new .env file")
    
    # Read current .env
    content = env_file.read_text()
    
    # Update or add DATABASE_URL
    lines = content.split('\n')
    updated = False
    for i, line in enumerate(lines):
        if line.startswith('DATABASE_URL='):
            lines[i] = f'DATABASE_URL={db_url}'
            updated = True
            break
    
    if not updated:
        lines.append(f'DATABASE_URL={db_url}')
    
    env_file.write_text('\n'.join(lines))
    print(f"✅ Updated DATABASE_URL in .env file")

def run_migrations():
    """Run Alembic migrations."""
    print("\n📦 Running database migrations...")
    try:
        result = subprocess.run(
            ['alembic', 'upgrade', 'head'],
            capture_output=True,
            text=True
        )
        if result.returncode == 0:
            print("✅ Migrations completed successfully")
            return True
        else:
            print(f"❌ Migration failed: {result.stderr}")
            return False
    except FileNotFoundError:
        print("❌ Alembic not found. Make sure you're in a virtual environment with dependencies installed.")
        return False

def main():
    """Main setup function."""
    print("🚀 Database Setup for Nonprofit Learning Platform\n")
    
    # Check if we're in the backend directory
    if not Path("app").exists() or not Path("alembic").exists():
        print("❌ Please run this script from the backend directory")
        sys.exit(1)
    
    print("Choose database type:")
    print("1. PostgreSQL (production-ready)")
    print("2. SQLite (easy development setup)")
    
    choice = input("\nEnter choice (1 or 2, default: 2): ").strip() or "2"
    
    if choice == "1":
        # PostgreSQL setup
        if not check_postgresql():
            print("\n❌ PostgreSQL is not installed or not in PATH")
            print("📦 Install PostgreSQL:")
            print("   macOS: brew install postgresql@14")
            print("   Ubuntu: sudo apt-get install postgresql postgresql-contrib")
            print("\n💡 Alternatively, use SQLite for development (option 2)")
            sys.exit(1)
        
        print("\n📝 PostgreSQL Setup")
        db_user = input("Enter PostgreSQL username (default: postgres): ").strip() or "postgres"
        db_password = input("Enter PostgreSQL password: ").strip()
        db_name = input("Enter database name (default: nonprofit_learning): ").strip() or "nonprofit_learning"
        db_host = input("Enter host (default: localhost): ").strip() or "localhost"
        db_port = input("Enter port (default: 5432): ").strip() or "5432"
        
        db_url = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
        
        print(f"\n📦 Creating database '{db_name}'...")
        # Try to create database using psql
        try:
            env = os.environ.copy()
            env['PGPASSWORD'] = db_password
            result = subprocess.run(
                ['psql', '-h', db_host, '-p', db_port, '-U', db_user, '-c', f'CREATE DATABASE {db_name};'],
                env=env,
                capture_output=True,
                text=True
            )
            if result.returncode != 0:
                if "already exists" in result.stderr:
                    print(f"⚠️  Database '{db_name}' already exists, using it")
                else:
                    print(f"⚠️  Could not create database automatically: {result.stderr}")
                    print(f"💡 Try running manually: createdb -U {db_user} {db_name}")
        except Exception as e:
            print(f"⚠️  Could not create database automatically: {e}")
            print(f"💡 Please create the database manually: createdb -U {db_user} {db_name}")
    
    else:
        # SQLite setup
        print("\n📝 SQLite Setup (Development)")
        db_path = create_database_sqlite()
        db_url = f"sqlite:///{db_path}"
    
    # Update .env file
    setup_env_file(db_url)
    
    # Run migrations
    if run_migrations():
        print("\n🎉 Database setup complete!")
        print("\nNext steps:")
        print("1. Make sure all environment variables are set in .env")
        print("2. Start the server: uvicorn app.main:app --reload --port 8000")
    else:
        print("\n⚠️  Setup incomplete. Please check the errors above.")

if __name__ == "__main__":
    main()
