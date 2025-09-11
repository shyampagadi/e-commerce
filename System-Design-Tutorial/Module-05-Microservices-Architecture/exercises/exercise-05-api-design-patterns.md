# Exercise 5: API Design Patterns

## Learning Objectives

After completing this exercise, you will be able to:
- Design RESTful APIs following best practices
- Create GraphQL schemas for flexible data fetching
- Implement gRPC services for high-performance communication
- Design API versioning strategies
- Plan for API security and rate limiting

## Prerequisites

- Understanding of microservices communication
- Knowledge of HTTP, REST, and API design principles
- Familiarity with GraphQL and gRPC
- Access to API development tools

## Scenario

You are designing APIs for a comprehensive e-learning platform that needs to support:
- Student and instructor management
- Course catalog and enrollment
- Video streaming and content delivery
- Assignment submission and grading
- Discussion forums and collaboration
- Progress tracking and analytics
- Mobile and web applications
- Third-party integrations

## Tasks

### Task 1: RESTful API Design

**Objective**: Design RESTful APIs for the e-learning platform.

**Instructions**:
1. Identify core resources and their relationships
2. Design resource URLs following REST conventions
3. Define HTTP methods and status codes
4. Design request/response schemas
5. Plan for pagination, filtering, and sorting

**Deliverables**:
- Resource identification and relationships
- RESTful URL design
- HTTP method and status code definitions
- Request/response schemas
- Pagination and filtering design

### Task 2: GraphQL Schema Design

**Objective**: Create a GraphQL schema for flexible data fetching.

**Instructions**:
1. Design GraphQL schema for the e-learning platform
2. Define types, queries, mutations, and subscriptions
3. Implement data resolvers and relationships
4. Plan for schema versioning and evolution
5. Design for performance and caching

**Deliverables**:
- GraphQL schema definition
- Type definitions and relationships
- Query, mutation, and subscription design
- Resolver implementation plan
- Schema versioning strategy

### Task 3: gRPC Service Design

**Objective**: Design gRPC services for high-performance communication.

**Instructions**:
1. Identify services that need high-performance communication
2. Design Protocol Buffer schemas
3. Define service methods and message types
4. Plan for streaming and bidirectional communication
5. Design for error handling and status codes

**Deliverables**:
- gRPC service identification
- Protocol Buffer schema design
- Service method definitions
- Streaming communication design
- Error handling strategy

### Task 4: API Versioning and Security

**Objective**: Design API versioning and security strategies.

**Instructions**:
1. Design API versioning strategy
2. Implement authentication and authorization
3. Plan for rate limiting and throttling
4. Design for API security and validation
5. Plan for monitoring and analytics

**Deliverables**:
- API versioning strategy
- Authentication and authorization design
- Rate limiting implementation
- Security validation plan
- Monitoring and analytics setup

## Validation Criteria

### RESTful API Design (25 points)
- [ ] Resource identification (5 points)
- [ ] URL design (5 points)
- [ ] HTTP methods and codes (5 points)
- [ ] Schema design (5 points)
- [ ] Pagination and filtering (5 points)

### GraphQL Schema Design (25 points)
- [ ] Schema definition (5 points)
- [ ] Type relationships (5 points)
- [ ] Query/mutation design (5 points)
- [ ] Resolver planning (5 points)
- [ ] Versioning strategy (5 points)

### gRPC Service Design (25 points)
- [ ] Service identification (5 points)
- [ ] Protocol Buffer schema (5 points)
- [ ] Method definitions (5 points)
- [ ] Streaming design (5 points)
- [ ] Error handling (5 points)

### API Versioning and Security (25 points)
- [ ] Versioning strategy (5 points)
- [ ] Authentication design (5 points)
- [ ] Rate limiting (5 points)
- [ ] Security validation (5 points)
- [ ] Monitoring setup (5 points)

## Extensions

### Advanced Challenge 1: Multi-tenant APIs
Design APIs to support multiple educational institutions with data isolation.

### Advanced Challenge 2: Real-time Collaboration
Design APIs for real-time collaboration features like live discussions and shared whiteboards.

### Advanced Challenge 3: Mobile Optimization
Design APIs optimized for mobile applications with offline capabilities.

## Solution Guidelines

### RESTful API Example
```
Resources:
- /api/v1/students - Student management
- /api/v1/courses - Course catalog
- /api/v1/enrollments - Course enrollment
- /api/v1/assignments - Assignment management
- /api/v1/grades - Grading system

HTTP Methods:
- GET /api/v1/students - List students
- POST /api/v1/students - Create student
- GET /api/v1/students/{id} - Get student
- PUT /api/v1/students/{id} - Update student
- DELETE /api/v1/students/{id} - Delete student
```

### GraphQL Schema Example
```
type Student {
  id: ID!
  name: String!
  email: String!
  enrollments: [Enrollment!]!
  assignments: [Assignment!]!
}

type Course {
  id: ID!
  title: String!
  description: String
  instructor: Instructor!
  students: [Student!]!
}

type Query {
  student(id: ID!): Student
  students(limit: Int, offset: Int): [Student!]!
  course(id: ID!): Course
  courses(search: String): [Course!]!
}
```

### gRPC Service Example
```
service StudentService {
  rpc GetStudent(GetStudentRequest) returns (Student);
  rpc CreateStudent(CreateStudentRequest) returns (Student);
  rpc UpdateStudent(UpdateStudentRequest) returns (Student);
  rpc DeleteStudent(DeleteStudentRequest) returns (Empty);
  rpc ListStudents(ListStudentsRequest) returns (stream Student);
}

message Student {
  string id = 1;
  string name = 2;
  string email = 3;
  repeated string course_ids = 4;
}
```

## Resources

- [REST API Design](https://restfulapi.net/)
- [GraphQL Documentation](https://graphql.org/)
- [gRPC Documentation](https://grpc.io/)
- [API Versioning](https://apievangelist.com/2018/01/08/api-versioning/)

## Next Steps

After completing this exercise:
1. Review the solution and compare with your approach
2. Identify areas for improvement
3. Apply API design patterns to your own projects
4. Move to Exercise 6: Data Management Patterns
