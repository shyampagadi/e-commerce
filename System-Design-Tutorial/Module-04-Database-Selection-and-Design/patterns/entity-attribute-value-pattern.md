# Entity-Attribute-Value (EAV) Pattern

## Pattern Overview

### Name
Entity-Attribute-Value (EAV) Pattern

### Intent
The EAV pattern provides a flexible schema design that allows entities to have dynamic attributes without requiring schema changes. It's particularly useful when dealing with entities that have varying attributes or when the attribute set is not known at design time.

### Context
Use the EAV pattern when:
- Entities have varying attributes that are not known at design time
- You need to support user-defined attributes
- The attribute set changes frequently
- You want to avoid schema changes for new attributes
- You're building a content management system or product catalog

### Forces
- **Flexibility vs. Performance**: EAV provides maximum flexibility but can impact query performance
- **Schema Simplicity vs. Query Complexity**: Simpler schema but more complex queries
- **Storage Efficiency vs. Query Efficiency**: More storage efficient but less query efficient
- **Maintenance vs. Performance**: Easier to maintain but harder to optimize

## Problem Statement

### Description
Traditional relational database design requires defining all attributes at schema creation time. This becomes problematic when:
- Different entities have different attributes
- New attributes need to be added frequently
- The attribute set is not known in advance
- You want to avoid schema migrations

### Symptoms
- Frequent schema changes required
- Complex inheritance hierarchies
- Difficulty adding new attributes
- Performance issues with polymorphic queries
- Maintenance overhead for schema changes

### Consequences
- **Schema Rigidity**: Difficult to add new attributes without schema changes
- **Performance Issues**: Complex queries and poor performance
- **Maintenance Overhead**: Frequent schema migrations
- **Data Integrity**: Difficult to enforce constraints
- **Query Complexity**: Complex queries for simple operations

### Examples
- **E-commerce Product Catalog**: Products have different attributes (size, color, weight, etc.)
- **User Profiles**: Users have varying profile attributes
- **Content Management**: Content types with different metadata
- **Configuration Management**: System configurations with varying parameters

## Solution

### Structure
The EAV pattern consists of three main tables:
1. **Entities Table**: Stores the main entities
2. **Attributes Table**: Defines the available attributes
3. **Values Table**: Stores the actual attribute values

### Participants
- **Entity**: The main entity being described
- **Attribute**: A property or characteristic of the entity
- **Value**: The actual value of the attribute for a specific entity

### Collaborations
- Entities have multiple attribute-value pairs
- Attributes can be shared across multiple entities
- Values are specific to entity-attribute combinations

### Implementation
```sql
-- Entities table
CREATE TABLE entities (
    entity_id INT PRIMARY KEY AUTO_INCREMENT,
    entity_type VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_entity_type (entity_type)
);

-- Attributes table
CREATE TABLE attributes (
    attribute_id INT PRIMARY KEY AUTO_INCREMENT,
    attribute_name VARCHAR(100) NOT NULL UNIQUE,
    attribute_type ENUM('string', 'number', 'boolean', 'date', 'text') NOT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    default_value TEXT,
    validation_rules JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Values table
CREATE TABLE entity_values (
    value_id INT PRIMARY KEY AUTO_INCREMENT,
    entity_id INT NOT NULL,
    attribute_id INT NOT NULL,
    value_text TEXT,
    value_number DECIMAL(15,4),
    value_boolean BOOLEAN,
    value_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES attributes(attribute_id) ON DELETE CASCADE,
    UNIQUE KEY uk_entity_attribute (entity_id, attribute_id),
    INDEX idx_entity_id (entity_id),
    INDEX idx_attribute_id (attribute_id),
    INDEX idx_value_text (value_text(100)),
    INDEX idx_value_number (value_number),
    INDEX idx_value_boolean (value_boolean),
    INDEX idx_value_date (value_date)
);
```

## Implementation Details

### Basic Operations

