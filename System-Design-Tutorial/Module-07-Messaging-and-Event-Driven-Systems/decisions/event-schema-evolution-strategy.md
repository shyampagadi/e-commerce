# ADR-004: Event Schema Evolution Strategy

## Status
Accepted

## Context
As our event-driven system evolves, we need to modify event schemas while maintaining backward compatibility with existing consumers. Without a proper schema evolution strategy, we risk breaking existing integrations and losing the ability to process historical events.

### Key Challenges
- Multiple consumer services with different update cycles
- Need to process historical events with older schemas
- Schema changes must not break existing consumers
- Performance impact of schema validation and transformation
- Coordination between producer and consumer deployments

### Requirements
- Backward compatibility for at least 2 major versions
- Forward compatibility where possible
- Automated schema validation and registration
- Gradual rollout of schema changes
- Ability to replay events with different schema versions

## Decision
We will implement a comprehensive schema evolution strategy using Apache Avro with a centralized schema registry and versioning approach.

### Schema Evolution Approach
1. **Avro Schema Format**: Use Apache Avro for all event schemas
2. **Schema Registry**: Implement centralized schema registry with AWS Glue Schema Registry
3. **Versioning Strategy**: Semantic versioning (MAJOR.MINOR.PATCH) for schemas
4. **Compatibility Rules**: Enforce backward and forward compatibility rules
5. **Migration Path**: Automated schema migration and transformation

### Implementation Components

#### 1. Schema Registry Setup
```python
import boto3
from avro import schema, io
import json

class SchemaRegistry:
    def __init__(self, registry_name: str = 'messaging-schema-registry'):
        self.glue_client = boto3.client('glue')
        self.registry_name = registry_name
        
    def register_schema(self, schema_name: str, schema_definition: str, 
                       compatibility: str = 'BACKWARD') -> str:
        """Register new schema version"""
        try:
            response = self.glue_client.register_schema_version(
                SchemaId={
                    'SchemaName': schema_name,
                    'RegistryName': self.registry_name
                },
                SchemaDefinition=schema_definition
            )
            
            return response['SchemaVersionId']
            
        except self.glue_client.exceptions.EntityNotFoundException:
            # Create schema if it doesn't exist
            self.glue_client.create_schema(
                RegistryId={'RegistryName': self.registry_name},
                SchemaName=schema_name,
                DataFormat='AVRO',
                Compatibility=compatibility,
                SchemaDefinition=schema_definition
            )
            
            return self.register_schema(schema_name, schema_definition, compatibility)
    
    def get_schema(self, schema_name: str, version: str = 'LATEST') -> dict:
        """Get schema by name and version"""
        response = self.glue_client.get_schema_version(
            SchemaId={
                'SchemaName': schema_name,
                'RegistryName': self.registry_name
            },
            SchemaVersionNumber={'VersionNumber': version} if version != 'LATEST' else {}
        )
        
        return {
            'schema_definition': response['SchemaDefinition'],
            'version_id': response['SchemaVersionId'],
            'version_number': response['VersionNumber']
        }
```

#### 2. Schema Evolution Rules
```json
{
  "compatibility_rules": {
    "BACKWARD": {
      "allowed_changes": [
        "add_optional_field",
        "remove_field",
        "add_enum_value",
        "widen_type"
      ],
      "forbidden_changes": [
        "remove_required_field",
        "change_field_type",
        "remove_enum_value",
        "change_field_name"
      ]
    },
    "FORWARD": {
      "allowed_changes": [
        "add_required_field_with_default",
        "remove_optional_field",
        "narrow_type"
      ]
    },
    "FULL": {
      "description": "Both backward and forward compatible"
    }
  }
}
```

