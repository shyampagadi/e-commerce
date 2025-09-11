# Database Normalization: From 1NF to 6NF

## Overview

Database normalization is a systematic approach to organizing data in a database to eliminate redundancy and improve data integrity. This process involves decomposing tables into smaller, more manageable structures while maintaining data relationships and ensuring data consistency.

## 1. First Normal Form (1NF)

### Definition
A table is in 1NF if:
- All columns contain atomic (indivisible) values
- Each column contains values of the same data type
- Each row is unique
- The order of columns doesn't matter

### Example: Violation of 1NF
```sql
-- BAD: Violates 1NF
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    courses VARCHAR(500)  -- Contains multiple values: "Math, Science, English"
);

-- Data example
INSERT INTO students VALUES 
(1, 'John Doe', 'Math, Science, English'),
(2, 'Jane Smith', 'Math, History');
```

### Example: Corrected to 1NF
```sql
-- GOOD: 1NF compliant
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100)
);

CREATE TABLE student_courses (
    student_id INT,
    course_name VARCHAR(100),
    PRIMARY KEY (student_id, course_name),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);

-- Data example
INSERT INTO students VALUES 
(1, 'John Doe'),
(2, 'Jane Smith');

INSERT INTO student_courses VALUES 
(1, 'Math'),
(1, 'Science'),
(1, 'English'),
(2, 'Math'),
(2, 'History');
```

### Benefits of 1NF
- Eliminates repeating groups
- Ensures atomic values
- Simplifies data manipulation
- Reduces storage space

## 2. Second Normal Form (2NF)

### Definition
A table is in 2NF if:
- It's in 1NF
- All non-key attributes are fully functionally dependent on the primary key
- No partial dependencies exist

### Example: Violation of 2NF
```sql
-- BAD: Violates 2NF (partial dependency)
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    product_name VARCHAR(100),  -- Depends only on product_id
    quantity INT,
    unit_price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id)
);
```

### Example: Corrected to 2NF
```sql
-- GOOD: 2NF compliant
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    unit_price DECIMAL(10,2)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
```

### Benefits of 2NF
- Eliminates partial dependencies
- Reduces data redundancy
- Improves data consistency
- Simplifies updates

## 3. Third Normal Form (3NF)

### Definition
A table is in 3NF if:
- It's in 2NF
- No transitive dependencies exist
- All non-key attributes are directly dependent on the primary key

### Example: Violation of 3NF
```sql
-- BAD: Violates 3NF (transitive dependency)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    department_name VARCHAR(100),  -- Depends on department_id, not employee_id
    department_location VARCHAR(100)
);
```

### Example: Corrected to 3NF
```sql
-- GOOD: 3NF compliant
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    department_location VARCHAR(100)
);
```

### Benefits of 3NF
- Eliminates transitive dependencies
- Further reduces redundancy
- Improves data integrity
- Simplifies maintenance

## 4. Boyce-Codd Normal Form (BCNF)

### Definition
A table is in BCNF if:
- It's in 3NF
- Every determinant is a candidate key
- No overlapping candidate keys exist

### Example: Violation of BCNF
```sql
-- BAD: Violates BCNF
CREATE TABLE course_instructors (
    course_id INT,
    instructor_id INT,
    instructor_name VARCHAR(100),
    PRIMARY KEY (course_id, instructor_id)
);
-- Problem: instructor_name depends on instructor_id, but instructor_id is not a candidate key
```

### Example: Corrected to BCNF
```sql
-- GOOD: BCNF compliant
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100)
);

CREATE TABLE instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100)
);

CREATE TABLE course_instructors (
    course_id INT,
    instructor_id INT,
    PRIMARY KEY (course_id, instructor_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id),
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
);
```

### Benefits of BCNF
- Eliminates all functional dependencies
- Ensures data consistency
- Prevents update anomalies
- Maintains referential integrity

## 5. Fourth Normal Form (4NF)

### Definition
A table is in 4NF if:
- It's in BCNF
- No multi-valued dependencies exist
- All attributes are functionally dependent on the primary key

### Example: Violation of 4NF
```sql
-- BAD: Violates 4NF (multi-valued dependency)
CREATE TABLE employee_skills_languages (
    employee_id INT,
    skill VARCHAR(100),
    language VARCHAR(100),
    PRIMARY KEY (employee_id, skill, language)
);
-- Problem: skills and languages are independent multi-valued attributes
```

### Example: Corrected to 4NF
```sql
-- GOOD: 4NF compliant
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100)
);

CREATE TABLE employee_skills (
    employee_id INT,
    skill VARCHAR(100),
    PRIMARY KEY (employee_id, skill),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE employee_languages (
    employee_id INT,
    language VARCHAR(100),
    PRIMARY KEY (employee_id, language),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

### Benefits of 4NF
- Eliminates multi-valued dependencies
- Reduces data redundancy
- Improves query performance
- Simplifies data maintenance

## 6. Fifth Normal Form (5NF)

### Definition
A table is in 5NF if:
- It's in 4NF
- No join dependencies exist
- All attributes are functionally dependent on the primary key

### Example: Violation of 5NF
```sql
-- BAD: Violates 5NF (join dependency)
CREATE TABLE supplier_parts_projects (
    supplier_id INT,
    part_id INT,
    project_id INT,
    PRIMARY KEY (supplier_id, part_id, project_id)
);
-- Problem: If supplier S supplies part P to project J, and supplier S supplies part Q to project J,
-- then supplier S supplies part P to project J (redundant information)
```

### Example: Corrected to 5NF
```sql
-- GOOD: 5NF compliant
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100)
);

