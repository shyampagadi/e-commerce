# REST API Design Principles

## Overview

Representational State Transfer (REST) is an architectural style that defines a set of constraints for creating web services. This document covers REST API design principles, best practices, and their implementation in AWS.

## Table of Contents
- [REST Fundamentals](#rest-fundamentals)
- [Core REST Principles](#core-rest-principles)
- [API Design Best Practices](#api-design-best-practices)
- [HTTP Methods and Status Codes](#http-methods-and-status-codes)
- [Resource Naming and URL Design](#resource-naming-and-url-design)
- [Rate Limiting](#rate-limiting)
- [API Routing](#api-routing)
- [Authentication and Authorization](#authentication-and-authorization)
- [AWS Implementation](#aws-implementation)

## REST Fundamentals

REST (Representational State Transfer) was introduced by Roy Fielding in his doctoral dissertation in 2000. It's not a protocol but an architectural style that leverages the existing HTTP protocol.

```
┌─────────────────────────────────────────────────────────────┐
│                    REST API ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                     CLIENTS                             │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │   WEB APP   │  │  MOBILE APP │  │ 3RD PARTY   │     │ │
│  │  │             │  │             │  │ INTEGRATION │     │ │
│  │  │ • Browser   │  │ • iOS       │  │ • Partners  │     │ │
│  │  │ • JavaScript│  │ • Android   │  │ • Webhooks  │     │ │
│  │  │ • SPA       │  │ • React Nat │  │ • Zapier    │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              │                             │
│                              ▼ HTTP Requests               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   API GATEWAY                           │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │              REQUEST PROCESSING                     │ │ │
│  │  │                                                     │ │ │
│  │  │ • Authentication    • Rate Limiting                 │ │ │
│  │  │ • Authorization     • Request Validation           │ │ │
│  │  │ • Routing          • Response Transformation       │ │ │
│  │  │ • Load Balancing   • Caching                       │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              │                             │
│                              ▼                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  REST API SERVICES                      │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │   USERS     │  │   ORDERS    │  │  PRODUCTS   │     │ │
│  │  │  SERVICE    │  │  SERVICE    │  │  SERVICE    │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │GET /users   │  │GET /orders  │  │GET /products│     │ │
│  │  │POST /users  │  │POST /orders │  │POST /products│    │ │
│  │  │PUT /users/id│  │PUT /orders/id│ │PUT /products/id│   │ │
│  │  │DELETE /users│  │DELETE /orders│ │DELETE /products│   │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              │                             │
│                              ▼                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   DATA LAYER                            │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │  DATABASE   │  │    CACHE    │  │  EXTERNAL   │     │ │
│  │  │             │  │             │  │   APIS      │     │ │
│  │  │ • PostgreSQL│  │ • Redis     │  │ • Payment   │     │ │
│  │  │ • MongoDB   │  │ • Memcached │  │ • Shipping  │     │ │
│  │  │ • DynamoDB  │  │ • ElastiCache│ │ • Analytics │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  Key REST Principles:                                       │
│  • Stateless communication                                  │
│  • Resource-based URLs                                      │
│  • Standard HTTP methods                                    │
│  • Uniform interface                                        │
│  • Cacheable responses                                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Key Characteristics

1. **Client-Server Architecture**: Separation of concerns between the user interface (client) and data storage (server)
2. **Statelessness**: Each request from client to server must contain all information needed to understand and process the request
3. **Cacheability**: Responses must define themselves as cacheable or non-cacheable
4. **Layered System**: A client cannot tell whether it's connected directly to the end server or through intermediaries
5. **Uniform Interface**: Simplified and decoupled architecture where each resource is uniquely addressable

### Benefits of REST APIs

- **Simplicity**: Uses standard HTTP methods and status codes
- **Scalability**: Stateless nature supports horizontal scaling
- **Performance**: Support for caching improves performance
- **Portability**: Can be used with any programming language
- **Visibility**: HTTP methods make operations explicit
- **Reliability**: Stateless operations are easier to recover during failures

## Core REST Principles

```
┌─────────────────────────────────────────────────────────────┐
│                    CORE REST PRINCIPLES                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                1. RESOURCE-BASED                        │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │              RESOURCE IDENTIFICATION                │ │ │
│  │  │                                                     │ │ │
│  │  │  URI Structure:                                     │ │ │
│  │  │  https://api.example.com/users/123                  │ │ │
│  │  │  │        │           │      │                      │ │ │ │
│  │  │  │        │           │      └─ Resource ID         │ │ │ │
│  │  │  │        │           └─ Resource Type              │ │ │ │
│  │  │  │        └─ API Base URL                           │ │ │ │
│  │  │  └─ Protocol                                        │ │ │ │
│  │  │                                                     │ │ │
│  │  │  Resource Hierarchy:                                │ │ │
│  │  │  /users           ← Collection                      │ │ │
│  │  │  /users/123       ← Individual Resource             │ │ │
│  │  │  /users/123/orders ← Sub-resource                   │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │         2. MANIPULATION THROUGH REPRESENTATIONS         │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   CLIENT    │    │    HTTP     │    │   SERVER    │ │ │
│  │  │             │    │  MESSAGE    │    │             │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ PUT Request │───▶│ JSON        │───▶│ Update      │ │ │
│  │  │ Update User │    │ Representation   │ Resource    │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ {           │    │ Content-    │    │ User Object │ │ │
│  │  │  "name":    │    │ Type:       │    │ Modified    │ │ │
│  │  │  "Jane",    │    │ application/│    │             │ │ │
│  │  │  "email":   │    │ json        │    │             │ │ │
│  │  │  "jane@..."  │   │             │    │             │ │ │
│  │  │ }           │    │             │    │             │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              3. SELF-DESCRIPTIVE MESSAGES               │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                HTTP REQUEST                         │ │ │
│  │  │                                                     │ │ │
│  │  │  GET /users/123 HTTP/1.1                            │ │ │
│  │  │  Host: api.example.com                              │ │ │
│  │  │  Accept: application/json                           │ │ │
│  │  │  Authorization: Bearer token123                     │ │ │
│  │  │  │     │         │               │                  │ │ │ │
│  │  │  │     │         │               └─ Auth Info       │ │ │ │
│  │  │  │     │         └─ Desired Format                  │ │ │ │
│  │  │  │     └─ Target Resource                           │ │ │ │
│  │  │  └─ HTTP Method (Action)                            │ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                HTTP RESPONSE                        │ │ │
│  │  │                                                     │ │ │
│  │  │  HTTP/1.1 200 OK                                    │ │ │
│  │  │  Content-Type: application/json                     │ │ │
│  │  │  Content-Length: 156                                │ │ │
│  │  │  Cache-Control: max-age=3600                        │ │ │
│  │  │  │         │              │            │            │ │ │ │
│  │  │  │         │              │            └─ Caching   │ │ │ │
│  │  │  │         │              └─ Content Size           │ │ │ │
│  │  │  │         └─ Response Format                       │ │ │ │
│  │  │  └─ Status (Success/Failure)                        │ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   4. HATEOAS                            │ │
│  │        (Hypermedia as Engine of Application State)      │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │              RESPONSE WITH LINKS                    │ │ │
│  │  │                                                     │ │ │
│  │  │  {                                                  │ │ │
│  │  │    "id": 123,                                       │ │ │
│  │  │    "name": "John Doe",                              │ │ │
│  │  │    "email": "john@example.com",                     │ │ │
│  │  │    "_links": {                                      │ │ │
│  │  │      "self": {                                      │ │ │
│  │  │        "href": "/users/123"                         │ │ │
│  │  │      },                                             │ │ │
│  │  │      "orders": {                                    │ │ │
│  │  │        "href": "/users/123/orders"                  │ │ │
│  │  │      },                                             │ │ │
│  │  │      "edit": {                                      │ │ │
│  │  │        "href": "/users/123",                        │ │ │
│  │  │        "method": "PUT"                              │ │ │
│  │  │      },                                             │ │ │
│  │  │      "delete": {                                    │ │ │
│  │  │        "href": "/users/123",                        │ │ │
│  │  │        "method": "DELETE"                           │ │ │
│  │  │      }                                              │ │ │
│  │  │    }                                                │ │ │
│  │  │  }                                                  │ │ │
│  │  │                                                     │ │ │
│  │  │  Benefits:                                          │ │ │
│  │  │  • Client discovers available actions               │ │ │
│  │  │  • API can evolve without breaking clients         │ │ │
│  │  │  • Reduces coupling between client and server      │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1. Resource-Based

REST APIs are designed around resources, which are any kind of object, data, or service that can be accessed by the client.

#### Resource Identification
- Resources are identified by URIs (Uniform Resource Identifiers)
- Each resource should have a unique URI
- Example: `/users/123` identifies user with ID 123

#### Resource Representations
- Resources can have multiple representations (JSON, XML, HTML, etc.)
- Clients specify desired representation using HTTP headers (Content-Type, Accept)
- Example: The same user resource might be represented in JSON, XML, or as an HTML page

### 2. Manipulation of Resources Through Representations

When a client holds a representation of a resource, it has enough information to modify or delete the resource on the server (provided it has permission).

- The representation captures the current or intended state of the resource
- When a client wants to change the state of a resource, it sends a representation
- The server interprets the representation to update the resource

### 3. Self-descriptive Messages

Each message includes enough information to describe how to process the message.

- HTTP methods define the action to perform (GET, POST, PUT, DELETE)
- HTTP headers provide metadata about the request or response
- HTTP status codes indicate the result of the operation
- Media types indicate how to process the representation

### 4. Hypermedia as the Engine of Application State (HATEOAS)

Clients interact with a network application entirely through hypermedia provided dynamically by application servers.

- API responses include links to related resources
- Clients do not need to hard-code resource URIs
- The API can evolve without breaking clients
- Example JSON response with HATEOAS links:

```json
{
  "id": 123,
  "name": "John Doe",
  "links": [
    {
      "rel": "self",
      "href": "https://api.example.com/users/123"
    },
    {
      "rel": "orders",
      "href": "https://api.example.com/users/123/orders"
    }
  ]
}
```

## API Design Best Practices

```
┌─────────────────────────────────────────────────────────────┐
│                 API DESIGN BEST PRACTICES                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 VERSIONING STRATEGIES                   │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │ URI PATH    │  │   HEADER    │  │   ACCEPT    │     │ │
│  │  │ VERSIONING  │  │ VERSIONING  │  │ VERSIONING  │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ /api/v1/    │  │ Accept-     │  │ Accept:     │     │ │
│  │  │ users       │  │ Version: v1 │  │ app/vnd.v1  │     │ │
│  │  │             │  │             │  │ +json       │     │ │
│  │  │ ✅ Explicit │  │ ✅ Clean    │  │ ✅ RESTful  │     │ │
│  │  │ ❌ URI      │  │ ❌ Hidden   │  │ ❌ Complex  │     │ │
│  │  │   changes   │  │   from URL  │  │   syntax    │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │                                                         │ │
│  │  ┌─────────────┐                                        │ │
│  │  │   QUERY     │                                        │ │
│  │  │ PARAMETER   │                                        │ │
│  │  │             │                                        │ │
│  │  │ /api/users  │                                        │ │
│  │  │ ?version=1  │                                        │ │
│  │  │             │                                        │ │
│  │  │ ✅ Simple   │                                        │ │
│  │  │ ❌ Easy to  │                                        │ │
│  │  │   overlook  │                                        │ │
│  │  └─────────────┘                                        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                PAGINATION STRATEGIES                    │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                OFFSET PAGINATION                    │ │ │
│  │  │                                                     │ │ │
│  │  │  Request: GET /users?offset=100&limit=25            │ │ │
│  │  │                                                     │ │ │
│  │  │  Database: [1][2][3]...[100][101][102]...[125]     │ │ │
│  │  │                      ▲─────────────────▲            │ │ │
│  │  │                    Skip 100    Take 25              │ │ │
│  │  │                                                     │ │ │
│  │  │  Response:                                          │ │ │
│  │  │  {                                                  │ │ │
│  │  │    "data": [...25 users...],                       │ │ │
│  │  │    "pagination": {                                  │ │ │
│  │  │      "offset": 100,                                 │ │ │
│  │  │      "limit": 25,                                   │ │ │
│  │  │      "total": 1000                                  │ │ │
│  │  │    }                                                │ │ │
│  │  │  }                                                  │ │ │
│  │  │                                                     │ │ │
│  │  │  ✅ Simple to implement                             │ │ │
│  │  │  ❌ Inefficient for large datasets                  │ │ │
│  │  │  ❌ Inconsistent if data changes                    │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │               CURSOR PAGINATION                     │ │ │
│  │  │                                                     │ │ │
│  │  │  Request: GET /users?cursor=eyJ1c2VyX2lkIjo1MH0&   │ │ │
│  │  │                     limit=25                        │ │ │
│  │  │                                                     │ │ │
│  │  │  Database: [1][2]...[50][51][52]...[75]            │ │ │
│  │  │                      ▲─────────────▲                │ │ │
│  │  │                   After ID 50   Take 25             │ │ │
│  │  │                                                     │ │ │
│  │  │  Response:                                          │ │ │
│  │  │  {                                                  │ │ │
│  │  │    "data": [...25 users...],                       │ │ │
│  │  │    "pagination": {                                  │ │ │
│  │  │      "next_cursor": "eyJ1c2VyX2lkIjo3NX0",         │ │ │
│  │  │      "has_more": true                               │ │ │
│  │  │    }                                                │ │ │
│  │  │  }                                                  │ │ │
│  │  │                                                     │ │ │
│  │  │  ✅ Efficient for large datasets                    │ │ │
│  │  │  ✅ Consistent results                              │ │ │
│  │  │  ❌ More complex to implement                       │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Versioning

API versioning is crucial for maintaining backward compatibility while allowing evolution of your API.

#### Common Versioning Strategies

1. **URI Path Versioning**
   - Include version in the URI path
   - Example: `/api/v1/users`
   - Pros: Explicit, easy to implement
   - Cons: Not RESTful (resources change URI), harder to manage in code

2. **Query Parameter Versioning**
   - Add version as a query parameter
   - Example: `/api/users?version=1`
   - Pros: Doesn't break URI-based caching
   - Cons: Easy to overlook, commonly used for filtering not versioning

3. **Header Versioning**
   - Use a custom header to indicate version
   - Example: `Accept-Version: v1`
   - Pros: Doesn't clutter URI, more RESTful
   - Cons: Less visible, harder to test from browsers

4. **Accept Header Versioning**
   - Use content negotiation via the Accept header
   - Example: `Accept: application/vnd.company.app-v1+json`
   - Pros: Most RESTful approach, leverages HTTP standards
   - Cons: Complex, not as intuitive for developers

#### Best Practices for Versioning

- Choose a versioning strategy early and be consistent
- Document how version changes will be communicated
- Consider semantic versioning (MAJOR.MINOR.PATCH)
- Maintain older versions for a reasonable deprecation period
- Clearly document breaking vs. non-breaking changes

### Pagination

Pagination is essential for handling large data sets efficiently.

#### Pagination Strategies

1. **Offset Pagination**
   - Use `limit` and `offset` parameters
   - Example: `/api/users?offset=100&limit=25`
   - Pros: Simple to implement
   - Cons: Inefficient for large datasets, inconsistent results if data changes

2. **Cursor-based Pagination**
   - Use a pointer to the last item
   - Example: `/api/users?after=user123&limit=25`
   - Pros: Efficient, consistent even when data changes
   - Cons: More complex implementation, typically requires sorted data

3. **Page-based Pagination**
   - Use `page` and `page_size` parameters
   - Example: `/api/users?page=4&page_size=25`
   - Pros: Intuitive for end users
   - Cons: Same issues as offset pagination

#### Pagination Response Format

Include metadata about pagination in responses:

```json
{
  "data": [...],
  "pagination": {
    "total_count": 1353,
    "page_size": 25,
    "current_page": 4,
    "total_pages": 55,
    "links": {
      "first": "/api/users?page=1&page_size=25",
      "prev": "/api/users?page=3&page_size=25",
      "next": "/api/users?page=5&page_size=25",
      "last": "/api/users?page=55&page_size=25"
    }
  }
}
```

### Error Handling

Consistent error handling improves API usability and debuggability.

```
┌─────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING STRATEGY                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 ERROR FLOW DIAGRAM                      │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   CLIENT    │    │ API SERVER  │    │   LOGGING   │ │ │
│  │  │             │    │             │    │   SYSTEM    │ │ │
│  │  │ 1. Invalid  │───▶│ 2. Validate │───▶│ 3. Log      │ │ │
│  │  │ Request     │    │ Request     │    │ Error       │ │ │
│  │  │             │    │             │    │ Details     │ │ │
│  │  │ POST /users │    │ ┌─────────┐ │    │             │ │ │
│  │  │ {           │    │ │Validation│ │    │ • Request   │ │ │
│  │  │  "email":   │    │ │ Error   │ │    │   ID        │ │ │
│  │  │  "invalid"  │    │ │ Detected│ │    │ • User ID   │ │ │
│  │  │ }           │    │ └─────────┘ │    │ • Stack     │ │ │
│  │  │             │    │             │    │   Trace     │ │ │
│  │  │             │◀───│ 4. Return   │    │ • Timestamp │ │ │
│  │  │ 5. Handle   │    │ Error       │    │             │ │ │
│  │  │ Error       │    │ Response    │    │             │ │ │
│  │  │ Response    │    │             │    │             │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              ERROR RESPONSE STRUCTURE                   │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                STANDARD FORMAT                      │ │ │
│  │  │                                                     │ │ │
│  │  │  HTTP/1.1 400 Bad Request                           │ │ │
│  │  │  Content-Type: application/json                     │ │ │
│  │  │                                                     │ │ │
│  │  │  {                                                  │ │ │
│  │  │    "error": {                                       │ │ │
│  │  │      "code": "VALIDATION_ERROR",                    │ │ │
│  │  │      "message": "Request validation failed",        │ │ │
│  │  │      "details": [                                   │ │ │ │
│  │  │        {                                            │ │ │ │
│  │  │          "field": "email",                          │ │ │ │
│  │  │          "error": "Invalid email format",          │ │ │ │
│  │  │          "code": "INVALID_FORMAT"                   │ │ │ │
│  │  │        }                                            │ │ │ │
│  │  │      ],                                             │ │ │ │
│  │  │      "request_id": "req_123456789",                 │ │ │ │
│  │  │      "timestamp": "2025-09-10T17:13:00Z",           │ │ │ │
│  │  │      "documentation": "https://api.docs/errors"     │ │ │ │
│  │  │    }                                                │ │ │ │
│  │  │  }                                                  │ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              HTTP STATUS CODE MAPPING                   │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │ CLIENT      │  │   SERVER    │  │  NETWORK    │     │ │
│  │  │ ERRORS      │  │   ERRORS    │  │  ERRORS     │     │ │
│  │  │ (4xx)       │  │   (5xx)     │  │             │     │ │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 400 Bad     │  │ 500 Internal│  │ 502 Bad     │     │ │
│  │  │ Request     │  │ Server Error│  │ Gateway     │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 401 Unauth  │  │ 501 Not     │  │ 503 Service │     │ │
│  │  │             │  │ Implemented │  │ Unavailable │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 403 Forbid  │  │ 502 Bad     │  │ 504 Gateway │     │ │
│  │  │             │  │ Gateway     │  │ Timeout     │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 404 Not     │  │ 503 Service │  │             │     │ │
│  │  │ Found       │  │ Unavailable │  │             │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 422 Unproc  │  │ 504 Gateway │  │             │     │ │
│  │  │ Entity      │  │ Timeout     │  │             │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 429 Too     │  │             │  │             │     │ │
│  │  │ Many Req    │  │             │  │             │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              ERROR HANDLING BEST PRACTICES              │ │
│  │                                                         │ │
│  │  ✅ DO:                          ❌ DON'T:              │ │
│  │  • Use appropriate HTTP codes    • Expose stack traces │ │
│  │  • Provide error codes           • Return HTML errors  │ │
│  │  • Include request IDs           • Use generic messages│ │
│  │  • Add documentation links       • Ignore error logging│ │
│  │  • Log detailed server errors    • Return 200 for errors│ │
│  │  • Validate input thoroughly     • Expose internal paths│ │
│  │  • Handle edge cases gracefully  • Skip error details  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Error Response Format

Provide detailed error information:

```json
{
  "error": {
    "code": "INVALID_PARAMETER",
    "message": "Invalid parameter: email",
    "details": "Email address is not properly formatted",
    "request_id": "f7a8b92c-3312-42f1-9121-f706e3bfad8a",
    "documentation_url": "https://api.example.com/docs/errors/INVALID_PARAMETER"
  }
}
```

#### Best Practices for Error Handling

- Use appropriate HTTP status codes
- Provide error codes for programmatic handling
- Include human-readable messages
- Add request IDs for tracking
- Consider including links to documentation
- Avoid exposing sensitive internal details
- Log detailed errors server-side

### Filtering, Sorting, and Field Selection

```
┌─────────────────────────────────────────────────────────────┐
│           FILTERING, SORTING & FIELD SELECTION             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    FILTERING                            │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │              BASIC FILTERING                        │ │ │
│  │  │                                                     │ │ │
│  │  │  Request: GET /api/users?status=active&role=admin   │ │ │
│  │  │                                                     │ │ │
│  │  │  Database Query:                                    │ │ │
│  │  │  SELECT * FROM users                                │ │ │
│  │  │  WHERE status = 'active' AND role = 'admin'        │ │ │
│  │  │                                                     │ │ │
│  │  │  Result: [                                          │ │ │
│  │  │    {"id": 1, "name": "John", "status": "active"},  │ │ │ │
│  │  │    {"id": 5, "name": "Jane", "status": "active"}   │ │ │ │
│  │  │  ]                                                  │ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │             ADVANCED FILTERING                      │ │ │
│  │  │                                                     │ │ │
│  │  │  Request: GET /api/products?price[gte]=100&        │ │ │ │
│  │  │                            price[lte]=500&         │ │ │ │
│  │  │                            category=electronics     │ │ │ │
│  │  │                                                     │ │ │
│  │  │  Operators:                                         │ │ │
│  │  │  • [eq]  = Equal to                                 │ │ │ │
│  │  │  • [ne]  = Not equal to                             │ │ │ │
│  │  │  • [gt]  = Greater than                             │ │ │ │
│  │  │  • [gte] = Greater than or equal                    │ │ │ │
│  │  │  • [lt]  = Less than                                │ │ │ │
│  │  │  • [lte] = Less than or equal                       │ │ │ │
│  │  │  • [in]  = In array                                 │ │ │ │
│  │  │  • [like]= Pattern matching                         │ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                     SORTING                             │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │               SORT EXAMPLES                         │ │ │
│  │  │                                                     │ │ │
│  │  │  Single Field:                                      │ │ │
│  │  │  GET /api/users?sort=name                           │ │ │ │
│  │  │  → ORDER BY name ASC                                │ │ │ │
│  │  │                                                     │ │ │
│  │  │  Descending:                                        │ │ │
│  │  │  GET /api/users?sort=-created_at                    │ │ │ │
│  │  │  → ORDER BY created_at DESC                         │ │ │ │
│  │  │                                                     │ │ │
│  │  │  Multiple Fields:                                   │ │ │
│  │  │  GET /api/users?sort=+name,-created_at              │ │ │ │
│  │  │  → ORDER BY name ASC, created_at DESC               │ │ │ │
│  │  │                                                     │ │ │
│  │  │  Result Transformation:                             │ │ │ │
│  │  │  Unsorted: [C, A, B] → Sorted: [A, B, C]           │ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 FIELD SELECTION                         │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │              SPARSE FIELDSETS                       │ │ │
│  │  │                                                     │ │ │
│  │  │  Full Response (Default):                           │ │ │
│  │  │  GET /api/users/123                                 │ │ │ │
│  │  │  {                                                  │ │ │ │
│  │  │    "id": 123,                                       │ │ │ │
│  │  │    "name": "John Doe",                              │ │ │ │
│  │  │    "email": "john@example.com",                     │ │ │ │
│  │  │    "phone": "+1234567890",                          │ │ │ │
│  │  │    "address": {...},                                │ │ │ │
│  │  │    "preferences": {...},                            │ │ │ │
│  │  │    "created_at": "2025-01-01T00:00:00Z",            │ │ │ │
│  │  │    "updated_at": "2025-09-10T17:13:00Z"             │ │ │ │
│  │  │  }                                                  │ │ │ │
│  │  │  Size: ~2KB                                         │ │ │ │
│  │  │                                                     │ │ │
│  │  │  Sparse Response:                                   │ │ │
│  │  │  GET /api/users/123?fields=id,name,email           │ │ │ │
│  │  │  {                                                  │ │ │ │
│  │  │    "id": 123,                                       │ │ │ │
│  │  │    "name": "John Doe",                              │ │ │ │
│  │  │    "email": "john@example.com"                      │ │ │ │
│  │  │  }                                                  │ │ │ │
│  │  │  Size: ~200B (90% reduction!)                       │ │ │ │
│  │  │                                                     │ │ │
│  │  │  Benefits:                                          │ │ │
│  │  │  • Reduced bandwidth usage                          │ │ │ │
│  │  │  • Faster response times                            │ │ │ │
│  │  │  • Lower server processing                          │ │ │ │
│  │  │  • Mobile-friendly                                  │ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              COMBINED QUERY EXAMPLE                     │ │
│  │                                                         │ │
│  │  GET /api/products?                                     │ │
│  │    category=electronics&                                │ │
│  │    price[gte]=100&                                      │ │
│  │    price[lte]=500&                                      │ │
│  │    status=active&                                       │ │
│  │    sort=-rating,+price&                                 │ │
│  │    fields=id,name,price,rating&                         │ │
│  │    limit=20&                                            │ │
│  │    offset=0                                             │ │
│  │                                                         │ │
│  │  Result: Filtered, sorted, limited electronics         │ │
│  │  with only essential fields for optimal performance     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Filtering

- Use query parameters for filtering
- Example: `/api/users?status=active&role=admin`
- Support operators where necessary: `/api/products?price[gte]=100&price[lte]=200`

#### Sorting

- Use a `sort` parameter with field names
- Use prefix for ascending/descending
- Example: `/api/users?sort=+name,-created_at` (ascending by name, then descending by creation date)

#### Field Selection

- Allow clients to request only needed fields
- Reduces payload size and improves performance
- Example: `/api/users?fields=id,name,email`

## HTTP Methods and Status Codes

```
┌─────────────────────────────────────────────────────────────┐
│                   HTTP METHODS & CRUD                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    HTTP METHODS                         │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │     GET     │  │    POST     │  │     PUT     │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ • Retrieve  │  │ • Create    │  │ • Update    │     │ │
│  │  │ • Safe      │  │ • Not Safe  │  │ • Idempotent│     │ │
│  │  │ • Idempotent│  │ • Not Idem  │  │ • Not Safe  │     │ │
│  │  │ • Cacheable │  │ • Not Cache │  │ • Not Cache │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │   PATCH     │  │   DELETE    │  │    HEAD     │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ • Partial   │  │ • Remove    │  │ • Metadata  │     │ │
│  │  │   Update    │  │ • Idempotent│  │ • Like GET  │     │ │
│  │  │ • Not Safe  │  │ • Not Safe  │  │ • No Body   │     │ │
│  │  │ • Not Idem  │  │ • Not Cache │  │ • Cacheable │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  CRUD MAPPING                           │ │
│  │                                                         │ │
│  │  CREATE  ──────▶  POST   /users                        │ │
│  │  READ    ──────▶  GET    /users/123                    │ │
│  │  UPDATE  ──────▶  PUT    /users/123                    │ │
│  │  DELETE  ──────▶  DELETE /users/123                    │ │
│  │                                                         │ │
│  │  LIST    ──────▶  GET    /users                        │ │
│  │  SEARCH  ──────▶  GET    /users?name=john              │ │
│  │  PARTIAL ──────▶  PATCH  /users/123                    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 STATUS CODES                            │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │ 2xx SUCCESS │  │ 3xx REDIRECT│  │ 4xx CLIENT  │     │ │
│  │  │             │  │             │  │   ERROR     │     │ │
│  │  │ 200 OK      │  │ 301 Moved   │  │ 400 Bad Req │     │ │
│  │  │ 201 Created │  │ 302 Found   │  │ 401 Unauth  │     │ │
│  │  │ 204 No Cont │  │ 304 Not Mod │  │ 403 Forbid  │     │ │
│  │  │             │  │             │  │ 404 Not Fnd │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │                                                         │ │
│  │  ┌─────────────┐                                        │ │
│  │  │ 5xx SERVER  │                                        │ │
│  │  │   ERROR     │                                        │ │
│  │  │             │                                        │ │
│  │  │ 500 Internal│                                        │ │
│  │  │ 502 Bad GW  │                                        │ │
│  │  │ 503 Unavail │                                        │ │
│  │  │ 504 Timeout │                                        │ │
│  │  └─────────────┘                                        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### RESTful HTTP Methods

#### GET
- **Purpose**: Retrieve a resource or collection
- **Properties**: Safe, idempotent, cacheable
- **Examples**: 
  - `GET /users` - List users
  - `GET /users/123` - Get user with ID 123

#### POST
- **Purpose**: Create a new resource
- **Properties**: Not safe, not idempotent, not cacheable
- **Examples**: 
  - `POST /users` - Create a new user
  - `POST /orders/123/refunds` - Create a refund for order 123

#### PUT
- **Purpose**: Update a resource by replacing it entirely
- **Properties**: Not safe, idempotent, not cacheable
- **Examples**: 
  - `PUT /users/123` - Replace user 123 with new data

#### PATCH
- **Purpose**: Partially update a resource
- **Properties**: Not safe, not idempotent (usually), not cacheable
- **Examples**: 
  - `PATCH /users/123` - Update specific fields of user 123

#### DELETE
- **Purpose**: Remove a resource
- **Properties**: Not safe, idempotent, not cacheable
- **Examples**: 
  - `DELETE /users/123` - Delete user 123

#### OPTIONS
- **Purpose**: Get information about allowed methods
- **Properties**: Safe, idempotent, not cacheable
- **Examples**: 
  - `OPTIONS /users` - Get allowed methods on users resource

### HTTP Status Codes

#### 2xx (Success)
- **200 OK**: Request succeeded
- **201 Created**: Resource created successfully
- **202 Accepted**: Request accepted but processing not completed
- **204 No Content**: Success but no response body (e.g., after DELETE)

#### 3xx (Redirection)
- **301 Moved Permanently**: Resource has new permanent URI
- **302 Found**: Temporary redirection
- **304 Not Modified**: Client's cached version is still valid

#### 4xx (Client Error)
- **400 Bad Request**: Invalid request syntax
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Authentication succeeded but insufficient permissions
- **404 Not Found**: Resource doesn't exist
- **405 Method Not Allowed**: HTTP method not supported for this resource
- **409 Conflict**: Request conflicts with current state
- **415 Unsupported Media Type**: Request payload format not supported
- **422 Unprocessable Entity**: Request format OK but semantically invalid
- **429 Too Many Requests**: Rate limit exceeded

#### 5xx (Server Error)
- **500 Internal Server Error**: Generic server error
- **501 Not Implemented**: Server doesn't support requested functionality
- **502 Bad Gateway**: Server as gateway received invalid response
- **503 Service Unavailable**: Server temporarily unavailable
- **504 Gateway Timeout**: Server as gateway didn't receive response in time

## Resource Naming and URL Design

Consistent and intuitive resource naming is crucial for a usable API. Well-designed URLs make APIs more discoverable and easier to use.

```
┌─────────────────────────────────────────────────────────────┐
│                 REST URL DESIGN PATTERNS                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 RESOURCE HIERARCHY                      │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                 COLLECTION                          │ │ │
│  │  │              /api/v1/users                          │ │ │
│  │  │                    │                                │ │ │
│  │  │                    ▼                                │ │ │
│  │  │              ┌─────────────┐                        │ │ │
│  │  │              │   RESOURCE  │                        │ │ │
│  │  │              │/api/v1/users│                        │ │ │
│  │  │              │    /123     │                        │ │ │
│  │  │              └─────────────┘                        │ │ │
│  │  │                    │                                │ │ │
│  │  │                    ▼                                │ │ │
│  │  │              ┌─────────────┐                        │ │ │
│  │  │              │SUB-RESOURCE │                        │ │ │
│  │  │              │/api/v1/users│                        │ │ │
│  │  │              │/123/orders  │                        │ │ │
│  │  │              └─────────────┘                        │ │ │
│  │  │                    │                                │ │ │
│  │  │                    ▼                                │ │ │
│  │  │              ┌─────────────┐                        │ │ │
│  │  │              │SUB-RESOURCE │                        │ │ │
│  │  │              │   ITEM      │                        │ │ │
│  │  │              │/api/v1/users│                        │ │ │
│  │  │              │/123/orders  │                        │ │ │
│  │  │              │    /456     │                        │ │ │
│  │  │              └─────────────┘                        │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 URL CONVENTIONS                         │ │
│  │                                                         │ │
│  │  ✅ GOOD EXAMPLES:                                      │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ GET    /api/v1/users           # List users         │ │ │
│  │  │ GET    /api/v1/users/123       # Get specific user  │ │ │
│  │  │ POST   /api/v1/users           # Create user        │ │ │
│  │  │ PUT    /api/v1/users/123       # Update user        │ │ │
│  │  │ DELETE /api/v1/users/123       # Delete user        │ │ │
│  │  │                                                     │ │ │
│  │  │ GET    /api/v1/users/123/orders # User's orders     │ │ │
│  │  │ POST   /api/v1/users/123/orders # Create order      │ │ │
│  │  │ GET    /api/v1/orders/456       # Specific order    │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  ❌ BAD EXAMPLES:                                       │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ GET    /api/v1/getUsers        # Verb in URL        │ │ │
│  │  │ POST   /api/v1/createUser      # Action in URL      │ │ │
│  │  │ GET    /api/v1/user            # Singular noun      │ │ │
│  │  │ DELETE /api/v1/deleteUser/123  # Redundant verb     │ │ │
│  │  │ GET    /api/v1/Users           # Inconsistent case  │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 QUERY PARAMETERS                        │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ FILTERING:                                          │ │ │
│  │  │ GET /api/v1/users?status=active                     │ │ │
│  │  │ GET /api/v1/users?role=admin&status=active          │ │ │
│  │  │                                                     │ │ │
│  │  │ SORTING:                                            │ │ │
│  │  │ GET /api/v1/users?sort=name                         │ │ │
│  │  │ GET /api/v1/users?sort=-created_at                  │ │ │
│  │  │                                                     │ │ │
│  │  │ PAGINATION:                                         │ │ │
│  │  │ GET /api/v1/users?page=2&limit=20                   │ │ │
│  │  │ GET /api/v1/users?offset=40&limit=20                │ │ │
│  │  │                                                     │ │ │
│  │  │ FIELD SELECTION:                                    │ │ │
│  │  │ GET /api/v1/users?fields=id,name,email              │ │ │
│  │  │ GET /api/v1/users?include=profile,orders            │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Resource Naming Conventions

#### Use Nouns, Not Verbs

Resources represent entities, not actions. Use nouns for resource names.

- **Good**: `/users`, `/articles`, `/products`
- **Bad**: `/getUsers`, `/createArticle`, `/deleteProduct`

Actions are represented by HTTP methods, not in the resource names.

#### Use Plural Nouns for Collections

Use plural nouns for collection resources to maintain consistency.

- **Good**: `/users`, `/orders`, `/products`
- **Avoid**: `/user`, `/order`, `/product`

#### Use Singular or Plural for Singletons

For singleton resources that represent a concept with only one instance per parent, you can use singular.

- Examples: `/account/settings`, `/system/status`

#### Use Concrete Names

Choose specific, concrete names rather than abstract concepts.

- **Good**: `/articles`, `/products`, `/users`
- **Avoid**: `/items`, `/entities`, `/resources`

### URL Structure Guidelines

#### Hierarchical Relationships

Express containment or hierarchical relationships through nested paths.

- **Parent-Child**: `/orders/123/items`
- **Container-Element**: `/playlists/456/tracks`

Keep nesting to a reasonable depth (typically no more than 2-3 levels).

#### Resource IDs

Use unique identifiers in resource paths. Common types include:

- **Numeric IDs**: `/users/123`
- **UUIDs**: `/orders/a8098c1a-f86e-11da-bd1a-00112444be1e`
- **Slugs**: `/articles/introduction-to-rest-apis`

#### Query Parameters for Non-Resource Data

Use query parameters for:
- Filtering: `/products?category=electronics`
- Sorting: `/products?sort=price_desc`
- Pagination: `/products?page=2&per_page=25`
- Search: `/products?q=wireless+headphones`

#### Consistent Casing

Choose a consistent case format for multi-word resource names. Common options:

- **Kebab-case**: `/blog-posts`, `/shipping-addresses`
- **Camelcase**: `/blogPosts`, `/shippingAddresses`
- **Snake_case**: `/blog_posts`, `/shipping_addresses`

Kebab-case is often preferred as it's the most readable in URLs.

### Advanced URL Design Patterns

#### Resource Collections and Individual Resources

Follow a consistent pattern for accessing collections and individual resources:

- Collection: `/resources`
- Individual: `/resources/{id}`

#### Sub-resources

For resources that exist only within the context of another resource:

- `/orders/{order_id}/items`
- `/users/{user_id}/addresses`

#### Resource Actions (Non-CRUD)

For operations that don't map neatly to CRUD, consider using:

1. **Custom resource endpoints**:
   - `/users/{id}/password-reset`
   - `/orders/{id}/cancel`

2. **Action resources**:
   - `POST /password-resets` (create a password reset)
   - `POST /cancellations` (create a cancellation)

#### Bulk Operations

For operations involving multiple resources at once:

- `POST /bulk/users` (create multiple users)
- `PATCH /bulk/products` (update multiple products)

#### Versioning in URLs

If using URI path versioning, place the version at the beginning of the path:

- `/v1/users`
- `/v2/products`

### URL Design Examples

#### E-commerce API Example

```
# Collections and items
GET /products                 # List products
GET /products/12345           # Get specific product
POST /products                # Create new product
PUT /products/12345           # Update product
DELETE /products/12345        # Delete product

# Sub-resources
GET /products/12345/reviews   # List reviews for product
POST /products/12345/reviews  # Add review to product

# Filtering and search
GET /products?category=electronics&brand=samsung
GET /products?price[min]=100&price[max]=500
GET /products?q=wireless+headphones
```

#### Social Media API Example

```
# User resources
GET /users/johndoe            # Get user profile
PUT /users/johndoe            # Update profile
GET /users/johndoe/followers  # Get user's followers
POST /users/johndoe/follow    # Follow a user

# Content resources
GET /posts                    # Get feed/timeline
GET /posts/5678               # Get specific post
POST /posts                   # Create post
POST /posts/5678/comments     # Comment on post
PUT /posts/5678/likes         # Like post
```

## Rate Limiting

Rate limiting is a critical strategy for protecting APIs from abuse, ensuring service stability, and managing resource allocation. It restricts the number of requests a client can make to an API within a specified time period.

```
┌─────────────────────────────────────────────────────────────┐
│                 RATE LIMITING ALGORITHMS                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 FIXED WINDOW                            │ │
│  │                                                         │ │
│  │  Limit: 10 requests per minute                          │ │
│  │                                                         │ │
│  │  Time:  0:00    0:30    1:00    1:30    2:00           │ │
│  │         │       │       │       │       │               │ │
│  │  Reqs:  ████████████████████████████████████████        │ │
│  │         10      0       10      0       10              │ │
│  │                                                         │ │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐       │ │
│  │  │ Window 1    │ │ Window 2    │ │ Window 3    │       │ │
│  │  │ 10 requests │ │ 10 requests │ │ 10 requests │       │ │
│  │  │ ALLOWED     │ │ ALLOWED     │ │ ALLOWED     │       │ │
│  │  └─────────────┘ └─────────────┘ └─────────────┘       │ │
│  │                                                         │ │
│  │  Pros: Simple, Memory efficient                         │ │
│  │  Cons: Burst at window boundaries                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                SLIDING WINDOW                           │ │
│  │                                                         │ │
│  │  Limit: 10 requests per minute                          │ │
│  │                                                         │ │
│  │  Time:    0:00   0:15   0:30   0:45   1:00             │ │
│  │           │      │      │      │      │                 │ │
│  │  Window:  ├──────┼──────┼──────┼──────┤                 │ │
│  │           │      ├──────┼──────┼──────┤                 │ │
│  │           │      │      ├──────┼──────┤                 │ │
│  │           │      │      │      ├──────┤                 │ │
│  │                                                         │ │
│  │  Each request checks last 60 seconds                    │ │
│  │  More accurate rate limiting                            │ │
│  │                                                         │ │
│  │  Pros: Smooth rate limiting, No burst                   │ │
│  │  Cons: More memory, Complex implementation              │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                TOKEN BUCKET                             │ │
│  │                                                         │ │
│  │  Capacity: 10 tokens, Refill: 1 token/6 seconds        │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                   BUCKET                            │ │ │
│  │  │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐           │ │ │
│  │  │  │  T  │ │  T  │ │  T  │ │  T  │ │  T  │           │ │ │
│  │  │  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘           │ │ │
│  │  │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐           │ │ │
│  │  │  │  T  │ │  T  │ │  T  │ │  T  │ │  T  │           │ │ │
│  │  │  └─────┘ └─────┘ └─────┘ └─────┘ └─────┘           │ │ │
│  │  │                                                     │ │ │
│  │  │  Current: 10/10 tokens                              │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                              │                         │ │
│  │  Request ──────────────────▶ │ ◀────── Refill Rate     │ │
│  │  (Consumes 1 token)          │         (1 token/6s)    │ │
│  │                                                         │ │
│  │  Pros: Allows bursts, Smooth over time                  │ │
│  │  Cons: Complex, Memory per client                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                LEAKY BUCKET                             │ │
│  │                                                         │ │
│  │  Process Rate: 1 request per 6 seconds                  │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                   QUEUE                             │ │ │
│  │  │                                                     │ │ │
│  │  │  Incoming ──▶ ┌─────┐ ┌─────┐ ┌─────┐ ──▶ Process  │ │ │
│  │  │  Requests     │ Req │ │ Req │ │ Req │     at Fixed  │ │ │
│  │  │               │  1  │ │  2  │ │  3  │     Rate      │ │ │
│  │  │               └─────┘ └─────┘ └─────┘               │ │ │
│  │  │                                                     │ │ │
│  │  │  If queue full: Reject new requests                 │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  Pros: Smooth output rate, Predictable                  │ │
│  │  Cons: Can introduce latency, Queue management          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why Implement Rate Limiting

1. **Protect Against Abuse**:
   - Prevent denial-of-service (DoS) attacks
   - Mitigate brute force attacks
   - Limit scraping and data harvesting

2. **Ensure Service Stability**:
   - Prevent resource exhaustion
   - Maintain consistent performance for all users
   - Avoid cascading failures

3. **Business Considerations**:
   - Monetize API usage tiers
   - Allocate resources fairly among clients
   - Control costs in pay-per-use infrastructure

### Rate Limiting Algorithms

#### 1. Fixed Window

Counts requests in fixed time intervals (e.g., 100 requests per minute).

**Implementation**:
- Reset counter at the start of each window
- Increment counter with each request
- Reject requests when limit is reached

**Pros**:
- Simple to understand and implement
- Low memory overhead

**Cons**:
- Allows request bursts at window boundaries
- Can still overwhelm systems at window transitions

#### 2. Sliding Window

Tracks requests over a rolling time period.

**Implementation**:
- Store timestamp of each request
- Count requests within the sliding window
- Remove timestamps outside the window

**Pros**:
- More accurate rate control
- Prevents boundary bursts

**Cons**:
- Higher memory usage (storing timestamps)
- More complex to implement

#### 3. Token Bucket

Adds tokens to a bucket at a fixed rate, with each request consuming a token.

**Implementation**:
- Add tokens to bucket at a constant rate up to capacity
- Each request consumes one token
- Reject requests when bucket is empty

**Pros**:
- Allows for bursts within limits
- Smooths out request processing
- Can assign different token costs to different endpoints

**Cons**:
- Slightly more complex implementation
- Requires per-client state management

#### 4. Leaky Bucket

Processes requests at a constant rate, queueing excess requests.

**Implementation**:
- Process requests at a fixed rate
- Queue excess requests up to a limit
- Drop requests when queue is full

**Pros**:
- Ensures constant processing rate
- Good for traffic shaping

**Cons**:
- Can introduce latency
- More complex to implement
- Fixed processing rate may not utilize available resources efficiently

### Rate Limiting Headers

When implementing rate limiting, include standard HTTP headers to inform clients about their limits:

```
X-RateLimit-Limit: 100         # Total requests allowed in period
X-RateLimit-Remaining: 75      # Requests remaining in period
X-RateLimit-Reset: 1626969262  # Timestamp when limit resets
Retry-After: 30                # Seconds to wait before retrying (with 429)
```

### Response for Rate-Limited Requests

When a client exceeds their rate limit:

1. Return HTTP status code `429 Too Many Requests`
2. Include a `Retry-After` header
3. Provide a clear error message

Example response:
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "You have exceeded the rate limit of 100 requests per minute",
    "retry_after": 30
  }
}
```

### Rate Limiting Strategies

#### 1. Client Identification

Methods to identify clients for rate limiting:

- **API Keys**: Most common, assigned per client
- **IP Address**: Simple but can be problematic with shared IPs
- **User ID**: For authenticated users
- **Combination**: Multiple factors for more accurate identification

#### 2. Granularity Levels

Apply rate limits at different levels:

- **Global**: Across the entire API
- **Per Endpoint**: Different limits for different resources
- **Per Method**: Different limits for GET vs POST
- **Resource-Based**: Limits based on resource consumption

#### 3. Advanced Techniques

- **Tiered Rate Limiting**: Different limits for different subscription levels
- **Dynamic Rate Limiting**: Adjust limits based on server load
- **Graduated Rate Limiting**: Reduce allowed rate gradually instead of cutting off
- **Priority Queuing**: Process higher-priority requests first during high load

### Implementation Best Practices

1. **Document Your Rate Limits**:
   - Clearly explain limits in API documentation
   - Describe how clients should handle rate limiting

2. **Provide Feedback**:
   - Use standard rate limit headers
   - Include detailed error messages
   - Offer guidance on when to retry

3. **Design for Scale**:
   - Use distributed rate limiting for multiple API servers
   - Consider using Redis or similar for centralized counter storage
   - Implement efficient algorithms for high-volume APIs

4. **Graceful Degradation**:
   - Consider throttling instead of blocking during high load
   - Implement priority-based rate limiting for critical operations

## API Routing

API routing is the process of directing client requests to the appropriate handlers based on the request's URL path, method, and other factors. Well-designed routing is essential for creating maintainable, scalable APIs.

### Routing Fundamentals

#### 1. Route Structure

Routes in REST APIs typically follow a hierarchical pattern:

- **Base Path**: `/api/v1`
- **Resource Path**: `/users`
- **Resource Identifier**: `/123`
- **Sub-resource Path**: `/orders`
- **Full Path Example**: `/api/v1/users/123/orders`

#### 2. Route Parameters

Parameters embedded in the route path:

- **Path Parameters**: `/users/{id}` or `/users/:id`
- **Query Parameters**: `/users?role=admin&status=active`
- **Header Parameters**: Used for metadata, authentication

### Routing Patterns

#### 1. Resource-Based Routing

The standard REST approach mapping HTTP methods to CRUD operations:

```
GET    /resources       # List resources
POST   /resources       # Create a resource
GET    /resources/{id}  # Retrieve a resource
PUT    /resources/{id}  # Update a resource
DELETE /resources/{id}  # Delete a resource
```

#### 2. Nested Resources

For representing hierarchical relationships:

```
GET    /users/{userId}/orders         # List orders for a user
POST   /users/{userId}/orders         # Create an order for a user
GET    /users/{userId}/orders/{orderId}  # Get specific order
```

Best practice: Limit nesting to 1-2 levels to avoid overly complex URLs.

#### 3. Controller-Based Routes

For operations that don't fit the CRUD model:

```
POST /users/{id}/reset-password
POST /orders/{id}/cancel
POST /emails/verify
```

#### 4. Bulk Operations

For handling multiple resources in a single request:

```
POST   /bulk/users      # Create multiple users
PATCH  /bulk/products   # Update multiple products
DELETE /users?ids=1,2,3 # Delete multiple users
```

### Advanced Routing Concepts

#### 1. Content Negotiation

Routing based on requested content type:

```
GET /users/123
Accept: application/json  # Returns JSON representation

GET /users/123
Accept: application/xml   # Returns XML representation
```

#### 2. Versioning Through Routes

Using URL paths for API versioning:

```
/api/v1/users
/api/v2/users
```

#### 3. Feature Toggles in Routes

Enabling experimental features through routes:

```
/api/users?features=new-sorting,advanced-filters
```

### Routing Implementation Considerations

#### 1. Route Registration

Two common approaches:

- **Declarative**: Define routes in configuration files or annotations
- **Programmatic**: Register routes in code

#### 2. Route Middleware

Common middleware functions in the routing pipeline:

- **Authentication**: Verify user identity
- **Authorization**: Check permissions
- **Validation**: Validate request parameters
- **Rate Limiting**: Apply request throttling
- **Logging**: Record request details
- **Caching**: Cache responses

#### 3. Route Organization

Strategies for organizing routes in larger APIs:

- **By Resource**: Group routes by the resource they manage
- **By Feature**: Group routes by feature or domain
- **By Access Level**: Group routes by required permissions

#### 4. Error Handling

Consistent error responses for routing issues:

- **404 Not Found**: Route doesn't exist
- **405 Method Not Allowed**: Method not supported on route
- **414 URI Too Long**: URL exceeds length limits

### Routing Best Practices

1. **Be Consistent**:
   - Follow consistent naming conventions
   - Use plural nouns for collections
   - Maintain consistent URL patterns

2. **Keep Routes Clean**:
   - Avoid deeply nested hierarchies
   - Use query parameters for filtering, not path segments
   - Limit URL length (max 2000 characters recommended)

3. **Design for Evolvability**:
   - Use versioning for breaking changes
   - Implement feature flags for gradual rollout
   - Document all routes comprehensively

4. **Consider Performance**:
   - Optimize route matching algorithms
   - Use route caching where appropriate
   - Monitor slow routes and optimize handlers

5. **Security Considerations**:
   - Validate all route parameters
   - Protect against path traversal attacks
   - Apply appropriate authorization to all routes

## Authentication and Authorization

Authentication and authorization are critical for API security, ensuring that only authorized users can access protected resources.

```
┌─────────────────────────────────────────────────────────────┐
│              AUTHENTICATION & AUTHORIZATION FLOWS           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   JWT TOKEN FLOW                        │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   CLIENT    │    │AUTH SERVICE │    │ API SERVER  │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ 1. Login    │───▶│ 2. Validate │    │             │ │ │
│  │  │ Credentials │    │ Credentials │    │             │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │             │◀───│ 3. Return   │    │             │ │ │
│  │  │ 4. Store    │    │ JWT Token   │    │             │ │ │
│  │  │ JWT Token   │    │             │    │             │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ 5. API      │─────────────────────▶│ 6. Validate │ │ │
│  │  │ Request +   │    │             │    │ JWT Token   │ │ │
│  │  │ JWT Token   │    │             │    │             │ │ │
│  │  │             │◀─────────────────────│ 7. Return   │ │ │
│  │  │ 8. Response │    │             │    │ Data        │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │                                                         │ │
│  │  JWT Structure: header.payload.signature               │ │
│  │  • Header: Algorithm & token type                      │ │
│  │  • Payload: Claims (user info, permissions, expiry)    │ │
│  │  • Signature: Verification hash                        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  OAUTH 2.0 FLOW                        │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │   CLIENT    │  │AUTH SERVER │  │RESOURCE SRV │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 1. Auth     │─▶│ 2. User     │  │             │     │ │
│  │  │ Request     │  │ Login       │  │             │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │             │◀─│ 3. Auth     │  │             │     │ │
│  │  │ 4. Exchange │  │ Code        │  │             │     │ │
│  │  │ Code for    │─▶│             │  │             │     │ │
│  │  │ Token       │  │ 5. Access   │  │             │     │ │
│  │  │             │◀─│ Token       │  │             │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 6. API      │─────────────────▶│ 7. Validate │     │ │
│  │  │ Request +   │  │             │  │ Token       │     │ │
│  │  │ Access Token│  │             │  │             │     │ │
│  │  │             │◀─────────────────│ 8. Return   │     │ │
│  │  │ 9. Response │  │             │  │ Data        │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │                                                         │ │
│  │  Benefits: Secure, Standardized, Delegated auth        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 API KEY FLOW                            │ │
│  │                                                         │ │
│  │  ┌─────────────┐              ┌─────────────┐           │ │
│  │  │   CLIENT    │              │ API SERVER  │           │ │
│  │  │             │              │             │           │ │
│  │  │ 1. API      │─────────────▶│ 2. Validate │           │ │
│  │  │ Request +   │              │ API Key     │           │ │
│  │  │ API Key     │              │             │           │ │
│  │  │             │              │ 3. Check    │           │ │
│  │  │ Header:     │              │ Rate Limits │           │ │
│  │  │ X-API-Key   │              │             │           │ │
│  │  │             │◀─────────────│ 4. Return   │           │ │
│  │  │ 5. Response │              │ Data        │           │ │
│  │  └─────────────┘              └─────────────┘           │ │
│  │                                                         │ │
│  │  Simple but limited: No user context, Basic security   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │               ROLE-BASED ACCESS CONTROL                 │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │    USER     │  │    ROLE     │  │ PERMISSION  │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ • john_doe  │─▶│ • admin     │─▶│ • read      │     │ │
│  │  │ • jane_doe  │  │ • editor    │  │ • write     │     │ │
│  │  │ • bob_smith │  │ • viewer    │  │ • delete    │     │ │
│  │  │             │  │             │  │ • execute   │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │                                                         │ │
│  │  Authorization Check:                                   │ │
│  │  1. Extract user from token                             │ │
│  │  2. Get user's roles                                    │ │
│  │  3. Check role permissions for resource                 │ │
│  │  4. Allow/Deny access                                   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Authentication Methods

#### 1. API Keys

Simple tokens that identify the calling project or application.

**Implementation:**
- Include in request header: `X-API-Key: abcd1234`
- Or in query parameter: `?api_key=abcd1234` (less secure)

**Best for:**
- Service-to-service communication
- Public APIs with rate limiting
- Low-security applications

**Limitations:**
- No user context
- Limited revocation capabilities
- Less secure than other methods

#### 2. Basic Authentication

Base64 encoding of username and password.

**Implementation:**
- Include header: `Authorization: Basic {base64(username:password)}`

**Best for:**
- Development environments
- Internal APIs with TLS/SSL

**Limitations:**
- Transmits credentials with every request
- No built-in expiration
- Username and password easily decoded if intercepted

#### 3. Bearer Token (OAuth 2.0)

Token-based authentication where the client presents an access token.

**Implementation:**
- Include header: `Authorization: Bearer {token}`
- Often used with JWT (JSON Web Tokens)

**Best for:**
- User authentication
- APIs requiring user context
- Third-party API access

**OAuth 2.0 Grant Types:**

1. **Authorization Code Flow**
   - Most secure flow
   - Redirects user to authorization server
   - Returns authorization code exchanged for token
   - Suitable for web applications

2. **Implicit Flow**
   - Simplified flow for browser-based applications
   - Returns access token directly
   - Less secure than Authorization Code

3. **Client Credentials Flow**
   - For service-to-service authentication
   - Client authenticates using client ID and secret
   - No user context

4. **Resource Owner Password Flow**
   - Clients collect username/password directly
   - Exchanges credentials for token
   - Only for trusted clients

#### 4. JWT (JSON Web Tokens)

Self-contained tokens that carry user data and are cryptographically signed.

**Structure:**
- Header: Token type and algorithm
- Payload: Claims (data)
- Signature: Verification

**Implementation:**
- Used with Bearer authentication
- Can be stateless (no server-side storage)
- Validate signature and expiration

**Best for:**
- Stateless authentication
- Microservices architecture
- Applications requiring claims/attributes

#### 5. OpenID Connect

Identity layer on top of OAuth 2.0 that adds authentication.

**Implementation:**
- Extends OAuth with ID tokens
- Standardized user information
- Single sign-on capabilities

**Best for:**
- Applications requiring user identity
- Enterprise SSO integrations
- Federated authentication

### Authorization Strategies

#### 1. Role-Based Access Control (RBAC)

Access decisions based on roles assigned to users.

**Implementation:**
- Assign roles to users
- Define permissions for roles
- Check role permissions for each operation

**Example:**
```json
{
  "roles": ["admin", "editor"],
  "permissions": {
    "admin": ["read", "write", "delete"],
    "editor": ["read", "write"]
  }
}
```

#### 2. Attribute-Based Access Control (ABAC)

Access decisions based on attributes of user, resource, action, and environment.

**Implementation:**
- Define policies using attributes
- Evaluate policies against request context
- More flexible than RBAC but more complex

**Example Policy:**
```
If (user.department == resource.owningDepartment || user.role == "admin")
  AND action == "read"
  AND environment.time BETWEEN 9AM AND 5PM
THEN allow
```

#### 3. Scopes (OAuth 2.0)

Permissions defined in tokens that limit what the client can do.

**Implementation:**
- Define scopes in authorization server
- Request specific scopes during authentication
- Validate scopes for each operation

**Example:**
```
Authorization: Bearer eyJhbG...
Scopes: "read:users write:users"
```

### Security Best Practices

```
┌─────────────────────────────────────────────────────────────┐
│                 REST API SECURITY FRAMEWORK                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 SECURITY LAYERS                         │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │ TRANSPORT   │    │APPLICATION  │    │    DATA     │ │ │
│  │  │ SECURITY    │    │  SECURITY   │    │  SECURITY   │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ • HTTPS/TLS │    │ • Auth      │    │ • Encryption│ │ │
│  │  │ • Cert      │    │ • JWT       │    │ • Hashing   │ │ │
│  │  │   Validation│    │ • Rate      │    │ • Masking   │ │ │
│  │  │ • HSTS      │    │   Limiting  │    │ • Validation│ │ │
│  │  │ • Cipher    │    │ • Input     │    │ • Sanitize  │ │ │
│  │  │   Suites    │    │   Validation│    │             │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              AUTHENTICATION FLOW                        │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   CLIENT    │    │ API SERVER  │    │AUTH SERVICE │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ 1. Login    │───▶│ 2. Forward  │───▶│ 3. Validate │ │ │
│  │  │ Credentials │    │ to Auth     │    │ Credentials │ │ │
│  │  │             │    │             │◀───│             │ │ │
│  │  │             │◀───│ 4. Return   │    │ 5. Generate │ │ │
│  │  │ 6. Store    │    │ JWT Token   │    │ JWT + Refresh│ │ │
│  │  │ Tokens      │    │             │    │ Token       │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ 7. API      │───▶│ 8. Validate │    │             │ │ │
│  │  │ Request +   │    │ JWT Token   │    │             │ │ │
│  │  │ Bearer Token│    │             │    │             │ │ │
│  │  │             │    │ 9. Check    │    │             │ │ │
│  │  │             │    │ Permissions │    │             │ │ │
│  │  │             │◀───│             │    │             │ │ │
│  │  │ 10. API     │    │ 11. Return  │    │             │ │ │
│  │  │ Response    │    │ Data        │    │             │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 SECURITY HEADERS                        │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │              RESPONSE HEADERS                       │ │ │
│  │  │                                                     │ │ │
│  │  │  HTTP/1.1 200 OK                                    │ │ │
│  │  │  Content-Type: application/json                     │ │ │
│  │  │  Strict-Transport-Security: max-age=31536000        │ │ │ │
│  │  │  Content-Security-Policy: default-src 'self'        │ │ │ │
│  │  │  X-Content-Type-Options: nosniff                    │ │ │ │
│  │  │  X-Frame-Options: DENY                              │ │ │ │
│  │  │  X-XSS-Protection: 1; mode=block                    │ │ │ │
│  │  │  Referrer-Policy: strict-origin-when-cross-origin   │ │ │ │
│  │  │  Cache-Control: no-store, no-cache                  │ │ │ │
│  │  │                                                     │ │ │
│  │  │  Purpose:                                           │ │ │ │
│  │  │  • Prevent XSS attacks                              │ │ │ │
│  │  │  • Block clickjacking                               │ │ │ │
│  │  │  • Enforce HTTPS                                    │ │ │ │
│  │  │  • Control content loading                          │ │ │ │
│  │  │  • Prevent MIME sniffing                            │ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 INPUT VALIDATION                        │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │              VALIDATION PIPELINE                    │ │ │
│  │  │                                                     │ │ │
│  │  │  Incoming Request                                   │ │ │ │
│  │  │         │                                           │ │ │ │
│  │  │         ▼                                           │ │ │ │
│  │  │  ┌─────────────┐                                    │ │ │ │
│  │  │  │1. Schema    │ ← JSON Schema Validation           │ │ │ │
│  │  │  │ Validation  │                                    │ │ │ │
│  │  │  └─────────────┘                                    │ │ │ │
│  │  │         │                                           │ │ │ │
│  │  │         ▼                                           │ │ │ │
│  │  │  ┌─────────────┐                                    │ │ │ │
│  │  │  │2. Type      │ ← String, Number, Boolean         │ │ │ │
│  │  │  │ Validation  │                                    │ │ │ │
│  │  │  └─────────────┘                                    │ │ │ │
│  │  │         │                                           │ │ │ │
│  │  │         ▼                                           │ │ │ │
│  │  │  ┌─────────────┐                                    │ │ │ │
│  │  │  │3. Range     │ ← Min/Max Length, Value           │ │ │ │
│  │  │  │ Validation  │                                    │ │ │ │
│  │  │  └─────────────┘                                    │ │ │ │
│  │  │         │                                           │ │ │ │
│  │  │         ▼                                           │ │ │ │
│  │  │  ┌─────────────┐                                    │ │ │ │
│  │  │  │4. Pattern   │ ← Regex, Email, URL               │ │ │ │
│  │  │  │ Validation  │                                    │ │ │ │
│  │  │  └─────────────┘                                    │ │ │ │
│  │  │         │                                           │ │ │ │
│  │  │         ▼                                           │ │ │ │
│  │  │  ┌─────────────┐                                    │ │ │ │
│  │  │  │5. Sanitize  │ ← Remove/Escape Special Chars     │ │ │ │
│  │  │  │ Input       │                                    │ │ │ │
│  │  │  └─────────────┘                                    │ │ │ │
│  │  │         │                                           │ │ │ │
│  │  │         ▼                                           │ │ │ │
│  │  │  ┌─────────────┐                                    │ │ │ │
│  │  │  │6. Business  │ ← Domain-Specific Rules           │ │ │ │
│  │  │  │ Validation  │                                    │ │ │ │
│  │  │  └─────────────┘                                    │ │ │ │
│  │  │         │                                           │ │ │ │
│  │  │         ▼                                           │ │ │ │
│  │  │  Valid Request → Process                            │ │ │ │
│  │  │                                                     │ │ │
│  │  │  Any Failure → Return 400 Bad Request               │ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 1. Always Use HTTPS

- Encrypt all API traffic using TLS
- Configure proper cipher suites and protocols
- Use HSTS headers to prevent downgrade attacks

#### 2. Token Security

- Set short expiration times (5-15 minutes for sensitive operations)
- Use refresh tokens for longer sessions
- Implement token revocation
- Store tokens securely (HttpOnly cookies, secure storage)

#### 3. Rate Limiting

- Limit requests per client/user
- Use token bucket or leaky bucket algorithms
- Return 429 Too Many Requests with Retry-After header

#### 4. Input Validation

- Validate all inputs (parameters, headers, body)
- Use schema validation (JSON Schema)
- Sanitize inputs to prevent injection attacks

#### 5. Security Headers

- Implement security headers:
  - `Content-Security-Policy`
  - `X-XSS-Protection`
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: DENY`

#### 6. Sensitive Data Handling

- Don't include sensitive data in URLs
- Mask sensitive data in logs
- Follow data privacy regulations (GDPR, CCPA)

## AWS Implementation

AWS offers multiple options for implementing RESTful APIs. This section covers the main services, their features, and best practices for each approach.

```
┌─────────────────────────────────────────────────────────────┐
│                 AWS REST API IMPLEMENTATION                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              SERVERLESS API PATTERN                     │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   CLIENT    │    │ API GATEWAY │    │   LAMBDA    │ │ │
│  │  │             │    │             │    │ FUNCTIONS   │ │ │
│  │  │ HTTP Request│───▶│ 1. Validate │───▶│             │ │ │
│  │  │ /api/users  │    │ 2. Transform│    │ ┌─────────┐ │ │ │
│  │  │             │    │ 3. Route    │    │ │getUsersλ│ │ │ │
│  │  │             │    │ 4. Auth     │    │ └─────────┘ │ │ │
│  │  │             │    │ 5. Rate     │    │ ┌─────────┐ │ │ │
│  │  │             │    │   Limit     │    │ │createUserλ│ │ │
│  │  │             │    │             │    │ └─────────┘ │ │ │
│  │  │ JSON        │◀───│ 6. Response │◀───│ ┌─────────┐ │ │ │
│  │  │ Response    │    │   Transform │    │ │updateUserλ│ │ │
│  │  └─────────────┘    └─────────────┘    │ └─────────┘ │ │ │
│  │                                        └─────────────┘ │ │
│  │                                               │         │ │
│  │                                               ▼         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   COGNITO   │    │  DYNAMODB   │    │     S3      │ │ │
│  │  │USER POOLS   │    │             │    │             │ │ │
│  │  │             │    │ • User Data │    │ • Static    │ │ │
│  │  │ • Auth      │    │ • Sessions  │    │   Assets    │ │ │
│  │  │ • JWT       │    │ • App Data  │    │ • Files     │ │ │
│  │  │ • Users     │    │             │    │ • Backups   │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │               CONTAINER-BASED PATTERN                   │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │APPLICATION  │    │     ALB     │    │    ECS      │ │ │
│  │  │LOAD BALANCER│    │             │    │  FARGATE    │ │ │
│  │  │             │    │ • SSL Term  │    │             │ │ │
│  │  │ • Route 53  │───▶│ • Health    │───▶│ ┌─────────┐ │ │ │
│  │  │ • CloudFront│    │   Check     │    │ │REST API │ │ │ │
│  │  │ • WAF       │    │ • Sticky    │    │ │Container│ │ │ │
│  │  │             │    │   Sessions  │    │ └─────────┘ │ │ │
│  │  └─────────────┘    └─────────────┘    │ ┌─────────┐ │ │ │
│  │                                        │ │REST API │ │ │ │
│  │                                        │ │Container│ │ │ │
│  │                                        │ └─────────┘ │ │ │
│  │                                        └─────────────┘ │ │ │
│  │                                               │         │ │
│  │                                               ▼         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │     RDS     │    │ELASTICACHE  │    │   SECRETS   │ │ │
│  │  │             │    │             │    │  MANAGER    │ │ │
│  │  │ • PostgreSQL│    │ • Redis     │    │             │ │ │
│  │  │ • Multi-AZ  │    │ • Session   │    │ • DB Creds  │ │ │
│  │  │ • Read      │    │   Store     │    │ • API Keys  │ │ │
│  │  │   Replicas  │    │ • Cache     │    │ • Rotation  │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Amazon API Gateway

API Gateway is a fully managed service for creating, publishing, maintaining, monitoring, and securing REST, HTTP, and WebSocket APIs.

#### Key Features

1. **API Types**
   - REST APIs: Traditional RESTful APIs with features like caching
   - HTTP APIs: Lightweight, lower latency APIs with fewer features
   - WebSocket APIs: For two-way communication applications

2. **Integration Types**
   - Lambda: Serverless backend integration (most common)
   - HTTP: Integration with existing HTTP endpoints
   - AWS Service: Direct integration with other AWS services
   - Mock: Return static responses without backend
   - VPC Link: Connect to private resources in VPC

3. **Features**
   - Request/response transformation
   - Request validation
   - API keys and usage plans
   - Throttling and rate limiting
   - Caching responses
   - Custom domain names
   - Stages and deployments
   - Canary deployments

#### Implementation Patterns

##### 1. Serverless API (Lambda Integration)

The most common pattern for REST APIs on AWS combines API Gateway with Lambda functions.

**Architecture:**
1. Client makes request to API Gateway endpoint
2. API Gateway validates and transforms request if needed
3. API Gateway invokes Lambda function
4. Lambda processes request and returns response
5. API Gateway transforms response if needed and returns to client

**Example: Create a User API Endpoint**

```yaml
# API Gateway resource configuration
Resources:
  UserApi:
    Type: AWS::ApiGateway::RestApi
    Properties:
      Name: UserAPI
      
  UsersResource:
    Type: AWS::ApiGateway::Resource
    Properties:
      RestApiId: !Ref UserApi
      ParentId: !GetAtt UserApi.RootResourceId
      PathPart: 'users'
      
  CreateUserMethod:
    Type: AWS::ApiGateway::Method
    Properties:
      RestApiId: !Ref UserApi
      ResourceId: !Ref UsersResource
      HttpMethod: POST
      AuthorizationType: COGNITO_USER_POOLS
      Integration:
        Type: AWS_PROXY
        IntegrationHttpMethod: POST
        Uri: !Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${CreateUserFunction.Arn}/invocations

# Lambda function
  CreateUserFunction:
    Type: AWS::Lambda::Function
    Properties:
      Handler: index.handler
      Runtime: nodejs14.x
      Code:
        ZipFile: |
          exports.handler = async (event) => {
            // Parse the incoming request body
            const body = JSON.parse(event.body);
            
            // Create user logic here
            
            // Return response
            return {
              statusCode: 201,
              headers: {
                "Content-Type": "application/json"
              },
              body: JSON.stringify({ id: "123", name: body.name })
            };
          };
```

##### 2. Microservices API Architecture

For larger applications, using API Gateway with multiple backend services organized by domain.

**Architecture:**
- API Gateway serves as the single entry point
- Routes requests to appropriate microservices based on path
- Each microservice has its own Lambda functions or containers
- Use API Gateway resource policies for access control

**Benefits:**
- Single endpoint for clients
- Independent deployment of each service
- Centralized authentication and authorization
- API composition across services

##### 3. Direct AWS Service Integration

API Gateway can directly integrate with AWS services without Lambda.

**Example: DynamoDB Integration**

```yaml
DynamoDBGetItem:
  Type: AWS::ApiGateway::Method
  Properties:
    RestApiId: !Ref MyApi
    ResourceId: !Ref ItemsResource
    HttpMethod: GET
    AuthorizationType: IAM
    Integration:
      Type: AWS
      IntegrationHttpMethod: POST
      Uri: !Sub arn:aws:apigateway:${AWS::Region}:dynamodb:action/GetItem
      Credentials: !GetAtt ApiGatewayRole.Arn
      RequestTemplates:
        application/json: |
          {
            "TableName": "Items",
            "Key": {
              "id": {
                "S": "$method.request.querystring.id"
              }
            }
          }
      IntegrationResponses:
        - StatusCode: 200
          ResponseTemplates:
            application/json: |
              #set($item = $input.path('$.Item'))
              {
                "id": "$item.id.S",
                "name": "$item.name.S"
              }
```

### Authentication and Authorization Options

AWS provides multiple options for securing your REST APIs:

#### 1. Amazon Cognito User Pools

Fully managed user directory with built-in authentication flow.

**Implementation:**
```yaml
# API Gateway authorizer using Cognito
UserPoolAuthorizer:
  Type: AWS::ApiGateway::Authorizer
  Properties:
    Name: CognitoUserPoolAuthorizer
    RestApiId: !Ref MyApi
    Type: COGNITO_USER_POOLS
    IdentitySource: method.request.header.Authorization
    ProviderARNs:
      - !GetAtt UserPool.Arn

# Associate with API method
ApiMethod:
  Type: AWS::ApiGateway::Method
  Properties:
    AuthorizationType: COGNITO_USER_POOLS
    AuthorizerId: !Ref UserPoolAuthorizer
    # Other properties
```

#### 2. Lambda Authorizer

Custom authorization logic with Lambda functions.

**Implementation:**
```yaml
# Lambda authorizer function
AuthorizerFunction:
  Type: AWS::Lambda::Function
  Properties:
    Handler: index.handler
    Runtime: nodejs14.x
    Code:
      ZipFile: |
        exports.handler = async (event) => {
          // Parse token from event.authorizationToken
          // Verify token and determine permissions
          
          return {
            principalId: "user-id",
            policyDocument: {
              Version: "2012-10-17",
              Statement: [{
                Action: "execute-api:Invoke",
                Effect: "Allow",
                Resource: event.methodArn
              }]
            },
            context: { userId: "123", role: "admin" }
          };
        };

# API Gateway authorizer
CustomAuthorizer:
  Type: AWS::ApiGateway::Authorizer
  Properties:
    RestApiId: !Ref MyApi
    Name: CustomAuthorizer
    Type: TOKEN
    AuthorizerUri: !Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${AuthorizerFunction.Arn}/invocations
    IdentitySource: method.request.header.Authorization
```

#### 3. IAM Authentication

Use AWS Identity and Access Management for API access control.

**Implementation:**
```yaml
ApiMethod:
  Type: AWS::ApiGateway::Method
  Properties:
    RestApiId: !Ref MyApi
    ResourceId: !Ref MyResource
    HttpMethod: GET
    AuthorizationType: AWS_IAM
    # Other properties
```

### API Gateway Best Practices

#### 1. Performance Optimization

- **Enable Caching**: Cache responses to reduce backend load
- **Use HTTP APIs**: For lower latency and cost when advanced features aren't needed
- **Minimize Payload Size**: Return only necessary data
- **Use Regional Endpoints**: For lower latency within a region
- **Consider Edge Optimization**: For globally distributed APIs

#### 2. Security

- **Use TLS**: Always enable HTTPS endpoints
- **Implement Rate Limiting**: Protect against abuse
- **Set Proper Timeouts**: Avoid long-running connections
- **Use Resource Policies**: Restrict access based on source IP, VPC, etc.
- **Enable WAF**: For additional protection against common attacks

#### 3. Monitoring and Troubleshooting

- **Enable CloudWatch Logs**: For API Gateway access logs
- **Set Up Metrics**: Monitor latency, error rates, cache hits
- **Configure Alarms**: For abnormal patterns
- **Use X-Ray**: For tracing requests across services

#### 4. Development and Deployment

- **Use Swagger/OpenAPI**: Define API using OpenAPI specification
- **Implement Stages**: For development, testing, and production
- **Use Canary Deployments**: For safe rollouts
- **Version APIs**: Use path versioning for major changes

### AWS AppSync (GraphQL Alternative)

For more complex data requirements, AWS AppSync provides a managed GraphQL service that can complement or replace REST APIs.

**Key Benefits:**
- Real-time data synchronization
- Offline data access
- Fine-grained data fetching
- Schema-driven development
- Multiple data sources in single request

**When to Choose AppSync over API Gateway:**
- Complex data relationships
- Real-time updates needed
- Mobile applications with offline requirements
- Reducing number of API calls
- Flexible querying needs

### Alternative Implementation: AWS Lambda Function URLs

For simpler APIs, Lambda Function URLs provide HTTP endpoints directly to Lambda functions without API Gateway.

**Benefits:**
- Simpler setup
- Lower cost
- Dual-stack IPv4/IPv6 support
- Custom domain support

**Example:**
```yaml
MyFunction:
  Type: AWS::Lambda::Function
  Properties:
    # Function properties...
    
MyFunctionUrl:
  Type: AWS::Lambda::Url
  Properties:
    TargetFunctionArn: !GetAtt MyFunction.Arn
    AuthType: NONE  # or AWS_IAM
    Cors:
      AllowOrigins:
        - '*'
      AllowMethods:
        - GET
        - POST
      AllowHeaders:
        - Content-Type
      MaxAge: 300
```

### REST API Design Pattern: Serverless CRUD Application

Below is a complete example of a serverless REST API CRUD application using AWS services:

**Components:**
- API Gateway: REST API interface
- Lambda: Business logic
- DynamoDB: Data storage
- Cognito: Authentication
- CloudWatch: Monitoring and logging

**Architecture Diagram:**
```
┌─────────┐       ┌─────────────┐       ┌───────────┐       ┌───────────┐
│  Client │───────│ API Gateway │───────│   Lambda  │───────│ DynamoDB  │
└─────────┘       └─────────────┘       └───────────┘       └───────────┘
                         │                    │
                         │                    │
                  ┌──────┴──────┐      ┌─────┴─────┐
                  │   Cognito   │      │ CloudWatch │
                  └─────────────┘      └───────────┘
```

This architecture follows RESTful principles with:
- Resource-based design (/items endpoint)
- HTTP methods for CRUD operations
- Authentication and authorization
- Stateless architecture
- Scalable components

## Decision Matrix

```
┌─────────────────────────────────────────────────────────────┐
│                REST API DESIGN DECISION MATRIX              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              IMPLEMENTATION APPROACH                    │ │
│  │                                                         │ │
│  │  Approach    │Complexity│Scalability│Cost    │Use Case  │ │
│  │  ──────────  │─────────│──────────│───────│─────────  │ │
│  │  Serverless  │ ✅ Low   │ ✅ Auto   │ ✅ Low │Startups  │ │
│  │  Containers  │ ⚠️ Medium│ ✅ High   │ ⚠️ Med │Enterprise│ │
│  │  Microservices│❌ High  │ ✅ High   │ ❌ High│Large Org │ │
│  │  Monolith    │ ✅ Low   │ ❌ Limited│ ✅ Low │Simple    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              VERSIONING STRATEGY                        │ │
│  │                                                         │ │
│  │  Strategy    │Visibility│RESTful│Complexity│Browser    │ │
│  │  ──────────  │─────────│──────│─────────│──────────  │ │
│  │  URI Path    │ ✅ High  │ ❌ No │ ✅ Low   │ ✅ Easy   │ │
│  │  Query Param │ ⚠️ Medium│ ⚠️ OK │ ✅ Low   │ ✅ Easy   │ │
│  │  Header      │ ❌ Hidden│ ✅ Yes│ ⚠️ Med   │ ❌ Hard   │ │
│  │  Accept      │ ❌ Hidden│ ✅ Yes│ ❌ High  │ ❌ Hard   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              AUTHENTICATION METHOD                      │ │
│  │                                                         │ │
│  │  Method      │Security │Complexity│Scalability│Mobile  │ │
│  │  ──────────  │────────│─────────│──────────│───────  │ │
│  │  API Keys    │ ⚠️ Basic│ ✅ Low   │ ✅ High   │ ✅ Good │ │
│  │  JWT         │ ✅ High │ ⚠️ Medium│ ✅ High   │ ✅ Good │ │
│  │  OAuth 2.0   │ ✅ High │ ❌ High  │ ✅ High   │ ✅ Good │ │
│  │  Basic Auth  │ ❌ Poor │ ✅ Low   │ ✅ High   │ ⚠️ OK   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Selection Guidelines

**Choose Serverless When:**
- Rapid prototyping needed
- Variable traffic patterns  
- Small to medium APIs
- Minimal operational overhead desired

**Choose JWT Authentication When:**
- Stateless architecture required
- Mobile applications involved
- Microservices communication
- Cross-domain requests needed