#### 3. Event Schema Versioning
```python
# Base Event Schema v1.0.0
ORDER_CREATED_SCHEMA_V1 = """
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "com.ecommerce.events",
  "fields": [
    {"name": "eventId", "type": "string"},
    {"name": "orderId", "type": "string"},
    {"name": "customerId", "type": "string"},
    {"name": "totalAmount", "type": "double"},
    {"name": "currency", "type": "string", "default": "USD"},
    {"name": "timestamp", "type": "long", "logicalType": "timestamp-millis"},
    {"name": "version", "type": "string", "default": "1.0.0"}
  ]
}
"""

# Enhanced Event Schema v1.1.0 (Backward Compatible)
ORDER_CREATED_SCHEMA_V1_1 = """
{
  "type": "record",
  "name": "OrderCreated",
  "namespace": "com.ecommerce.events",
  "fields": [
    {"name": "eventId", "type": "string"},
    {"name": "orderId", "type": "string"},
    {"name": "customerId", "type": "string"},
    {"name": "totalAmount", "type": "double"},
    {"name": "currency", "type": "string", "default": "USD"},
    {"name": "timestamp", "type": "long", "logicalType": "timestamp-millis"},
    {"name": "version", "type": "string", "default": "1.1.0"},
    {"name": "paymentMethod", "type": ["null", "string"], "default": null},
    {"name": "shippingAddress", "type": ["null", {
      "type": "record",
      "name": "Address",
      "fields": [
        {"name": "street", "type": "string"},
        {"name": "city", "type": "string"},
        {"name": "country", "type": "string"},
        {"name": "postalCode", "type": "string"}
      ]
    }], "default": null}
  ]
}
"""

class SchemaEvolutionManager:
    def __init__(self):
        self.schema_registry = SchemaRegistry()
        self.schema_cache = {}
        
    def validate_schema_evolution(self, old_schema: str, new_schema: str) -> dict:
        """Validate schema evolution compatibility"""
        try:
            old_avro_schema = schema.parse(old_schema)
            new_avro_schema = schema.parse(new_schema)
            
            # Check backward compatibility
            backward_compatible = self._check_backward_compatibility(
                old_avro_schema, new_avro_schema
            )
            
            # Check forward compatibility
            forward_compatible = self._check_forward_compatibility(
                old_avro_schema, new_avro_schema
            )
            
            return {
                'backward_compatible': backward_compatible,
                'forward_compatible': forward_compatible,
                'full_compatible': backward_compatible and forward_compatible,
                'changes': self._analyze_schema_changes(old_avro_schema, new_avro_schema)
            }
            
        except Exception as e:
            return {
                'error': str(e),
                'backward_compatible': False,
                'forward_compatible': False
            }
    
    def _check_backward_compatibility(self, old_schema, new_schema) -> bool:
        """Check if new schema can read data written with old schema"""
        try:
            # Create sample data with old schema
            sample_data = self._generate_sample_data(old_schema)
            
            # Try to read with new schema
            writer = io.DatumWriter(old_schema)
            reader = io.DatumReader(old_schema, new_schema)
            
            # Serialize with old schema
            bytes_writer = io.BytesIO()
            encoder = io.BinaryEncoder(bytes_writer)
            writer.write(sample_data, encoder)
            
            # Deserialize with new schema
            bytes_reader = io.BytesIO(bytes_writer.getvalue())
            decoder = io.BinaryDecoder(bytes_reader)
            reader.read(decoder)
            
            return True
            
        except Exception:
            return False
    
    def _check_forward_compatibility(self, old_schema, new_schema) -> bool:
        """Check if old schema can read data written with new schema"""
        try:
            # Create sample data with new schema
            sample_data = self._generate_sample_data(new_schema)
            
            # Try to read with old schema
            writer = io.DatumWriter(new_schema)
            reader = io.DatumReader(new_schema, old_schema)
            
            # Serialize with new schema
            bytes_writer = io.BytesIO()
            encoder = io.BinaryEncoder(bytes_writer)
            writer.write(sample_data, encoder)
            
            # Deserialize with old schema
            bytes_reader = io.BytesIO(bytes_writer.getvalue())
            decoder = io.BinaryDecoder(bytes_reader)
            reader.read(decoder)
            
            return True
            
        except Exception:
            return False
```

#### 4. Event Transformation Pipeline
```python
class EventTransformer:
    def __init__(self):
        self.transformation_rules = {}
        
    def register_transformation(self, from_version: str, to_version: str, 
                              transform_func):
        """Register transformation function between schema versions"""
        key = f"{from_version}->{to_version}"
        self.transformation_rules[key] = transform_func
    
    def transform_event(self, event_data: dict, from_version: str, 
                       to_version: str) -> dict:
        """Transform event from one schema version to another"""
        if from_version == to_version:
            return event_data
        
        # Direct transformation
        direct_key = f"{from_version}->{to_version}"
        if direct_key in self.transformation_rules:
            return self.transformation_rules[direct_key](event_data)
        
        # Multi-step transformation (find path)
        transformation_path = self._find_transformation_path(from_version, to_version)
        
        current_data = event_data
        current_version = from_version
        
        for next_version in transformation_path:
            transform_key = f"{current_version}->{next_version}"
            if transform_key in self.transformation_rules:
                current_data = self.transformation_rules[transform_key](current_data)
                current_version = next_version
            else:
                raise ValueError(f"No transformation rule found for {transform_key}")
        
        return current_data
    
    def _find_transformation_path(self, from_version: str, to_version: str) -> list:
        """Find transformation path between versions"""
        # Simple implementation - in practice, use graph algorithms
        available_versions = ['1.0.0', '1.1.0', '1.2.0', '2.0.0']
        
        from_idx = available_versions.index(from_version)
        to_idx = available_versions.index(to_version)
        
        if from_idx < to_idx:
            return available_versions[from_idx + 1:to_idx + 1]
        else:
            return list(reversed(available_versions[to_idx:from_idx]))

# Example transformation functions
def transform_v1_0_to_v1_1(event_data: dict) -> dict:
    """Transform OrderCreated from v1.0 to v1.1"""
    transformed = event_data.copy()
    
    # Add new optional fields with defaults
    transformed['paymentMethod'] = None
    transformed['shippingAddress'] = None
    transformed['version'] = '1.1.0'
    
    return transformed

def transform_v1_1_to_v1_0(event_data: dict) -> dict:
    """Transform OrderCreated from v1.1 to v1.0 (backward)"""
    transformed = event_data.copy()
    
    # Remove fields not present in v1.0
    transformed.pop('paymentMethod', None)
    transformed.pop('shippingAddress', None)
    transformed['version'] = '1.0.0'
    
    return transformed
```