#### Creating Entities
```python
class EAVManager:
    def __init__(self, db_connection):
        self.db = db_connection
    
    def create_entity(self, entity_type, name, attributes=None):
        """Create a new entity with optional attributes"""
        cursor = self.db.cursor()
        
        # Create entity
        cursor.execute(
            "INSERT INTO entities (entity_type, name) VALUES (%s, %s)",
            (entity_type, name)
        )
        entity_id = cursor.lastrowid
        
        # Add attributes if provided
        if attributes:
            for attr_name, value in attributes.items():
                self.set_attribute(entity_id, attr_name, value)
        
        self.db.commit()
        return entity_id
    
    def set_attribute(self, entity_id, attribute_name, value):
        """Set an attribute value for an entity"""
        cursor = self.db.cursor()
        
        # Get or create attribute
        attribute_id = self._get_or_create_attribute(attribute_name, type(value).__name__)
        
        # Set value
        cursor.execute(
            """
            INSERT INTO entity_values (entity_id, attribute_id, value_text, value_number, value_boolean, value_date)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                value_text = VALUES(value_text),
                value_number = VALUES(value_number),
                value_boolean = VALUES(value_boolean),
                value_date = VALUES(value_date),
                updated_at = CURRENT_TIMESTAMP
            """,
            (entity_id, attribute_id, value if isinstance(value, str) else None,
             value if isinstance(value, (int, float)) else None,
             value if isinstance(value, bool) else None,
             value if isinstance(value, datetime) else None)
        )
        
        self.db.commit()
    
    def get_attribute(self, entity_id, attribute_name):
        """Get an attribute value for an entity"""
        cursor = self.db.cursor()
        
        cursor.execute(
            """
            SELECT ev.value_text, ev.value_number, ev.value_boolean, ev.value_date, a.attribute_type
            FROM entity_values ev
            JOIN attributes a ON ev.attribute_id = a.attribute_id
            WHERE ev.entity_id = %s AND a.attribute_name = %s
            """,
            (entity_id, attribute_name)
        )
        
        result = cursor.fetchone()
        if result:
            value_text, value_number, value_boolean, value_date, attribute_type = result
            
            # Return value based on type
            if attribute_type == 'string' or attribute_type == 'text':
                return value_text
            elif attribute_type == 'number':
                return value_number
            elif attribute_type == 'boolean':
                return value_boolean
            elif attribute_type == 'date':
                return value_date
        
        return None
    
    def get_entity_attributes(self, entity_id):
        """Get all attributes for an entity"""
        cursor = self.db.cursor()
        
        cursor.execute(
            """
            SELECT a.attribute_name, ev.value_text, ev.value_number, ev.value_boolean, ev.value_date, a.attribute_type
            FROM entity_values ev
            JOIN attributes a ON ev.attribute_id = a.attribute_id
            WHERE ev.entity_id = %s
            """,
            (entity_id,)
        )
        
        attributes = {}
        for row in cursor.fetchall():
            attr_name, value_text, value_number, value_boolean, value_date, attribute_type = row
            
            # Get value based on type
            if attribute_type == 'string' or attribute_type == 'text':
                value = value_text
            elif attribute_type == 'number':
                value = value_number
            elif attribute_type == 'boolean':
                value = value_boolean
            elif attribute_type == 'date':
                value = value_date
            
            attributes[attr_name] = value
        
        return attributes
    
    def _get_or_create_attribute(self, attribute_name, value_type):
        """Get or create an attribute definition"""
        cursor = self.db.cursor()
        
        # Try to get existing attribute
        cursor.execute(
            "SELECT attribute_id FROM attributes WHERE attribute_name = %s",
            (attribute_name,)
        )
        
        result = cursor.fetchone()
        if result:
            return result[0]
        
        # Create new attribute
        cursor.execute(
            "INSERT INTO attributes (attribute_name, attribute_type) VALUES (%s, %s)",
            (attribute_name, value_type)
        )
        
        return cursor.lastrowid
```

