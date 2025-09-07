#!/usr/bin/env python3
"""
🗄️ Comprehensive Spring PetClinic Database Setup Script
=======================================================

This consolidated script handles ALL database operations for the Spring PetClinic application.
It includes setup, sample data creation, backup/restore, and maintenance operations.

📋 PREREQUISITES:
- MySQL 8.0+ installed and running
- Python 3.8+ with required packages
- Kubernetes cluster access (for K8s deployments)
- Proper database credentials configured

🚀 USAGE:
    python scripts/database-setup.py --help                    # Show all options
    python scripts/database-setup.py --validate               # Test database connections
    python scripts/database-setup.py --init-clean            # Clean database setup
    python scripts/database-setup.py --init-sample           # Setup with sample data
    python scripts/database-setup.py --reset                 # Reset all databases
    python scripts/database-setup.py --backup                # Create backup
    python scripts/database-setup.py --restore backup.sql    # Restore from backup
    python scripts/database-setup.py --all                   # Complete setup

🔧 CONFIGURATION:
Update these variables in the script or use environment variables:
    MYSQL_HOST=localhost
    MYSQL_PORT=3306
    MYSQL_ROOT_PASSWORD=petclinic
    MYSQL_USER=petclinic
    MYSQL_PASSWORD=petclinic

Author: Spring PetClinic Development Team
Version: 2.0.0 Enterprise Edition
Last Updated: December 2024
"""

import os
import sys
import argparse
import subprocess
import json
import time
import logging
import mysql.connector
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple, Any
from dataclasses import dataclass

# ============================================================================
# CONFIGURATION AND CONSTANTS
# ============================================================================

@dataclass
class DatabaseConfig:
    """Database configuration class"""
    host: str
    port: int
    root_password: str
    user: str
    password: str
    databases: List[str]

# Default configuration
DEFAULT_CONFIG = DatabaseConfig(
    host=os.getenv('MYSQL_HOST', 'localhost'),
    port=int(os.getenv('MYSQL_PORT', '3306')),
    root_password=os.getenv('MYSQL_ROOT_PASSWORD', 'petclinic'),
    user=os.getenv('MYSQL_USER', 'petclinic'),
    password=os.getenv('MYSQL_PASSWORD', 'petclinic'),
    databases=['petclinic_customer', 'petclinic_vet', 'petclinic_visit']
)

# Kubernetes configuration
K8S_NAMESPACE = os.getenv('K8S_NAMESPACE', 'petclinic')
K8S_ENABLED = os.getenv('K8S_ENABLED', 'false').lower() == 'true'