#### 5. Schema Migration Workflow
```python
class SchemaMigrationWorkflow:
    def __init__(self):
        self.schema_registry = SchemaRegistry()
        self.transformer = EventTransformer()
        
    def deploy_new_schema_version(self, schema_name: str, new_schema: str, 
                                 migration_strategy: str = 'gradual') -> dict:
        """Deploy new schema version with migration strategy"""
        try:
            # Get current schema
            current_schema_info = self.schema_registry.get_schema(schema_name)
            current_schema = current_schema_info['schema_definition']
            
            # Validate compatibility
            compatibility_check = SchemaEvolutionManager().validate_schema_evolution(
                current_schema, new_schema
            )
            
            if not compatibility_check['backward_compatible']:
                return {
                    'success': False,
                    'error': 'New schema is not backward compatible',
                    'details': compatibility_check
                }
            
            # Register new schema version
            new_version_id = self.schema_registry.register_schema(
                schema_name, new_schema
            )
            
            # Execute migration strategy
            if migration_strategy == 'gradual':
                return self._execute_gradual_migration(schema_name, new_version_id)
            elif migration_strategy == 'immediate':
                return self._execute_immediate_migration(schema_name, new_version_id)
            else:
                return {'success': False, 'error': 'Unknown migration strategy'}
                
        except Exception as e:
            return {'success': False, 'error': str(e)}
    
    def _execute_gradual_migration(self, schema_name: str, new_version_id: str) -> dict:
        """Execute gradual migration with canary deployment"""
        steps = [
            "Register new schema version",
            "Deploy consumers with dual schema support",
            "Gradually migrate producers to new schema",
            "Monitor compatibility and performance",
            "Complete migration when all services updated"
        ]
        
        return {
            'success': True,
            'migration_type': 'gradual',
            'new_version_id': new_version_id,
            'steps': steps,
            'estimated_duration': '2-4 weeks'
        }
    
    def _execute_immediate_migration(self, schema_name: str, new_version_id: str) -> dict:
        """Execute immediate migration (for backward compatible changes)"""
        return {
            'success': True,
            'migration_type': 'immediate',
            'new_version_id': new_version_id,
            'action': 'Schema updated immediately - consumers will adapt automatically'
        }
```

### Migration Timeline
1. **Week 1**: Deploy schema registry and versioning infrastructure
2. **Week 2**: Implement transformation pipeline and validation
3. **Week 3**: Migrate existing schemas to registry
4. **Week 4**: Deploy gradual migration workflow
5. **Ongoing**: Monitor and optimize schema evolution process

## Consequences

### Positive
- **Backward Compatibility**: Existing consumers continue working during schema updates
- **Controlled Evolution**: Systematic approach to schema changes with validation
- **Automated Validation**: Prevents incompatible schema changes from being deployed
- **Historical Data**: Ability to process events with any schema version
- **Gradual Migration**: Reduces risk through controlled rollout

### Negative
- **Complexity**: Additional infrastructure and tooling required
- **Performance Overhead**: Schema validation and transformation add latency
- **Storage Overhead**: Multiple schema versions stored in registry
- **Development Overhead**: Developers must consider compatibility in schema changes

### Risks and Mitigations
- **Schema Registry Availability**: Implement high availability and caching
- **Transformation Errors**: Comprehensive testing of transformation functions
- **Version Conflicts**: Clear versioning strategy and governance process
- **Performance Impact**: Monitor and optimize transformation performance

## Implementation Plan
1. Set up AWS Glue Schema Registry
2. Implement schema validation and compatibility checking
3. Create transformation pipeline for version migration
4. Deploy gradual migration workflow
5. Migrate existing event schemas to registry
6. Train development teams on schema evolution best practices

This strategy ensures our event-driven system can evolve safely while maintaining compatibility with existing consumers and historical data.