CREATE TABLE parts (
    part_id INT PRIMARY KEY,
    part_name VARCHAR(100)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100)
);

CREATE TABLE supplier_parts (
    supplier_id INT,
    part_id INT,
    PRIMARY KEY (supplier_id, part_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (part_id) REFERENCES parts(part_id)
);

CREATE TABLE supplier_projects (
    supplier_id INT,
    project_id INT,
    PRIMARY KEY (supplier_id, project_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

CREATE TABLE part_projects (
    part_id INT,
    project_id INT,
    PRIMARY KEY (part_id, project_id),
    FOREIGN KEY (part_id) REFERENCES parts(part_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
```

### Benefits of 5NF
- Eliminates join dependencies
- Ensures data consistency
- Prevents update anomalies
- Maintains referential integrity

## 7. Sixth Normal Form (6NF)

### Definition
A table is in 6NF if:
- It's in 5NF
- No temporal dependencies exist
- All attributes are functionally dependent on the primary key

### Example: 6NF Implementation
```sql
-- GOOD: 6NF compliant (temporal database)
CREATE TABLE employee_history (
    employee_id INT,
    valid_from TIMESTAMP,
    valid_to TIMESTAMP,
    employee_name VARCHAR(100),
    department_id INT,
    salary DECIMAL(10,2),
    PRIMARY KEY (employee_id, valid_from),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
```

### Benefits of 6NF
- Eliminates temporal dependencies
- Supports historical data
- Ensures data consistency
- Maintains referential integrity

## Denormalization Techniques

### When to Denormalize
- **Performance Requirements**: When query performance is critical
- **Read-Heavy Workloads**: When reads significantly outnumber writes
- **Complex Queries**: When normalized structure makes queries complex
- **Reporting Requirements**: When analytical queries need denormalized data

### Common Denormalization Techniques

#### 1. Redundant Data Storage
```sql
-- Denormalized for performance
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),  -- Redundant but improves query performance
    order_date DATE,
    total_amount DECIMAL(10,2)
);
```

#### 2. Computed Columns
```sql
-- Computed column for performance
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    total_price DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);
```

#### 3. Materialized Views
```sql
-- Materialized view for complex aggregations
CREATE MATERIALIZED VIEW sales_summary AS
SELECT 
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as order_count,
    SUM(total_amount) as total_sales
FROM orders
GROUP BY DATE_TRUNC('month', order_date);
```

### Trade-offs of Denormalization
- **Pros**: Improved query performance, simplified queries, reduced joins
- **Cons**: Data redundancy, update complexity, storage overhead, consistency challenges

## Data Warehouse Schemas

### Star Schema
```sql
-- Fact table (center)
CREATE TABLE sales_fact (
    sale_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    date_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2)
);

-- Dimension tables (points)
CREATE TABLE product_dim (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    brand_id INT
);

CREATE TABLE customer_dim (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE date_dim (
    date_id INT PRIMARY KEY,
    date_value DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    day_of_week VARCHAR(20)
);
```

### Snowflake Schema
```sql
-- Extended star schema with normalized dimensions
CREATE TABLE product_dim (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    brand_id INT
);

CREATE TABLE category_dim (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    department_id INT
);

CREATE TABLE department_dim (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);
```

### Galaxy Schema
```sql
-- Multiple fact tables sharing dimensions
CREATE TABLE sales_fact (
    sale_id INT PRIMARY KEY,
    product_id INT,
    customer_id INT,
    date_id INT,
    quantity INT,
    unit_price DECIMAL(10,2)
);

CREATE TABLE inventory_fact (
    inventory_id INT PRIMARY KEY,
    product_id INT,
    warehouse_id INT,
    date_id INT,
    quantity_on_hand INT,
    reorder_level INT
);
```

## Normalization Best Practices

### 1. Start with 3NF
- Begin with 3NF as the baseline
- Only go higher if specific requirements demand it
- Consider performance implications

### 2. Consider Performance
- Balance normalization with query performance
- Use denormalization strategically
- Monitor query performance regularly

### 3. Plan for Growth
- Design for future requirements
- Consider data volume growth
- Plan for schema evolution

### 4. Document Decisions
- Document normalization choices
- Explain denormalization decisions
- Maintain data dictionary

### 5. Test Thoroughly
- Test with realistic data volumes
- Validate performance requirements
- Ensure data integrity

## Conclusion

Database normalization is a crucial aspect of database design that balances data integrity, consistency, and performance. While higher normal forms eliminate more redundancy, they may impact query performance. The key is to find the right balance based on your specific requirements:

- **1NF-3NF**: Essential for most applications
- **BCNF**: Recommended for critical data integrity
- **4NF-5NF**: Use when specific requirements demand it
- **6NF**: Rarely needed, mainly for temporal databases

Remember that denormalization is often necessary for performance, but should be done carefully with proper documentation and testing.