# Logging configuration
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('database-setup.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# ============================================================================
# UTILITY CLASSES AND FUNCTIONS
# ============================================================================

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    WHITE = '\033[1;37m'
    NC = '\033[0m'  # No Color

class DatabaseManager:
    """Main database management class"""
    
    def __init__(self, config: DatabaseConfig):
        self.config = config
        self.connections = {}
        
    def log_info(self, message: str):
        """Log info message with color"""
        print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}")
        logger.info(message)
        
    def log_success(self, message: str):
        """Log success message with color"""
        print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}")
        logger.info(message)
        
    def log_warning(self, message: str):
        """Log warning message with color"""
        print(f"{Colors.YELLOW}[WARNING]{Colors.NC} {message}")
        logger.warning(message)
        
    def log_error(self, message: str):
        """Log error message with color"""
        print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")
        logger.error(message)
        
    def log_header(self, message: str):
        """Log header message"""
        print(f"\n{Colors.PURPLE}{'='*80}{Colors.NC}")
        print(f"{Colors.WHITE}{message}{Colors.NC}")
        print(f"{Colors.PURPLE}{'='*80}{Colors.NC}\n")
        
    def get_connection(self, database: Optional[str] = None) -> mysql.connector.MySQLConnection:
        """Get database connection"""
        try:
            if K8S_ENABLED:
                return self._get_k8s_connection(database)
            else:
                return self._get_local_connection(database)
        except Exception as e:
            self.log_error(f"Failed to connect to database: {str(e)}")
            raise
            
    def _get_local_connection(self, database: Optional[str] = None) -> mysql.connector.MySQLConnection:
        """Get local database connection"""
        connection_config = {
            'host': self.config.host,
            'port': self.config.port,
            'user': 'root',
            'password': self.config.root_password,
            'autocommit': True
        }
        
        if database:
            connection_config['database'] = database
            
        return mysql.connector.connect(**connection_config)
        
    def _get_k8s_connection(self, database: Optional[str] = None) -> mysql.connector.MySQLConnection:
        """Get Kubernetes database connection via port-forward"""
        # This would implement K8s port-forwarding logic
        # For now, fallback to local connection
        return self._get_local_connection(database)
        
    def validate_connections(self) -> bool:
        """Validate all database connections"""
        self.log_header("🔍 VALIDATING DATABASE CONNECTIONS")
        
        try:
            # Test root connection
            self.log_info("Testing root connection...")
            conn = self.get_connection()
            cursor = conn.cursor()
            cursor.execute("SELECT VERSION()")
            version = cursor.fetchone()[0]
            self.log_success(f"✅ MySQL version: {version}")
            cursor.close()
            conn.close()
            
            # Test individual database connections
            for db_name in self.config.databases:
                self.log_info(f"Testing connection to {db_name}...")
                try:
                    conn = self.get_connection(db_name)
                    cursor = conn.cursor()
                    cursor.execute("SELECT DATABASE()")
                    current_db = cursor.fetchone()[0]
                    self.log_success(f"✅ Connected to {current_db}")
                    cursor.close()
                    conn.close()
                except mysql.connector.Error as e:
                    if e.errno == 1049:  # Database doesn't exist
                        self.log_warning(f"⚠️  Database {db_name} doesn't exist (will be created)")
                    else:
                        self.log_error(f"❌ Failed to connect to {db_name}: {str(e)}")
                        return False
                        
            self.log_success("All database connections validated successfully")
            return True
            
        except Exception as e:
            self.log_error(f"Connection validation failed: {str(e)}")
            return False
            
    def create_databases(self) -> bool:
        """Create all required databases"""
        self.log_header("🏗️ CREATING DATABASES")
        
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            for db_name in self.config.databases:
                self.log_info(f"Creating database {db_name}...")
                
                # Drop database if exists (for clean setup)
                cursor.execute(f"DROP DATABASE IF EXISTS {db_name}")
                self.log_info(f"Dropped existing {db_name} (if existed)")
                
                # Create database
                cursor.execute(f"CREATE DATABASE {db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
                self.log_success(f"✅ Created database {db_name}")
                
                # Create user and grant privileges
                cursor.execute(f"CREATE USER IF NOT EXISTS '{self.config.user}'@'%' IDENTIFIED BY '{self.config.password}'")
                cursor.execute(f"GRANT ALL PRIVILEGES ON {db_name}.* TO '{self.config.user}'@'%'")
                cursor.execute("FLUSH PRIVILEGES")
                self.log_success(f"✅ Granted privileges to {self.config.user} for {db_name}")
                
            cursor.close()
            conn.close()
            
            self.log_success("All databases created successfully")
            return True
            
        except Exception as e:
            self.log_error(f"Database creation failed: {str(e)}")
            return False
            
    def create_tables(self) -> bool:
        """Create tables for all databases"""
        self.log_header("📋 CREATING TABLES")
        
        # Customer database schema
        customer_schema = """
        CREATE TABLE IF NOT EXISTS owners (
            id INT AUTO_INCREMENT PRIMARY KEY,
            first_name VARCHAR(30) NOT NULL,
            last_name VARCHAR(30) NOT NULL,
            address VARCHAR(255),
            city VARCHAR(80),
            telephone VARCHAR(20),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
        
        CREATE TABLE IF NOT EXISTS pets (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(30) NOT NULL,
            birth_date DATE,
            type_id INT,
            owner_id INT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            FOREIGN KEY (owner_id) REFERENCES owners(id)
        );
        
        CREATE TABLE IF NOT EXISTS types (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(80) NOT NULL
        );
        
        ALTER TABLE pets ADD FOREIGN KEY (type_id) REFERENCES types(id);
        """
        
        # Vet database schema
        vet_schema = """
        CREATE TABLE IF NOT EXISTS vets (
            id INT AUTO_INCREMENT PRIMARY KEY,
            first_name VARCHAR(30) NOT NULL,
            last_name VARCHAR(30) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
        
        CREATE TABLE IF NOT EXISTS specialties (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(80) NOT NULL
        );
        
        CREATE TABLE IF NOT EXISTS vet_specialties (
            vet_id INT,
            specialty_id INT,
            PRIMARY KEY (vet_id, specialty_id),
            FOREIGN KEY (vet_id) REFERENCES vets(id),
            FOREIGN KEY (specialty_id) REFERENCES specialties(id)
        );
        """
        
        # Visit database schema
        visit_schema = """
        CREATE TABLE IF NOT EXISTS visits (
            id INT AUTO_INCREMENT PRIMARY KEY,
            pet_id INT NOT NULL,
            visit_date DATE,
            description TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
        """
        
        schemas = {
            'petclinic_customer': customer_schema,
            'petclinic_vet': vet_schema,
            'petclinic_visit': visit_schema
        }
        
        try:
            for db_name, schema in schemas.items():
                self.log_info(f"Creating tables for {db_name}...")
                conn = self.get_connection(db_name)
                cursor = conn.cursor()
                
                # Execute schema statements
                for statement in schema.split(';'):
                    statement = statement.strip()
                    if statement:
                        cursor.execute(statement)
                        
                cursor.close()
                conn.close()
                self.log_success(f"✅ Tables created for {db_name}")
                
            self.log_success("All tables created successfully")
            return True
            
        except Exception as e:
            self.log_error(f"Table creation failed: {str(e)}")
            return False
            
    def insert_sample_data(self) -> bool:
        """Insert sample data into all databases"""
        self.log_header("📊 INSERTING SAMPLE DATA")
        
        try:
            # Insert sample data for customer database
            self._insert_customer_sample_data()
            
            # Insert sample data for vet database
            self._insert_vet_sample_data()
            
            # Insert sample data for visit database
            self._insert_visit_sample_data()
            
            self.log_success("All sample data inserted successfully")
            return True
            
        except Exception as e:
            self.log_error(f"Sample data insertion failed: {str(e)}")
            return False
            
    def _insert_customer_sample_data(self):
        """Insert sample data for customer database"""
        self.log_info("Inserting customer sample data...")
        
        conn = self.get_connection('petclinic_customer')
        cursor = conn.cursor()
        
        # Insert pet types
        types_data = [
            ('cat',), ('dog',), ('lizard',), ('snake',), ('bird',), ('hamster',)
        ]
        cursor.executemany("INSERT INTO types (name) VALUES (%s)", types_data)
        
        # Insert owners
        owners_data = [
            ('George', 'Franklin', '110 W. Liberty St.', 'Madison', '6085551023'),
            ('Betty', 'Davis', '638 Cardinal Ave.', 'Sun Prairie', '6085551749'),
            ('Eduardo', 'Rodriquez', '2693 Commerce St.', 'McFarland', '6085558763'),
            ('Harold', 'Davis', '563 Friendly St.', 'Windsor', '6085553198'),
            ('Peter', 'McTavish', '2387 S. Fair Way', 'Madison', '6085552765'),
            ('Jean', 'Coleman', '105 N. Lake St.', 'Monona', '6085552654'),
            ('Jeff', 'Black', '1450 Oak Blvd.', 'Monona', '6085555387'),
            ('Maria', 'Escobito', '345 Maple St.', 'Madison', '6085557683'),
            ('David', 'Schroeder', '2749 Blackhawk Trail', 'Madison', '6085559435'),
            ('Carlos', 'Estaban', '2335 Independence La.', 'Waunakee', '6085555487')
        ]
        cursor.executemany(
            "INSERT INTO owners (first_name, last_name, address, city, telephone) VALUES (%s, %s, %s, %s, %s)",
            owners_data
        )
        
        # Insert pets
        pets_data = [
            ('Leo', '2010-09-07', 1, 1),
            ('Basil', '2012-08-06', 6, 2),
            ('Rosy', '2011-04-17', 2, 3),
            ('Jewel', '2010-03-07', 2, 3),
            ('Iggy', '2010-11-30', 3, 4),
            ('George', '2010-01-20', 4, 5),
            ('Samantha', '2012-09-04', 1, 6),
            ('Max', '2012-09-04', 1, 6),
            ('Lucky', '2011-08-06', 5, 7),
            ('Mulligan', '2007-02-24', 2, 8),
            ('Freddy', '2010-03-09', 5, 9),
            ('Lucky', '2010-06-24', 2, 10),
            ('Sly', '2012-06-08', 1, 10)
        ]
        cursor.executemany(
            "INSERT INTO pets (name, birth_date, type_id, owner_id) VALUES (%s, %s, %s, %s)",
            pets_data
        )
        
        cursor.close()
        conn.close()
        self.log_success("✅ Customer sample data inserted")
        
    def _insert_vet_sample_data(self):
        """Insert sample data for vet database"""
        self.log_info("Inserting vet sample data...")
        
        conn = self.get_connection('petclinic_vet')
        cursor = conn.cursor()
        
        # Insert specialties
        specialties_data = [
            ('radiology',), ('surgery',), ('dentistry',)
        ]
        cursor.executemany("INSERT INTO specialties (name) VALUES (%s)", specialties_data)
        
        # Insert vets
        vets_data = [
            ('James', 'Carter'),
            ('Helen', 'Leary'),
            ('Linda', 'Douglas'),
            ('Rafael', 'Ortega'),
            ('Henry', 'Stevens'),
            ('Sharon', 'Jenkins')
        ]
        cursor.executemany(
            "INSERT INTO vets (first_name, last_name) VALUES (%s, %s)",
            vets_data
        )
        
        # Insert vet specialties
        vet_specialties_data = [
            (2, 1),  # Helen Leary - radiology
            (3, 2),  # Linda Douglas - surgery
            (3, 3),  # Linda Douglas - dentistry
            (4, 2),  # Rafael Ortega - surgery
            (5, 1),  # Henry Stevens - radiology
        ]
        cursor.executemany(
            "INSERT INTO vet_specialties (vet_id, specialty_id) VALUES (%s, %s)",
            vet_specialties_data
        )
        
        cursor.close()
        conn.close()
        self.log_success("✅ Vet sample data inserted")
        
    def _insert_visit_sample_data(self):
        """Insert sample data for visit database"""
        self.log_info("Inserting visit sample data...")
        
        conn = self.get_connection('petclinic_visit')
        cursor = conn.cursor()
        
        # Insert visits
        visits_data = [
            (7, '2013-01-01', 'rabies shot'),
            (8, '2013-01-02', 'rabies shot'),
            (8, '2013-01-03', 'neutered'),
            (7, '2013-06-04', 'spayed')
        ]
        cursor.executemany(
            "INSERT INTO visits (pet_id, visit_date, description) VALUES (%s, %s, %s)",
            visits_data
        )
        
        cursor.close()
        conn.close()
        self.log_success("✅ Visit sample data inserted")
        
    def backup_databases(self, backup_dir: str = "/tmp/petclinic-backups") -> bool:
        """Create backup of all databases"""
        self.log_header("💾 CREATING DATABASE BACKUPS")
        
        try:
            # Create backup directory
            Path(backup_dir).mkdir(parents=True, exist_ok=True)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            
            for db_name in self.config.databases:
                self.log_info(f"Backing up {db_name}...")
                
                backup_file = f"{backup_dir}/{db_name}_{timestamp}.sql"
                
                # Use mysqldump to create backup
                cmd = [
                    'mysqldump',
                    f'--host={self.config.host}',
                    f'--port={self.config.port}',
                    f'--user=root',
                    f'--password={self.config.root_password}',
                    '--single-transaction',
                    '--routines',
                    '--triggers',
                    db_name
                ]
                
                with open(backup_file, 'w') as f:
                    result = subprocess.run(cmd, stdout=f, stderr=subprocess.PIPE, text=True)
                    
                if result.returncode == 0:
                    file_size = os.path.getsize(backup_file)
                    self.log_success(f"✅ {db_name} backed up to {backup_file} ({file_size} bytes)")
                else:
                    self.log_error(f"❌ Backup failed for {db_name}: {result.stderr}")
                    return False
                    
            self.log_success(f"All databases backed up to {backup_dir}")
            return True
            
        except Exception as e:
            self.log_error(f"Backup failed: {str(e)}")
            return False
            
    def restore_database(self, backup_file: str, database: str) -> bool:
        """Restore database from backup file"""
        self.log_header(f"🔄 RESTORING DATABASE {database}")
        
        try:
            if not os.path.exists(backup_file):
                self.log_error(f"Backup file not found: {backup_file}")
                return False
                
            self.log_info(f"Restoring {database} from {backup_file}...")
            
            # Use mysql to restore backup
            cmd = [
                'mysql',
                f'--host={self.config.host}',
                f'--port={self.config.port}',
                f'--user=root',
                f'--password={self.config.root_password}',
                database
            ]
            
            with open(backup_file, 'r') as f:
                result = subprocess.run(cmd, stdin=f, stderr=subprocess.PIPE, text=True)
                
            if result.returncode == 0:
                self.log_success(f"✅ {database} restored successfully")
                return True
            else:
                self.log_error(f"❌ Restore failed for {database}: {result.stderr}")
                return False
                
        except Exception as e:
            self.log_error(f"Restore failed: {str(e)}")
            return False
            
    def reset_databases(self) -> bool:
        """Reset all databases (drop and recreate)"""
        self.log_header("🔄 RESETTING ALL DATABASES")
        
        try:
            # Drop all databases
            conn = self.get_connection()
            cursor = conn.cursor()
            
            for db_name in self.config.databases:
                self.log_info(f"Dropping database {db_name}...")
                cursor.execute(f"DROP DATABASE IF EXISTS {db_name}")
                self.log_success(f"✅ Dropped {db_name}")
                
            cursor.close()
            conn.close()
            
            # Recreate databases
            if not self.create_databases():
                return False
                
            # Create tables
            if not self.create_tables():
                return False
                
            self.log_success("All databases reset successfully")
            return True
            
        except Exception as e:
            self.log_error(f"Database reset failed: {str(e)}")
            return False

# ============================================================================
# MAIN EXECUTION FUNCTIONS
# ============================================================================

def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(
        description='Spring PetClinic Database Setup Script',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python database-setup.py --validate              # Test connections
  python database-setup.py --init-clean           # Clean setup
  python database-setup.py --init-sample          # Setup with sample data
  python database-setup.py --backup               # Create backup
  python database-setup.py --restore backup.sql   # Restore from backup
  python database-setup.py --all                  # Complete setup
        """
    )
    
    parser.add_argument('--validate', action='store_true', help='Validate database connections')
    parser.add_argument('--init-clean', action='store_true', help='Initialize clean databases')
    parser.add_argument('--init-sample', action='store_true', help='Initialize with sample data')
    parser.add_argument('--backup', action='store_true', help='Create database backups')
    parser.add_argument('--restore', metavar='FILE', help='Restore from backup file')
    parser.add_argument('--reset', action='store_true', help='Reset all databases')
    parser.add_argument('--all', action='store_true', help='Complete setup (clean + sample data)')
    parser.add_argument('--config', metavar='FILE', help='Configuration file path')
    
    args = parser.parse_args()
    
    # Initialize database manager
    db_manager = DatabaseManager(DEFAULT_CONFIG)
    
    try:
        if args.validate:
            success = db_manager.validate_connections()
            sys.exit(0 if success else 1)
            
        elif args.init_clean:
            success = (
                db_manager.create_databases() and
                db_manager.create_tables()
            )
            sys.exit(0 if success else 1)
            
        elif args.init_sample:
            success = (
                db_manager.create_databases() and
                db_manager.create_tables() and
                db_manager.insert_sample_data()
            )
            sys.exit(0 if success else 1)
            
        elif args.backup:
            success = db_manager.backup_databases()
            sys.exit(0 if success else 1)
            
        elif args.restore:
            # For simplicity, restore to first database
            success = db_manager.restore_database(args.restore, DEFAULT_CONFIG.databases[0])
            sys.exit(0 if success else 1)
            
        elif args.reset:
            success = db_manager.reset_databases()
            sys.exit(0 if success else 1)
            
        elif args.all:
            success = (
                db_manager.validate_connections() and
                db_manager.create_databases() and
                db_manager.create_tables() and
                db_manager.insert_sample_data()
            )
            if success:
                db_manager.log_success("🎉 Complete database setup finished successfully!")
            sys.exit(0 if success else 1)
            
        else:
            parser.print_help()
            
    except KeyboardInterrupt:
        db_manager.log_warning("Operation cancelled by user")
        sys.exit(1)
    except Exception as e:
        db_manager.log_error(f"Unexpected error: {str(e)}")
        sys.exit(1)

if __name__ == '__main__':
    main()