#### Querying Entities
```python
def find_entities_by_attribute(self, attribute_name, value):
    """Find entities by attribute value"""
    cursor = self.db.cursor()
    
    # Get attribute ID
    cursor.execute(
        "SELECT attribute_id, attribute_type FROM attributes WHERE attribute_name = %s",
        (attribute_name,)
    )
    
    result = cursor.fetchone()
    if not result:
        return []
    
    attribute_id, attribute_type = result
    
    # Build query based on attribute type
    if attribute_type == 'string' or attribute_type == 'text':
        cursor.execute(
            """
            SELECT e.entity_id, e.entity_type, e.name
            FROM entities e
            JOIN entity_values ev ON e.entity_id = ev.entity_id
            WHERE ev.attribute_id = %s AND ev.value_text = %s
            """,
            (attribute_id, value)
        )
    elif attribute_type == 'number':
        cursor.execute(
            """
            SELECT e.entity_id, e.entity_type, e.name
            FROM entities e
            JOIN entity_values ev ON e.entity_id = ev.entity_id
            WHERE ev.attribute_id = %s AND ev.value_number = %s
            """,
            (attribute_id, value)
        )
    elif attribute_type == 'boolean':
        cursor.execute(
            """
            SELECT e.entity_id, e.entity_type, e.name
            FROM entities e
            JOIN entity_values ev ON e.entity_id = ev.entity_id
            WHERE ev.attribute_id = %s AND ev.value_boolean = %s
            """,
            (attribute_id, value)
        )
    elif attribute_type == 'date':
        cursor.execute(
            """
            SELECT e.entity_id, e.entity_type, e.name
            FROM entities e
            JOIN entity_values ev ON e.entity_id = ev.entity_id
            WHERE ev.attribute_id = %s AND ev.value_date = %s
            """,
            (attribute_id, value)
        )
    
    return cursor.fetchall()

def find_entities_by_multiple_attributes(self, attribute_filters):
    """Find entities by multiple attribute values"""
    cursor = self.db.cursor()
    
    # Build dynamic query
    joins = []
    conditions = []
    params = []
    
    for i, (attr_name, value) in enumerate(attribute_filters.items()):
        alias = f"ev{i}"
        joins.append(f"JOIN entity_values {alias} ON e.entity_id = {alias}.entity_id")
        joins.append(f"JOIN attributes a{i} ON {alias}.attribute_id = a{i}.attribute_id")
        conditions.append(f"a{i}.attribute_name = %s AND {alias}.value_text = %s")
        params.extend([attr_name, value])
    
    query = f"""
        SELECT DISTINCT e.entity_id, e.entity_type, e.name
        FROM entities e
        {' '.join(joins)}
        WHERE {' AND '.join(conditions)}
    """
    
    cursor.execute(query, params)
    return cursor.fetchall()
```

### Advanced Operations

#### Bulk Operations
```python
def bulk_set_attributes(self, entity_id, attributes):
    """Set multiple attributes for an entity efficiently"""
    cursor = self.db.cursor()
    
    # Get all attribute IDs
    attribute_names = list(attributes.keys())
    placeholders = ','.join(['%s'] * len(attribute_names))
    
    cursor.execute(
        f"SELECT attribute_id, attribute_name FROM attributes WHERE attribute_name IN ({placeholders})",
        attribute_names
    )
    
    attribute_map = {name: attr_id for attr_id, name in cursor.fetchall()}
    
    # Prepare bulk insert
    values = []
    for attr_name, value in attributes.items():
        if attr_name in attribute_map:
            attribute_id = attribute_map[attr_name]
            values.append((entity_id, attribute_id, value))
    
    if values:
        cursor.executemany(
            """
            INSERT INTO entity_values (entity_id, attribute_id, value_text)
            VALUES (%s, %s, %s)
            ON DUPLICATE KEY UPDATE
                value_text = VALUES(value_text),
                updated_at = CURRENT_TIMESTAMP
            """,
            values
        )
        
        self.db.commit()

def bulk_get_entities(self, entity_ids):
    """Get multiple entities with their attributes efficiently"""
    cursor = self.db.cursor()
    
    placeholders = ','.join(['%s'] * len(entity_ids))
    
    cursor.execute(
        f"""
        SELECT e.entity_id, e.entity_type, e.name, a.attribute_name, ev.value_text
        FROM entities e
        LEFT JOIN entity_values ev ON e.entity_id = ev.entity_id
        LEFT JOIN attributes a ON ev.attribute_id = a.attribute_id
        WHERE e.entity_id IN ({placeholders})
        ORDER BY e.entity_id, a.attribute_name
        """,
        entity_ids
    )
    
    entities = {}
    for row in cursor.fetchall():
        entity_id, entity_type, name, attr_name, value = row
        
        if entity_id not in entities:
            entities[entity_id] = {
                'entity_id': entity_id,
                'entity_type': entity_type,
                'name': name,
                'attributes': {}
            }
        
        if attr_name and value:
            entities[entity_id]['attributes'][attr_name] = value
    
    return list(entities.values())
```

