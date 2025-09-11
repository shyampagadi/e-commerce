# Module-04: Database Selection and Design - Exercises

## Overview

This directory contains hands-on exercises to reinforce the concepts covered in Module-04: Database Selection and Design. These exercises will help you practice database design, optimization, and implementation skills.

## Exercise Structure

Each exercise includes:
- **Objective**: What you'll learn and practice
- **Prerequisites**: Required knowledge and setup
- **Instructions**: Step-by-step guidance
- **Expected Outcomes**: What you should achieve
- **Solution**: Detailed solution with explanations

## Exercise List

### Exercise 1: Database Schema Design
**Objective**: Design a normalized database schema for a social media platform
**Difficulty**: Intermediate
**Duration**: 4-6 hours
**File**: [exercise-01-schema-design.md](exercise-01-schema-design.md)

### Exercise 2: Database Selection
**Objective**: Select appropriate database technologies for different use cases
**Difficulty**: Intermediate
**Duration**: 10-15 hours
**File**: [exercise-02-database-selection.md](exercise-02-database-selection.md)

### Exercise 3: Schema Design
**Objective**: Design schemas for multiple database types (RDBMS, Document, Key-Value, Column-Family, Graph)
**Difficulty**: Advanced
**Duration**: 15-20 hours
**File**: [exercise-03-schema-design.md](exercise-03-schema-design.md)

### Exercise 4: Performance Optimization
**Objective**: Optimize database performance through indexing, query optimization, and tuning
**Difficulty**: Advanced
**Duration**: 15-20 hours
**File**: [exercise-04-performance-optimization.md](exercise-04-performance-optimization.md)

### Exercise 5: Scalability and Availability
**Objective**: Design database systems for scalability and high availability
**Difficulty**: Expert
**Duration**: 17-22 hours
**File**: [exercise-05-scalability-and-availability.md](exercise-05-scalability-and-availability.md)

## Getting Started

### Prerequisites
- Basic knowledge of SQL and database concepts
- Understanding of NoSQL databases
- Familiarity with database design principles
- Access to database systems (PostgreSQL, MongoDB, Redis)

### Setup Instructions
1. **Install Required Software**:
   - PostgreSQL 13+
   - MongoDB 5.0+
   - Redis 6.0+
   - Elasticsearch 7.0+ (for advanced exercises)

2. **Create Exercise Database**:
   ```sql
   -- PostgreSQL
   CREATE DATABASE exercise_db;
   ```

3. **Set Up MongoDB Collections**:
   ```javascript
   // MongoDB
   use exercise_db
   ```

4. **Configure Redis**:
   ```bash
   # Start Redis server
   redis-server
   ```

### Running Exercises
1. Read the exercise instructions carefully
2. Set up the required database environment
3. Follow the step-by-step instructions
4. Test your solutions
5. Compare with the provided solutions
6. Reflect on what you learned

## Exercise Guidelines

### 1. Database Design
- Follow normalization principles (1NF, 2NF, 3NF)
- Consider denormalization for performance
- Design for scalability and performance
- Implement proper indexing strategies
- Consider data relationships and constraints

### 2. Query Optimization
- Use appropriate indexes
- Optimize query structure
- Consider query execution plans
- Test performance improvements
- Monitor query performance

### 3. NoSQL Modeling
- Design for access patterns
- Consider data relationships
- Optimize for read/write performance
- Plan for scalability
- Handle data consistency

### 4. Polyglot Persistence
- Choose appropriate databases for each use case
- Design data synchronization strategies
- Handle data consistency across databases
- Implement proper error handling
- Monitor data synchronization

## Assessment Criteria

### Technical Skills (40%)
- Correctness of database design
- Proper use of database features
- Query optimization techniques
- Data modeling best practices

### Problem-Solving (30%)
- Ability to analyze requirements
- Creative solutions to complex problems
- Trade-off analysis and decision making
- Error handling and edge cases

### Code Quality (20%)
- Clean and readable code
- Proper documentation
- Error handling
- Testing and validation

### Understanding (10%)
- Explanation of design decisions
- Understanding of trade-offs
- Knowledge of best practices
- Ability to explain concepts

## Resources

### Documentation
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Redis Documentation](https://redis.io/documentation)
- [Elasticsearch Documentation](https://www.elastic.co/guide/)

### Tools
- [pgAdmin](https://www.pgadmin.org/) - PostgreSQL administration
- [MongoDB Compass](https://www.mongodb.com/products/compass) - MongoDB GUI
- [RedisInsight](https://redis.com/redis-enterprise/redis-insight/) - Redis GUI
- [Kibana](https://www.elastic.co/kibana/) - Elasticsearch visualization

### Learning Resources
- [Database Design Best Practices](https://www.postgresql.org/docs/current/ddl.html)
- [NoSQL Data Modeling](https://docs.mongodb.com/manual/core/data-modeling-introduction/)
- [Query Optimization](https://www.postgresql.org/docs/current/performance-tips.html)
- [Polyglot Persistence](https://martinfowler.com/bliki/PolyglotPersistence.html)

## Support

If you encounter issues or have questions:
1. Check the exercise solutions
2. Review the module concepts
3. Consult the documentation
4. Ask for help in the discussion forum
5. Contact the course instructors

## Next Steps

After completing the exercises:
1. Review your solutions
2. Compare with best practices
3. Identify areas for improvement
4. Practice additional scenarios
5. Move on to the assessment

---

**Ready to start?** Begin with [Exercise 1: Database Schema Design](exercise-01-schema-design.md)!