#### Performance Optimization
```python
def create_optimized_indexes(self):
    """Create optimized indexes for EAV queries"""
    cursor = self.db.cursor()
    
    # Create composite indexes for common query patterns
    indexes = [
        "CREATE INDEX idx_entity_type_name ON entities (entity_type, name)",
        "CREATE INDEX idx_attribute_name_type ON attributes (attribute_name, attribute_type)",
        "CREATE INDEX idx_entity_attribute_value ON entity_values (entity_id, attribute_id, value_text)",
        "CREATE INDEX idx_value_text_search ON entity_values (value_text(100))",
        "CREATE INDEX idx_value_number_search ON entity_values (value_number)",
        "CREATE INDEX idx_value_boolean_search ON entity_values (value_boolean)",
        "CREATE INDEX idx_value_date_search ON entity_values (value_date)"
    ]
    
    for index_sql in indexes:
        try:
            cursor.execute(index_sql)
            print(f"Created index: {index_sql}")
        except Exception as e:
            print(f"Error creating index: {e}")
    
    self.db.commit()

def optimize_eav_queries(self):
    """Optimize common EAV queries"""
    cursor = self.db.cursor()
    
    # Create materialized view for common queries
    cursor.execute("""
        CREATE VIEW entity_attribute_summary AS
        SELECT 
            e.entity_id,
            e.entity_type,
            e.name,
            GROUP_CONCAT(
                CONCAT(a.attribute_name, ':', ev.value_text)
                ORDER BY a.attribute_name
                SEPARATOR '|'
            ) as attributes
        FROM entities e
        LEFT JOIN entity_values ev ON e.entity_id = ev.entity_id
        LEFT JOIN attributes a ON ev.attribute_id = a.attribute_id
        GROUP BY e.entity_id, e.entity_type, e.name
    """)
    
    self.db.commit()
```

## Consequences

### Benefits
- **Flexibility**: Easy to add new attributes without schema changes
- **Schema Simplicity**: Simple, consistent schema structure
- **Storage Efficiency**: Only stores attributes that have values
- **Maintainability**: Easier to maintain and evolve
- **User-Defined Attributes**: Support for user-defined attributes

### Liabilities
- **Query Complexity**: More complex queries for simple operations
- **Performance Issues**: Can be slower than traditional schemas
- **Data Integrity**: Difficult to enforce constraints
- **Storage Overhead**: Additional storage for metadata
- **Learning Curve**: Steeper learning curve for developers

### Trade-offs
- **Flexibility vs. Performance**: Maximum flexibility at the cost of performance
- **Schema Simplicity vs. Query Complexity**: Simpler schema but more complex queries
- **Storage Efficiency vs. Query Efficiency**: More storage efficient but less query efficient
- **Maintenance vs. Performance**: Easier to maintain but harder to optimize

### Alternatives
- **JSON Columns**: Store attributes as JSON in a single column
- **Polymorphic Tables**: Use inheritance with separate tables
- **Key-Value Stores**: Use NoSQL databases for flexible schemas
- **Hybrid Approach**: Combine EAV with traditional columns

## Related Patterns

### Similar Patterns
- **Polymorphic Association Pattern**: Handling multiple entity types
- **Audit Trail Pattern**: Tracking changes over time
- **Soft Delete Pattern**: Marking records as deleted
- **Versioning Pattern**: Maintaining multiple versions

### Complementary Patterns
- **Caching Pattern**: Cache frequently accessed EAV data
- **Indexing Pattern**: Optimize EAV queries with proper indexes
- **Partitioning Pattern**: Partition EAV tables for better performance
- **Materialized View Pattern**: Pre-compute common EAV queries

### Conflicting Patterns
- **Normalized Schema Pattern**: Traditional normalized schemas
- **Denormalized Schema Pattern**: Denormalized schemas for performance
- **Star Schema Pattern**: Data warehouse schemas

### Evolution
- **EAV to JSON**: Migrate from EAV to JSON columns
- **EAV to NoSQL**: Move to NoSQL databases
- **Hybrid EAV**: Combine EAV with traditional columns
- **EAV with Constraints**: Add validation and constraints

## Best Practices

### Design
- **Use Sparingly**: Only use EAV when necessary
- **Plan for Performance**: Design with performance in mind
- **Add Constraints**: Implement validation where possible
- **Document Well**: Clear documentation is essential

### Implementation
- **Optimize Queries**: Use proper indexes and query optimization
- **Cache Frequently**: Cache frequently accessed data
- **Monitor Performance**: Track query performance
- **Test Thoroughly**: Comprehensive testing is critical

### Maintenance
- **Regular Review**: Periodically review EAV usage
- **Performance Tuning**: Continuously optimize performance
- **Data Cleanup**: Regular cleanup of unused attributes
- **Documentation Updates**: Keep documentation current

## Conclusion

The Entity-Attribute-Value pattern provides a flexible solution for handling dynamic attributes in relational databases. While it offers maximum flexibility, it comes with performance trade-offs that must be carefully considered.

Use EAV when:
- You need maximum flexibility for attributes
- The attribute set changes frequently
- You want to avoid schema migrations
- You're building content management or catalog systems

Avoid EAV when:
- Performance is critical
- You have a stable, well-defined schema
- You need complex queries and reporting
- You want to leverage database-specific features

The key is to understand the trade-offs and use EAV judiciously, combining it with other patterns and optimizations to achieve the right balance between flexibility and performance.

