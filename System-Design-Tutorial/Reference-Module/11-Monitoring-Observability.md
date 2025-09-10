# Monitoring and Observability in System Design

## Overview

Monitoring and observability are critical for maintaining reliable, performant systems at scale. While monitoring tells you when something is wrong, observability helps you understand why it's wrong.

```
┌─────────────────────────────────────────────────────────────┐
│              MONITORING vs OBSERVABILITY                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   TRADITIONAL MONITORING                │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   SYSTEM    │    │   METRICS   │    │   ALERTS    │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ • CPU: 85%  │───▶│ • Threshold │───▶│ • CPU High  │ │ │
│  │  │ • Memory:90%│    │   Based     │    │ • Memory    │ │ │
│  │  │ • Disk: 70% │    │ • Known     │    │   Critical  │ │ │
│  │  │ • Network   │    │   Unknowns  │    │ • Disk      │ │ │
│  │  │   Latency   │    │ • Reactive  │    │   Warning   │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │                                                         │ │
│  │  Answers: "WHAT is happening?"                          │ │
│  │  • System is slow                                       │ │
│  │  • Error rate increased                                 │ │
│  │  • Resource utilization high                            │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    OBSERVABILITY                        │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   METRICS   │    │    LOGS     │    │   TRACES    │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ • Business  │    │ • Structured│    │ • Request   │ │ │
│  │  │   KPIs      │    │ • Contextual│    │   Journey   │ │ │
│  │  │ • SLIs      │    │ • Searchable│    │ • Service   │ │ │
│  │  │ • Custom    │    │ • Correlated│    │   Map       │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │         │                   │                   │      │ │
│  │         └───────────────────┼───────────────────┘      │ │
│  │                             │                          │ │
│  │                             ▼                          │ │
│  │                    ┌─────────────┐                     │ │
│  │                    │ CORRELATION │                     │ │
│  │                    │   ENGINE    │                     │ │
│  │                    │             │                     │ │
│  │                    │ • Pattern   │                     │ │
│  │                    │   Detection │                     │ │
│  │                    │ • Root Cause│                     │ │
│  │                    │   Analysis  │                     │ │
│  │                    │ • Predictive│                     │ │
│  │                    │   Insights  │                     │ │
│  │                    └─────────────┘                     │ │
│  │                                                         │ │
│  │  Answers: "WHY is this happening?"                      │ │
│  │  • Which service caused the slowdown                    │ │
│  │  • What user action triggered the error                 │ │
│  │  • How the issue propagated through the system         │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 OBSERVABILITY MATURITY                  │ │
│  │                                                         │ │
│  │  Level 1: Basic Monitoring                              │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ • Infrastructure metrics                            │ │ │
│  │  │ • Simple alerts                                     │ │ │
│  │  │ • Manual investigation                              │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                             │                          │ │
│  │                             ▼                          │ │
│  │  Level 2: Application Monitoring                        │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ • Application metrics                               │ │ │
│  │  │ • Structured logging                                │ │ │
│  │  │ • Basic dashboards                                  │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                             │                          │ │
│  │                             ▼                          │ │
│  │  Level 3: Full Observability                           │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ • Distributed tracing                               │ │ │
│  │  │ • Correlation across signals                        │ │ │
│  │  │ • Proactive insights                                │ │ │
│  │  │ • Business context integration                      │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Table of Contents
- [Monitoring vs Observability](#monitoring-vs-observability)
- [The Three Pillars of Observability](#the-three-pillars-of-observability)
- [Monitoring Strategies](#monitoring-strategies)
- [Alerting and Incident Response](#alerting-and-incident-response)
- [AWS Monitoring Services](#aws-monitoring-services)
- [Performance Monitoring](#performance-monitoring)
- [Distributed Tracing](#distributed-tracing)
- [Best Practices](#best-practices)

## Monitoring vs Observability

### Understanding the Difference

**Monitoring** is about collecting, aggregating, and analyzing known metrics to determine system health. It answers the question "Is my system working?"

**Observability** is about understanding system behavior from external outputs. It answers the question "Why is my system behaving this way?"

#### Monitoring Example
```
Traditional Monitoring Approach:
- CPU usage > 80% → Alert
- Memory usage > 90% → Alert  
- Response time > 2 seconds → Alert
- Error rate > 1% → Alert

Result: You know something is wrong, but not why
```

#### Observability Example
```
Observability Approach:
- High CPU detected
- Trace shows slow database queries
- Logs reveal specific query patterns
- Metrics show correlation with user behavior
- Custom events show business context

Result: You understand the root cause and business impact
```

### The Evolution from Monitoring to Observability

#### Traditional Monitoring Limitations
**Known Unknowns:** Traditional monitoring works well for predictable failure modes
- Server crashes
- Network outages  
- Resource exhaustion
- Predefined error conditions

**Unknown Unknowns:** Modern distributed systems create unpredictable failure modes
- Emergent behaviors from service interactions
- Performance degradation from subtle bugs
- Cascading failures across microservices
- Race conditions in distributed transactions

#### Why Observability Matters
**Complex System Characteristics:**
- Hundreds of microservices
- Dynamic infrastructure (containers, serverless)
- Distributed state and transactions
- Multiple programming languages and frameworks
- Third-party service dependencies

**Business Impact:**
- Faster incident resolution (MTTR reduction)
- Proactive issue prevention
- Better understanding of user experience
- Data-driven optimization decisions

## The Three Pillars of Observability

```
┌─────────────────────────────────────────────────────────────┐
│               THREE PILLARS OF OBSERVABILITY                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    PILLAR 1: METRICS                    │ │
│  │                  "WHAT is happening?"                   │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │INFRASTRUCTURE│ │APPLICATION  │  │  BUSINESS   │     │ │
│  │  │   METRICS    │  │  METRICS    │  │  METRICS    │     │ │
│  │  │              │  │             │  │             │     │ │
│  │  │ • CPU: 75%   │  │ • Req/sec   │  │ • Revenue   │     │ │
│  │  │ • Memory:60% │  │ • Latency   │  │ • Orders    │     │ │
│  │  │ • Disk I/O   │  │ • Error %   │  │ • Users     │     │ │
│  │  │ • Network    │  │ • Throughput│  │ • Conversion│     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │                                                         │ │
│  │  Time Series Data: [timestamp, value, labels]          │ │
│  │  Example: http_requests_total{method="GET"} 1500        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    PILLAR 2: LOGS                       │ │
│  │                 "WHAT happened when?"                   │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │ STRUCTURED  │  │ APPLICATION │  │   AUDIT     │     │ │
│  │  │    LOGS     │  │    LOGS     │  │   LOGS      │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │{            │  │ ERROR: DB   │  │ User login: │     │ │
│  │  │"timestamp": │  │ connection  │  │ user_123    │     │ │
│  │  │"2025-09-10" │  │ timeout     │  │ IP: 1.2.3.4 │     │ │
│  │  │"level":"ERR"│  │ Query: SEL..│  │ Status: OK  │     │ │
│  │  │"service":"  │  │ Duration:5s │  │ Method: SSO │     │ │
│  │  │ user-api"   │  │             │  │             │     │ │
│  │  │"message":"  │  │             │  │             │     │ │
│  │  │ Auth failed"│  │             │  │             │     │ │
│  │  │}            │  │             │  │             │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │                                                         │ │
│  │  Searchable, Contextual, Timestamped Events            │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   PILLAR 3: TRACES                      │ │
│  │                "HOW did this happen?"                   │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │              DISTRIBUTED TRACE                      │ │ │
│  │  │                                                     │ │ │
│  │  │  User Request → API Gateway → Auth Service          │ │ │
│  │  │       │              │              │               │ │ │
│  │  │       │              │              ▼               │ │ │
│  │  │       │              │         User Database        │ │ │
│  │  │       │              │              │               │ │ │
│  │  │       │              ▼              │               │ │ │
│  │  │       │         Order Service ◀─────┘               │ │ │
│  │  │       │              │                              │ │ │
│  │  │       │              ▼                              │ │ │
│  │  │       │         Payment Service                     │ │ │
│  │  │       │              │                              │ │ │
│  │  │       ▼              ▼                              │ │ │
│  │  │   Response ◀─── Final Response                      │ │ │
│  │  │                                                     │ │ │
│  │  │  Trace ID: abc123                                   │ │ │
│  │  │  Total Duration: 250ms                              │ │ │
│  │  │  Spans: 7 services, 12 operations                  │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  Request Journey: Parent-Child Span Relationships      │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 CORRELATION POWER                       │ │
│  │                                                         │ │
│  │  Metrics Alert: "API latency > 2s"                     │ │
│  │         │                                               │ │
│  │         ▼                                               │ │
│  │  Logs Query: "Show errors in last 5 minutes"           │ │
│  │         │                                               │ │
│  │         ▼                                               │ │
│  │  Trace Analysis: "Database queries taking 3s"          │ │
│  │         │                                               │ │
│  │         ▼                                               │ │
│  │  Root Cause: "Slow query on user_orders table"         │ │
│  │                                                         │ │
│  │  Resolution: Add index, optimize query                  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1. Metrics (What is happening?)

Metrics are numerical measurements collected over time intervals, providing quantitative insights into system behavior.

```
┌─────────────────────────────────────────────────────────────┐
│                    METRICS ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 METRIC COLLECTION                       │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   SYSTEM    │    │APPLICATION  │    │  BUSINESS   │ │ │
│  │  │  METRICS    │───▶│   METRICS   │───▶│  METRICS    │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ • CPU: 75%  │    │ • RPS: 1000 │    │ • Revenue:  │ │ │
│  │  │ • Memory:   │    │ • Latency:  │    │   $50K/day  │ │ │
│  │  │   60%       │    │   150ms     │    │ • Users:    │ │ │
│  │  │ • Disk I/O: │    │ • Errors:   │    │   10K active│ │ │
│  │  │   500 IOPS  │    │   2%        │    │ • Conversion│ │ │
│  │  │ • Network:  │    │ • Queue:    │    │   Rate: 3.5%│ │ │
│  │  │   100 Mbps  │    │   20 depth  │    │             │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │         │                   │                   │      │ │
│  │         └───────────────────┼───────────────────┘      │ │
│  │                             │                          │ │
│  │                             ▼                          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                METRIC PROCESSING                        │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │ COLLECTION  │    │AGGREGATION  │    │   STORAGE   │ │ │
│  │  │             │───▶│             │───▶│             │ │ │
│  │  │ • Agents    │    │ • Sum       │    │ • Time      │ │ │
│  │  │ • Exporters │    │ • Average   │    │   Series    │ │ │
│  │  │ • Push/Pull │    │ • Min/Max   │    │ • Retention │ │ │
│  │  │ • Sampling  │    │ • Percentiles│   │ • Compression│ │ │
│  │  │ • Buffering │    │ • Rate      │    │ • Indexing  │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │         │                   │                   │      │ │
│  │         └───────────────────┼───────────────────┘      │ │
│  │                             │                          │ │
│  │                             ▼                          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │               METRIC VISUALIZATION                      │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │ DASHBOARDS  │    │   ALERTS    │    │  REPORTS    │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ • Real-time │    │ • Thresholds│    │ • Historical│ │ │
│  │  │   Charts    │    │ • Anomaly   │    │   Trends    │ │ │
│  │  │ • Heat Maps │    │   Detection │    │ • Capacity  │ │ │
│  │  │ • Gauges    │    │ • Escalation│    │   Planning  │ │ │
│  │  │ • Tables    │    │ • Notification│  │ • SLA       │ │ │
│  │  │ • Custom    │    │ • Runbooks  │    │   Reports   │ │ │
│  │  │   Views     │    │             │    │             │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Types of Metrics

**System Metrics:**
- **CPU Utilization**: Percentage of processing capacity used
- **Memory Usage**: RAM consumption patterns
- **Disk I/O**: Read/write operations and throughput
- **Network Traffic**: Bytes in/out, packet loss, latency

**Application Metrics:**
- **Request Rate**: Requests per second (RPS)
- **Response Time**: Latency percentiles (p50, p95, p99)
- **Error Rate**: Percentage of failed requests
- **Throughput**: Successful operations per unit time

**Business Metrics:**
- **User Registrations**: New users per day/hour
- **Revenue**: Sales volume and conversion rates
- **Feature Usage**: Adoption rates for new features
- **Customer Satisfaction**: NPS scores, support tickets

#### The RED Method (Rate, Errors, Duration)

```
┌─────────────────────────────────────────────────────────────┐
│                    RED METHOD FRAMEWORK                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                      RATE                               │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Requests Per Second (RPS)                           │ │ │
│  │  │                                                     │ │ │
│  │  │  1200 ┤                                             │ │ │
│  │  │  1000 ┤     ██                                      │ │ │
│  │  │   800 ┤   ████                                      │ │ │
│  │  │   600 ┤ ██████                                      │ │ │
│  │  │   400 ┤████████                                     │ │ │
│  │  │   200 ┤████████                                     │ │ │
│  │  │     0 └────────────────────────────────────────     │ │ │
│  │  │       09:00  10:00  11:00  12:00  13:00  14:00     │ │ │
│  │  │                                                     │ │ │
│  │  │ Insights:                                           │ │ │
│  │  │ • Peak traffic at 10:00 AM                          │ │ │
│  │  │ • Steady load throughout day                        │ │ │
│  │  │ • Capacity planning needed for growth               │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                     ERRORS                              │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Error Rate Percentage                               │ │ │
│  │  │                                                     │ │ │
│  │  │   5% ┤                                              │ │ │
│  │  │   4% ┤                                              │ │ │
│  │  │   3% ┤                                              │ │ │
│  │  │   2% ┤     ██                                       │ │ │
│  │  │   1% ┤   ████                                       │ │ │
│  │  │   0% └────────────────────────────────────────      │ │ │
│  │  │      09:00  10:00  11:00  12:00  13:00  14:00      │ │ │
│  │  │                                                     │ │ │
│  │  │ Error Breakdown:                                    │ │ │
│  │  │ • 404 Not Found: 60%                                │ │ │
│  │  │ • 500 Internal Error: 25%                           │ │ │
│  │  │ • 503 Service Unavailable: 15%                      │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    DURATION                             │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Response Time Percentiles (ms)                      │ │ │
│  │  │                                                     │ │ │
│  │  │  500 ┤                                              │ │ │
│  │  │  400 ┤                                              │ │ │
│  │  │  300 ┤                                              │ │ │
│  │  │  200 ┤ ████████████████████████████████████████     │ │ │
│  │  │  100 ┤ ████████████████████████████████████████     │ │ │
│  │  │    0 └────────────────────────────────────────      │ │ │
│  │  │       p50   p75   p90   p95   p99   p99.9          │ │ │
│  │  │                                                     │ │ │
│  │  │ Values:                                             │ │ │
│  │  │ • p50: 45ms   • p95: 180ms                          │ │ │
│  │  │ • p75: 85ms   • p99: 350ms                          │ │ │
│  │  │ • p90: 120ms  • p99.9: 500ms                        │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 RED METHOD ALERTS                       │ │
│  │                                                         │ │
│  │  Alert Conditions:                                      │ │
│  │  ✅ Rate: RPS > 1500 (capacity limit)                   │ │
│  │  ⚠️ Errors: Error rate > 1% (quality threshold)         │ │
│  │  🚨 Duration: p95 > 200ms (performance SLA)             │ │
│  │                                                         │ │
│  │  Correlation Analysis:                                  │ │
│  │  • High error rate correlates with increased duration   │ │
│  │  • Rate spikes precede error increases                  │ │
│  │  • Duration degrades before errors manifest             │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**For Request-Driven Services:**
```
E-commerce API Monitoring:
- Rate: 1,000 requests/second to /api/products
- Errors: 2% error rate (mostly 404s for discontinued products)
- Duration: p95 response time of 150ms

Insight: High error rate indicates catalog sync issues
Action: Investigate product availability service
```

#### The USE Method (Utilization, Saturation, Errors)

```
┌─────────────────────────────────────────────────────────────┐
│                    USE METHOD FRAMEWORK                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   UTILIZATION                           │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │     CPU     │  │   MEMORY    │  │    DISK     │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │    75%      │  │    60%      │  │    45%      │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ ████████    │  │ ██████      │  │ █████       │     │ │
│  │  │ 0%    100%  │  │ 0%    100%  │  │ 0%    100%  │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                   SATURATION                            │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │ CPU QUEUE   │  │ MEMORY SWAP │  │ DISK QUEUE  │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 20 processes│  │ 0 MB/s      │  │ 5 requests  │     │ │
│  │  │ waiting     │  │ swapping    │  │ queued      │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ ⚠️ Warning   │  │ ✅ Good      │  │ ⚠️ Warning   │     │ │
│  │  │ Load > cores│  │ No swapping │  │ I/O bound   │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                     ERRORS                              │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │ CPU ERRORS  │  │MEMORY ERRORS│  │ DISK ERRORS │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 0 thermal   │  │ 0 ECC       │  │ 2 read      │     │ │
│  │  │ throttling  │  │ errors      │  │ errors      │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ ✅ Good      │  │ ✅ Good      │  │ ⚠️ Warning   │     │ │
│  │  │ No issues   │  │ No issues   │  │ Check disk  │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 USE METHOD ANALYSIS                     │ │
│  │                                                         │ │
│  │  Current State:                                         │ │
│  │  • CPU: High utilization (75%) with queue buildup      │ │
│  │  • Memory: Moderate usage (60%) with no swapping       │ │
│  │  • Disk: Low usage (45%) but some I/O errors           │ │
│  │                                                         │ │
│  │  Recommendations:                                       │ │
│  │  1. Investigate CPU-bound processes causing queue      │ │
│  │  2. Monitor disk health due to read errors             │ │
│  │  3. Consider CPU scaling if queue persists             │ │
│  │  4. Memory headroom available for caching              │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**For Resource Monitoring:**
```
Database Server Analysis:
- Utilization: CPU at 75%, Memory at 60%
- Saturation: 20 queries waiting in queue
- Errors: 0.1% connection timeouts

Insight: CPU bound but not saturated, queue indicates bottleneck
Action: Optimize slow queries causing CPU spikes
```

### 2. Logs (What happened in detail?)

Logs provide detailed, timestamped records of discrete events within your system.

```
┌─────────────────────────────────────────────────────────────┐
│                    LOGGING ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 LOG GENERATION                          │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │APPLICATION  │  │   SYSTEM    │  │INFRASTRUCTURE│    │ │
│  │  │    LOGS     │  │    LOGS     │  │    LOGS     │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ • Business  │  │ • OS Events │  │ • Load      │     │ │
│  │  │   Events    │  │ • Security  │  │   Balancer  │     │ │
│  │  │ • User      │  │ • Network   │  │ • Database  │     │ │
│  │  │   Actions   │  │ • Hardware  │  │ • Cache     │     │ │
│  │  │ • Errors    │  │ • Services  │  │ • Message   │     │ │
│  │  │ • Debug     │  │             │  │   Queue     │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │         │                   │                   │      │ │
│  │         └───────────────────┼───────────────────┘      │ │
│  │                             │                          │ │
│  │                             ▼                          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                LOG COLLECTION                           │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   AGENTS    │    │ AGGREGATION │    │ FORWARDING  │ │ │
│  │  │             │───▶│             │───▶│             │ │ │
│  │  │ • Filebeat  │    │ • Logstash  │    │ • Kafka     │ │ │
│  │  │ • Fluentd   │    │ • Fluentd   │    │ • Kinesis   │ │ │
│  │  │ • Vector    │    │ • Vector    │    │ • SQS       │ │ │
│  │  │ • Promtail  │    │ • Rsyslog   │    │ • Direct    │ │ │
│  │  │ • Custom    │    │ • Custom    │    │   Shipping  │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │         │                   │                   │      │ │
│  │         └───────────────────┼───────────────────┘      │ │
│  │                             │                          │ │
│  │                             ▼                          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                LOG PROCESSING                           │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   PARSING   │    │ ENRICHMENT  │    │   STORAGE   │ │ │
│  │  │             │───▶│             │───▶│             │ │ │
│  │  │ • Structure │    │ • Context   │    │ • Elasticsearch│ │
│  │  │ • Extract   │    │ • Metadata  │    │ • Splunk    │ │ │
│  │  │   Fields    │    │ • GeoIP     │    │ • CloudWatch│ │ │
│  │  │ • Normalize │    │ • User      │    │ • S3        │ │ │
│  │  │ • Validate  │    │   Agent     │    │ • BigQuery  │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │         │                   │                   │      │ │
│  │         └───────────────────┼───────────────────┘      │ │
│  │                             │                          │ │
│  │                             ▼                          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                LOG ANALYSIS                             │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   SEARCH    │    │ ANALYTICS   │    │   ALERTS    │ │ │
│  │  │             │    │             │    │             │ │ │
│  │  │ • Full-text │    │ • Patterns  │    │ • Error     │ │ │
│  │  │ • Filters   │    │ • Trends    │    │   Spikes    │ │ │
│  │  │ • Regex     │    │ • Anomalies │    │ • Threshold │ │ │
│  │  │ • Time      │    │ • Correlation│   │   Breaches  │ │ │
│  │  │   Range     │    │ • Aggregation│   │ • Pattern   │ │ │
│  │  │ • Context   │    │             │    │   Matching  │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Log Levels and Usage

```
┌─────────────────────────────────────────────────────────────┐
│                    LOG LEVELS HIERARCHY                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    SEVERITY LEVELS                      │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │    FATAL    │  │    ERROR    │  │    WARN     │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 🚨 Critical │  │ ❌ Failures │  │ ⚠️ Issues    │     │ │
│  │  │ System      │  │ Exceptions  │  │ Degradation │     │ │
│  │  │ Failure     │  │ Failed      │  │ Recoverable │     │ │
│  │  │             │  │ Operations  │  │ Problems    │     │ │
│  │  │ Volume:     │  │             │  │             │     │ │
│  │  │ Very Low    │  │ Volume:     │  │ Volume:     │     │ │
│  │  │ (<0.01%)    │  │ Low (0.1%)  │  │ Medium (1%) │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │    INFO     │  │    DEBUG    │  │    TRACE    │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ ℹ️ Normal    │  │ 🔍 Detailed │  │ 🔬 Verbose   │     │ │
│  │  │ Operations  │  │ Diagnostics │  │ Execution   │     │ │
│  │  │ Business    │  │ Variable    │  │ Flow        │     │ │
│  │  │ Events      │  │ Values      │  │ Step-by-step│     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ Volume:     │  │ Volume:     │  │ Volume:     │     │ │
│  │  │ High (10%)  │  │ Very High   │  │ Extreme     │     │ │
│  │  │             │  │ (50%)       │  │ (90%+)      │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 LOG LEVEL EXAMPLES                      │ │
│  │                                                         │ │
│  │  FATAL: "Database connection pool exhausted, shutting   │ │
│  │         down application"                               │ │
│  │                                                         │ │
│  │  ERROR: "Payment processing failed for order #12345:   │ │
│  │         Credit card declined"                           │ │
│  │                                                         │ │
│  │  WARN:  "API rate limit approaching: 950/1000 requests │ │
│  │         in current window"                              │ │
│  │                                                         │ │
│  │  INFO:  "User john.doe@example.com logged in           │ │
│  │         successfully from IP 192.168.1.100"            │ │
│  │                                                         │ │
│  │  DEBUG: "Cache miss for key 'user:12345', fetching     │ │
│  │         from database"                                  │ │
│  │                                                         │ │
│  │  TRACE: "Entering method processPayment() with         │ │
│  │         parameters: amount=99.99, currency=USD"        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │               PRODUCTION LOG STRATEGY                   │ │
│  │                                                         │ │
│  │  Environment-Based Levels:                              │ │
│  │  • Production: INFO and above (ERROR, WARN, INFO)      │ │
│  │  • Staging: DEBUG and above (all except TRACE)         │ │
│  │  • Development: ALL levels including TRACE             │ │
│  │                                                         │ │
│  │  Dynamic Log Levels:                                    │ │
│  │  • Increase to DEBUG during incidents                  │ │
│  │  • Reduce to ERROR during high load                    │ │
│  │  • Feature flags for component-specific logging        │ │
│  │                                                         │ │
│  │  Sampling Strategies:                                   │ │
│  │  • Sample DEBUG logs (1 in 100)                        │ │
│  │  • Always log ERROR and above                          │ │
│  │  • Adaptive sampling based on volume                   │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**ERROR Level:**
- System failures and exceptions
- Failed business transactions
- Security violations
- **Example**: "Payment processing failed for order #12345: Credit card declined"

**WARN Level:**
- Recoverable errors and degraded performance
- Retry attempts and fallback activations
- Configuration issues
- **Example**: "Database connection pool exhausted, using fallback read replica"

**INFO Level:**
- Normal business operations
- User actions and system state changes
- Performance milestones
- **Example**: "User john@example.com successfully logged in from IP 192.168.1.100"

**DEBUG Level:**
- Detailed execution flow
- Variable values and intermediate states
- Performance timing details
- **Example**: "Processing payment: amount=$99.99, method=credit_card, gateway_response_time=245ms"

#### Structured Logging

```
┌─────────────────────────────────────────────────────────────┐
│              STRUCTURED vs UNSTRUCTURED LOGGING             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                UNSTRUCTURED LOGGING                     │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Raw Log Messages:                                   │ │ │
│  │  │                                                     │ │ │
│  │  │ 2024-01-15 10:30:45 INFO User john@example.com     │ │ │
│  │  │ placed order 12345 for $99.99 using credit card    │ │ │
│  │  │ ending in 4567                                      │ │ │
│  │  │                                                     │ │ │
│  │  │ 2024-01-15 10:31:02 ERROR Payment failed for       │ │ │
│  │  │ order 12346: Insufficient funds                     │ │ │
│  │  │                                                     │ │ │
│  │  │ 2024-01-15 10:31:15 WARN High memory usage: 85%    │ │ │
│  │  │ on server web-01                                    │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  ❌ Problems:                                            │ │
│  │  • Hard to parse and analyze                            │ │
│  │  • Inconsistent formats                                 │ │
│  │  • Difficult to filter and search                      │ │
│  │  • Manual correlation required                          │ │
│  │  • No automated processing                              │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 STRUCTURED LOGGING                      │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ JSON Log Messages:                                  │ │ │
│  │  │                                                     │ │ │
│  │  │ {                                                   │ │ │
│  │  │   "timestamp": "2024-01-15T10:30:45Z",              │ │ │
│  │  │   "level": "INFO",                                  │ │ │
│  │  │   "event": "order_placed",                          │ │ │
│  │  │   "user_email": "john@example.com",                 │ │ │
│  │  │   "order_id": "12345",                              │ │ │
│  │  │   "amount": 99.99,                                  │ │ │
│  │  │   "payment_method": "credit_card",                  │ │ │
│  │  │   "card_last_four": "4567",                         │ │ │
│  │  │   "processing_time_ms": 245,                        │ │ │
│  │  │   "service": "order-service",                       │ │ │
│  │  │   "trace_id": "abc123",                             │ │ │
│  │  │   "span_id": "def456"                               │ │ │
│  │  │ }                                                   │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  ✅ Benefits:                                            │ │
│  │  • Machine-readable format                              │ │
│  │  • Consistent structure                                 │ │
│  │  • Easy filtering and searching                         │ │
│  │  • Automated analysis possible                          │ │
│  │  • Integration with monitoring tools                    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │               STRUCTURED LOG PROCESSING                 │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │   PARSING   │    │ INDEXING    │    │  QUERYING   │ │ │
│  │  │             │───▶│             │───▶│             │ │ │
│  │  │ • Automatic │    │ • Field     │    │ • SQL-like  │ │ │
│  │  │   JSON      │    │   extraction│    │   queries   │ │ │
│  │  │   parsing   │    │ • Type      │    │ • Complex   │ │ │
│  │  │ • Schema    │    │   inference │    │   filters   │ │ │
│  │  │   validation│    │ • Full-text │    │ • Aggregation│ │ │
│  │  │ • Field     │    │   search    │    │ • Real-time │ │ │
│  │  │   extraction│    │ • Time-based│    │   analytics │ │ │
│  │  │             │    │   indexing  │    │             │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │                                                         │ │
│  │  Example Queries:                                       │ │
│  │  • Find all ERROR logs in last hour                     │ │
│  │  • Show payment failures by card type                   │ │
│  │  • Calculate average processing time by service         │ │
│  │  • Identify users with multiple failed orders          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │               LOG CORRELATION EXAMPLE                   │ │
│  │                                                         │ │
│  │  Request Flow with Trace ID: "abc123"                   │ │
│  │                                                         │ │
│  │  API Gateway:                                           │ │
│  │  {"trace_id": "abc123", "event": "request_received"}    │ │
│  │                                                         │ │
│  │  User Service:                                          │ │
│  │  {"trace_id": "abc123", "event": "user_validated"}      │ │
│  │                                                         │ │
│  │  Order Service:                                         │ │
│  │  {"trace_id": "abc123", "event": "order_created"}       │ │
│  │                                                         │ │
│  │  Payment Service:                                       │ │
│  │  {"trace_id": "abc123", "event": "payment_processed"}   │ │
│  │                                                         │ │
│  │  Result: Complete request journey easily traceable      │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Traditional Unstructured Logs:**
```
2024-01-15 10:30:45 INFO User john@example.com placed order 12345 for $99.99 using credit card ending in 4567
```

**Structured Logging (JSON):**
```json
{
  "timestamp": "2024-01-15T10:30:45Z",
  "level": "INFO",
  "event": "order_placed",
  "user_email": "john@example.com",
  "order_id": "12345",
  "amount": 99.99,
  "payment_method": "credit_card",
  "card_last_four": "4567",
  "processing_time_ms": 245
}
```

**Benefits of Structured Logging:**
- Easy filtering and searching
- Automated analysis and alerting
- Integration with monitoring tools
- Consistent format across services

### 3. Traces (How did requests flow through the system?)

Distributed tracing tracks requests as they flow through multiple services, providing end-to-end visibility.

```
┌─────────────────────────────────────────────────────────────┐
│                DISTRIBUTED TRACING ARCHITECTURE             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 SINGLE SERVICE FLOW                     │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │    USER     │───▶│ WEB SERVER  │───▶│  DATABASE   │ │ │
│  │  │   REQUEST   │    │             │    │             │ │ │
│  │  │             │    │ • Process   │    │ • Query     │ │ │
│  │  │ GET /users  │    │   request   │    │ • Return    │ │ │
│  │  │             │    │ • Generate  │    │   data      │ │ │
│  │  │             │    │   response  │    │             │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │                                                         │ │
│  │  ✅ Simple to debug:                                     │ │
│  │  • Linear flow                                          │ │
│  │  • Single log file                                      │ │
│  │  • Clear cause-and-effect                               │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │               MICROSERVICES FLOW                        │ │
│  │                                                         │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐ │ │
│  │  │    USER     │───▶│ API GATEWAY │───▶│    USER     │ │ │
│  │  │   REQUEST   │    │             │    │   SERVICE   │ │ │
│  │  │             │    │ • Route     │    │             │ │ │
│  │  │ POST /order │    │ • Auth      │    │ • Validate  │ │ │
│  │  │             │    │ • Rate      │    │   user      │ │ │
│  │  │             │    │   limit     │    │             │ │ │
│  │  └─────────────┘    └─────────────┘    └─────────────┘ │ │
│  │                             │                   │      │ │
│  │                             ▼                   ▼      │ │
│  │                    ┌─────────────┐    ┌─────────────┐ │ │
│  │                    │   ORDER     │───▶│ INVENTORY   │ │ │
│  │                    │  SERVICE    │    │  SERVICE    │ │ │
│  │                    │             │    │             │ │ │
│  │                    │ • Create    │    │ • Check     │ │ │
│  │                    │   order     │    │   stock     │ │ │
│  │                    │ • Calculate │    │ • Reserve   │ │ │
│  │                    │   total     │    │   items     │ │ │
│  │                    └─────────────┘    └─────────────┘ │ │
│  │                             │                   │      │ │
│  │                             ▼                   ▼      │ │
│  │                    ┌─────────────┐    ┌─────────────┐ │ │
│  │                    │  PAYMENT    │    │NOTIFICATION │ │ │
│  │                    │  SERVICE    │    │  SERVICE    │ │ │
│  │                    │             │    │             │ │ │
│  │                    │ • Process   │    │ • Send      │ │ │
│  │                    │   payment   │    │   email     │ │ │
│  │                    │ • Update    │    │ • SMS       │ │ │
│  │                    │   status    │    │   alert     │ │ │
│  │                    └─────────────┘    └─────────────┘ │ │
│  │                                                         │ │
│  │  ❌ Complex to debug:                                    │ │
│  │  • Multiple services                                    │ │
│  │  • Separate log files                                   │ │
│  │  • Difficult correlation                                │ │
│  │  • Async operations                                     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Understanding Distributed Traces

**Single Service Request:**
```
Simple Web Application:
User Request → Web Server → Database → Response
- Easy to debug with traditional logs
- Clear cause-and-effect relationships
```

**Microservices Request:**
```
E-commerce Order Processing:
User Request → API Gateway → User Service → Order Service → Inventory Service → Payment Service → Notification Service → Response

Challenges:
- Request spans multiple services
- Each service has its own logs
- Difficult to correlate related events
- Complex failure scenarios
```

#### Trace Components

```
┌─────────────────────────────────────────────────────────────┐
│                    TRACE COMPONENTS                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    TRACE HIERARCHY                      │ │
│  │                                                         │ │
│  │  Trace ID: abc123 (Complete request journey)            │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Span 1: API Gateway                                 │ │ │
│  │  │ ├─ Start: 10:30:45.000                              │ │ │
│  │  │ ├─ Duration: 250ms                                  │ │ │
│  │  │ ├─ Operation: handle_request                        │ │ │
│  │  │ └─ Tags: method=POST, endpoint=/order               │ │ │
│  │  │                                                     │ │ │
│  │  │   ┌─────────────────────────────────────────────┐   │ │ │
│  │  │   │ Span 2: User Service                        │   │ │ │
│  │  │   │ ├─ Parent: Span 1                           │   │ │ │
│  │  │   │ ├─ Start: 10:30:45.050                      │   │ │ │
│  │  │   │ ├─ Duration: 45ms                           │   │ │ │
│  │  │   │ ├─ Operation: validate_user                 │   │ │ │
│  │  │   │ └─ Tags: user_id=12345, valid=true          │   │ │ │
│  │  │   └─────────────────────────────────────────────┘   │ │ │
│  │  │                                                     │ │ │
│  │  │   ┌─────────────────────────────────────────────┐   │ │ │
│  │  │   │ Span 3: Order Service                       │   │ │ │
│  │  │   │ ├─ Parent: Span 1                           │   │ │ │
│  │  │   │ ├─ Start: 10:30:45.100                      │   │ │ │
│  │  │   │ ├─ Duration: 120ms                          │   │ │ │
│  │  │   │ ├─ Operation: create_order                  │   │ │ │
│  │  │   │ └─ Tags: order_id=67890, amount=99.99       │   │ │ │
│  │  │   │                                             │   │ │ │
│  │  │   │   ┌─────────────────────────────────────┐   │   │ │ │
│  │  │   │   │ Span 4: Database Query              │   │   │ │ │
│  │  │   │   │ ├─ Parent: Span 3                   │   │   │ │ │
│  │  │   │   │ ├─ Start: 10:30:45.110              │   │   │ │ │
│  │  │   │   │ ├─ Duration: 25ms                   │   │   │ │ │
│  │  │   │   │ ├─ Operation: INSERT orders         │   │   │ │ │
│  │  │   │   │ └─ Tags: table=orders, rows=1       │   │   │ │ │
│  │  │   │   └─────────────────────────────────────┘   │   │ │ │
│  │  │   └─────────────────────────────────────────────┘   │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 TRACE VISUALIZATION                     │ │
│  │                                                         │ │
│  │  Timeline View:                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ API Gateway    ████████████████████████████████████ │ │ │
│  │  │ User Service     ████████                           │ │ │
│  │  │ Order Service      ████████████████████             │ │ │
│  │  │ Database Query       ████                           │ │ │
│  │  │ Payment Service        ████████████████             │ │ │
│  │  │ Notification           ████████                     │ │ │
│  │  │                                                     │ │ │
│  │  │ 0ms    50ms   100ms   150ms   200ms   250ms         │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  Service Map View:                                      │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │     [API Gateway] ──┐                               │ │ │
│  │  │           │         ├─→ [User Service]              │ │ │
│  │  │           │         ├─→ [Order Service] ──→ [DB]    │ │ │
│  │  │           │         ├─→ [Payment Service]           │ │ │
│  │  │           │         └─→ [Notification Service]      │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Trace:** Complete journey of a request through the system
**Span:** Individual operation within a trace (service call, database query)
**Context:** Metadata that connects spans within a trace

**Example Trace Structure:**
```
Trace ID: abc123 (Place Order Request)
├── Span 1: API Gateway (50ms total)
├── Span 2: User Service - Validate User (20ms)
├── Span 3: Order Service - Create Order (100ms)
│   ├── Span 3.1: Database - Insert Order (30ms)
│   └── Span 3.2: Inventory Service - Reserve Items (60ms)
├── Span 4: Payment Service - Process Payment (200ms)
│   ├── Span 4.1: External API - Charge Card (180ms)
│   └── Span 4.2: Database - Record Transaction (15ms)
└── Span 5: Notification Service - Send Confirmation (25ms)

Total Request Time: 395ms
Bottleneck: Payment Service (200ms, 51% of total time)
```

## Monitoring Strategies

### Proactive vs Reactive Monitoring

#### Reactive Monitoring
**Characteristics:**
- Responds to problems after they occur
- Focuses on system recovery
- User-reported issues drive investigations
- **Example**: Users report slow checkout process, team investigates and finds database performance issue

#### Proactive Monitoring
**Characteristics:**
- Identifies problems before user impact
- Focuses on problem prevention
- Data-driven optimization
- **Example**: Monitoring shows database query times increasing, team optimizes queries before users notice slowdown

### Monitoring Pyramid

#### Level 1: Infrastructure Monitoring
**What to Monitor:**
- Server health (CPU, memory, disk, network)
- Container and orchestration metrics
- Cloud service health and quotas
- Network connectivity and performance

**Example Metrics:**
```
Web Server Infrastructure:
- CPU Usage: Average 45%, Peak 78%
- Memory Usage: 60% of 16GB allocated
- Disk I/O: 150 IOPS average, 500 IOPS peak
- Network: 50 Mbps inbound, 200 Mbps outbound
```

#### Level 2: Application Monitoring
**What to Monitor:**
- Application performance metrics
- Error rates and types
- Feature usage and adoption
- Custom business metrics

**Example Metrics:**
```
E-commerce Application:
- Page Load Time: p95 = 2.1 seconds
- Checkout Conversion Rate: 3.2%
- Search Success Rate: 94%
- Cart Abandonment Rate: 68%
```

#### Level 3: User Experience Monitoring
**What to Monitor:**
- Real user monitoring (RUM)
- Synthetic transaction monitoring
- Core Web Vitals
- User journey completion rates

**Example Metrics:**
```
User Experience Tracking:
- Largest Contentful Paint: 1.8 seconds
- First Input Delay: 45ms
- Cumulative Layout Shift: 0.08
- User Journey Completion: 87% (registration to first purchase)
```

### Golden Signals

The four golden signals provide a comprehensive view of service health:

#### 1. Latency
**Definition:** Time taken to service a request
**Why Important:** Directly impacts user experience
**What to Measure:**
- Response time percentiles (p50, p95, p99)
- Time to first byte (TTFB)
- End-to-end transaction time

**Example Analysis:**
```
API Latency Analysis:
- p50: 120ms (good - most users have fast experience)
- p95: 800ms (concerning - 5% of users wait too long)
- p99: 2.1s (poor - 1% of users have very slow experience)

Action: Investigate what causes the slowest 5% of requests
```

#### 2. Traffic
**Definition:** Demand being placed on your system
**Why Important:** Understanding load patterns and capacity needs
**What to Measure:**
- Requests per second
- Concurrent users
- Data transfer rates

**Example Analysis:**
```
Traffic Pattern Analysis:
- Peak Hours: 9 AM - 11 AM (2,500 RPS)
- Normal Hours: 500 RPS average
- Weekend Traffic: 60% of weekday volume
- Mobile vs Desktop: 70% mobile, 30% desktop

Insight: Need auto-scaling for morning peak traffic
```

#### 3. Errors
**Definition:** Rate of requests that fail
**Why Important:** Indicates system reliability and user frustration
**What to Measure:**
- HTTP error rates (4xx, 5xx)
- Application exceptions
- Failed business transactions

**Example Analysis:**
```
Error Rate Analysis:
- Overall Error Rate: 0.8%
- 4xx Errors: 0.6% (mostly 404s - missing products)
- 5xx Errors: 0.2% (server errors - database timeouts)

Action: Fix product catalog sync and database performance
```

#### 4. Saturation
**Definition:** How "full" your service is
**Why Important:** Predicts when you'll need more resources
**What to Measure:**
- CPU and memory utilization
- Database connection pool usage
- Queue depths and wait times

**Example Analysis:**
```
Saturation Monitoring:
- CPU Utilization: 75% average, 95% peak
- Memory Usage: 80% of allocated
- Database Connections: 85% of pool used
- Message Queue: 200 messages waiting (normal: <50)

Warning: Approaching capacity limits, scale up needed
```

## Alerting and Incident Response

### Effective Alerting Strategies

#### Alert Fatigue Prevention
**The Problem:**
- Too many alerts desensitize teams
- Important alerts get lost in noise
- Teams start ignoring notifications
- Real incidents go unnoticed

**Solutions:**
```
Alert Prioritization:
- P1 (Critical): System down, data loss, security breach
- P2 (High): Performance degradation, partial outage
- P3 (Medium): Warning thresholds, capacity concerns
- P4 (Low): Informational, maintenance reminders

Alert Routing:
- P1: Immediate phone call + SMS + Slack
- P2: Slack notification + email
- P3: Email notification
- P4: Dashboard only
```

#### Smart Alerting Techniques

**Threshold-Based Alerting:**
```
Simple Threshold (problematic):
- CPU > 80% → Alert
- Problem: Temporary spikes cause false alarms

Smart Threshold (better):
- CPU > 80% for 5 consecutive minutes → Alert
- Problem: Still doesn't account for normal patterns

Adaptive Threshold (best):
- CPU > (historical average + 2 standard deviations) → Alert
- Accounts for normal daily/weekly patterns
```

**Composite Alerting:**
```
Single Metric Alert:
- Error rate > 1% → Alert
- Problem: May not indicate real user impact

Composite Alert:
- (Error rate > 1%) AND (Traffic > 100 RPS) → Alert
- Better: Only alerts when errors affect significant traffic
```

### Incident Response Process

#### Incident Severity Levels

**Severity 1 (Critical):**
- Complete service outage
- Data loss or corruption
- Security breach
- **Response Time**: Immediate (< 15 minutes)
- **Example**: Payment processing completely down

**Severity 2 (High):**
- Significant performance degradation
- Partial service outage
- Major feature unavailable
- **Response Time**: 1 hour
- **Example**: Search functionality returning no results

**Severity 3 (Medium):**
- Minor performance issues
- Non-critical feature problems
- Workaround available
- **Response Time**: 4 hours
- **Example**: Recommendation engine showing stale data

#### Incident Response Workflow

**1. Detection and Alerting**
```
Incident Detection Sources:
- Automated monitoring alerts
- User reports and complaints
- Internal team observations
- Third-party service notifications

First Response Actions:
- Acknowledge the alert
- Assess severity and impact
- Create incident ticket
- Notify relevant stakeholders
```

**2. Investigation and Diagnosis**
```
Investigation Process:
- Check system dashboards and metrics
- Review recent deployments and changes
- Analyze logs and traces for errors
- Identify affected components and users

Diagnosis Techniques:
- Compare current metrics to baseline
- Trace request flows through system
- Check dependencies and external services
- Review error patterns and frequencies
```

**3. Mitigation and Resolution**
```
Immediate Mitigation:
- Rollback recent deployments
- Scale up resources if capacity issue
- Activate circuit breakers or failover
- Implement temporary workarounds

Root Cause Resolution:
- Fix underlying code or configuration issues
- Update monitoring and alerting rules
- Implement preventive measures
- Document lessons learned
```

## AWS Monitoring Services

### Amazon CloudWatch

#### CloudWatch Metrics
**Default Metrics:**
- EC2: CPU, network, disk utilization
- RDS: Database connections, read/write IOPS
- Lambda: Invocations, duration, errors
- ALB: Request count, latency, error rates

**Custom Metrics:**
```
Business Metrics Examples:
- User registrations per hour
- Revenue per minute
- Shopping cart abandonment rate
- Feature adoption metrics

Technical Metrics Examples:
- Application response times
- Database query performance
- Cache hit ratios
- Queue processing rates
```

#### CloudWatch Alarms
**Alarm States:**
- **OK**: Metric within acceptable range
- **ALARM**: Metric breached threshold
- **INSUFFICIENT_DATA**: Not enough data to determine state

**Alarm Actions:**
```
Automated Response Examples:
- Scale up Auto Scaling Group
- Send SNS notification
- Execute Lambda function
- Stop/start EC2 instances

Notification Examples:
- Email to operations team
- Slack message to #alerts channel
- PagerDuty incident creation
- SMS to on-call engineer
```

### AWS X-Ray

#### Distributed Tracing with X-Ray
**Service Map Visualization:**
- Visual representation of service dependencies
- Response time and error rate for each service
- Identification of bottlenecks and failures
- Impact analysis for service issues

**Trace Analysis:**
```
Example Trace Insights:
- Total request time: 2.3 seconds
- Slowest service: Database queries (1.8 seconds)
- Error location: Payment service timeout
- Optimization opportunity: Parallel API calls

Business Impact:
- 15% of checkout requests affected
- $50,000 potential revenue impact per hour
- Customer satisfaction score decrease
```

### Amazon CloudTrail

#### API Auditing and Compliance
**What CloudTrail Logs:**
- API calls made to AWS services
- User and role activity
- Resource changes and configurations
- Security-related events

**Use Cases:**
```
Security Monitoring:
- Unusual API activity patterns
- Unauthorized access attempts
- Privilege escalation events
- Resource deletion activities

Compliance Auditing:
- Who accessed what data when
- Configuration change history
- Regulatory compliance reporting
- Forensic investigation support
```

## Performance Monitoring

### Application Performance Monitoring (APM)

#### Key Performance Indicators

**Response Time Metrics:**
```
Web Application Performance:
- Page Load Time: Time from request to fully rendered page
- Time to Interactive: When page becomes fully interactive
- First Contentful Paint: When first content appears
- Largest Contentful Paint: When main content loads

API Performance:
- Request Processing Time: Server-side processing duration
- Database Query Time: Time spent in database operations
- External API Calls: Third-party service response times
- Queue Processing Time: Asynchronous task completion
```

**Throughput Metrics:**
```
System Capacity Indicators:
- Requests per Second (RPS): Current load handling
- Transactions per Second (TPS): Business operation rate
- Concurrent Users: Active user sessions
- Data Processing Rate: Records/messages processed per unit time
```

#### Performance Bottleneck Identification

**Common Bottleneck Patterns:**
```
Database Bottlenecks:
- Symptoms: High query response times, connection pool exhaustion
- Causes: Unoptimized queries, missing indexes, lock contention
- Solutions: Query optimization, read replicas, connection pooling

Network Bottlenecks:
- Symptoms: High latency, packet loss, timeouts
- Causes: Bandwidth limitations, geographic distance, routing issues
- Solutions: CDN deployment, regional distribution, connection optimization

Application Bottlenecks:
- Symptoms: High CPU usage, memory leaks, slow processing
- Causes: Inefficient algorithms, resource leaks, blocking operations
- Solutions: Code optimization, caching, asynchronous processing
```

### Real User Monitoring (RUM)

#### User Experience Metrics
**Core Web Vitals:**
```
Loading Performance:
- Largest Contentful Paint (LCP): < 2.5 seconds (good)
- Measures: When main content finishes loading
- Impact: User perception of page load speed

Interactivity:
- First Input Delay (FID): < 100 milliseconds (good)
- Measures: Time from user interaction to browser response
- Impact: User frustration with unresponsive pages

Visual Stability:
- Cumulative Layout Shift (CLS): < 0.1 (good)
- Measures: Unexpected layout shifts during page load
- Impact: User experience disruption from moving elements
```

**User Journey Monitoring:**
```
E-commerce User Journey:
1. Landing Page → Product Search (95% completion)
2. Product Search → Product View (78% completion)
3. Product View → Add to Cart (45% completion)
4. Add to Cart → Checkout (67% completion)
5. Checkout → Payment (89% completion)
6. Payment → Order Confirmation (94% completion)

Insights:
- Major drop-off at "Add to Cart" step
- Payment process is reliable once started
- Search functionality works well
```

## Distributed Tracing

### Tracing in Microservices

#### Correlation IDs and Context Propagation
**The Challenge:**
```
Microservices Request Flow:
User Request → API Gateway → Service A → Service B → Service C → Database

Without Tracing:
- Each service logs independently
- No connection between related log entries
- Difficult to debug cross-service issues
- Manual correlation of timestamps and IDs
```

**The Solution:**
```
Distributed Tracing Implementation:
1. Generate unique trace ID for each request
2. Propagate trace ID through all service calls
3. Each service adds span information
4. Collect and correlate all spans
5. Visualize complete request journey

Benefits:
- End-to-end request visibility
- Performance bottleneck identification
- Error root cause analysis
- Service dependency mapping
```

#### Sampling Strategies
**Why Sampling is Necessary:**
- High-traffic systems generate millions of traces
- Storing all traces is expensive and unnecessary
- Processing overhead impacts performance
- Most traces are similar and don't provide unique insights

**Sampling Approaches:**
```
Head-Based Sampling (at request start):
- Sample 1% of all requests randomly
- Pros: Predictable overhead, simple implementation
- Cons: May miss important error traces

Tail-Based Sampling (after request completion):
- Sample based on trace characteristics (errors, latency)
- Pros: Captures interesting traces, reduces noise
- Cons: Higher complexity, delayed decisions

Adaptive Sampling:
- Adjust sampling rate based on traffic and error rates
- Higher sampling during incidents
- Lower sampling during normal operations
```

### Trace Analysis Techniques

#### Performance Analysis
**Identifying Bottlenecks:**
```
Trace Analysis Example:
Total Request Time: 1.2 seconds

Service Breakdown:
- API Gateway: 50ms (4%)
- User Service: 100ms (8%)
- Product Service: 200ms (17%)
- Database Query: 800ms (67%)
- Response Processing: 50ms (4%)

Insight: Database is the primary bottleneck
Action: Optimize database queries and consider caching
```

#### Error Analysis
**Root Cause Investigation:**
```
Error Trace Analysis:
Request failed with 500 Internal Server Error

Trace Timeline:
1. API Gateway: Success (50ms)
2. User Service: Success (100ms)
3. Product Service: Success (150ms)
4. Inventory Service: Timeout Error (5000ms)
5. Order Service: Never called (cascade failure)

Root Cause: Inventory Service timeout
Impact: Order processing completely blocked
Solution: Implement circuit breaker and fallback logic
```

## Best Practices

### Monitoring Strategy Design

#### 1. Start with Business Metrics
**Business-First Approach:**
- Define what success looks like for your business
- Identify key user journeys and conversion funnels
- Monitor business KPIs alongside technical metrics
- Align technical alerts with business impact

**Example Implementation:**
```
E-commerce Business Metrics:
- Revenue per minute
- Conversion rate by traffic source
- Average order value trends
- Customer acquisition cost

Technical Metrics Supporting Business:
- Checkout process completion rate
- Payment processing success rate
- Search result relevance scores
- Page load times for key pages
```

#### 2. Implement the Monitoring Pyramid
**Layer 1: Infrastructure (Foundation)**
- Server health and resource utilization
- Network connectivity and performance
- Cloud service health and quotas
- Basic availability monitoring

**Layer 2: Application (Core)**
- Application performance metrics
- Error rates and types
- Feature usage and adoption
- Custom business metrics

**Layer 3: User Experience (Top)**
- Real user monitoring
- Synthetic transaction monitoring
- Core Web Vitals
- User journey completion rates

#### 3. Design for Actionability
**Every Alert Should Be Actionable:**
```
Bad Alert:
- "CPU usage is high"
- Problem: Doesn't indicate what action to take

Good Alert:
- "API response time exceeded SLA (>2s) for 5 minutes, affecting checkout process"
- Includes: Impact, duration, affected functionality
- Action: Investigate checkout service performance
```

### Observability Implementation

#### 1. Structured Logging Standards
**Consistent Log Format:**
```json
{
  "timestamp": "2024-01-15T10:30:45Z",
  "level": "INFO",
  "service": "order-service",
  "trace_id": "abc123",
  "span_id": "def456",
  "user_id": "user789",
  "event": "order_created",
  "order_id": "order123",
  "amount": 99.99,
  "processing_time_ms": 245,
  "metadata": {
    "payment_method": "credit_card",
    "shipping_method": "standard"
  }
}
```

#### 2. Distributed Tracing Strategy
**Trace Everything Important:**
- User-facing requests
- Background job processing
- Inter-service communication
- Database operations
- External API calls

**Context Propagation:**
- Use standard formats (W3C Trace Context)
- Propagate through all service boundaries
- Include business context in spans
- Maintain trace integrity across async operations

#### 3. Metrics Collection Best Practices
**Metric Naming Conventions:**
```
Consistent Naming Pattern:
- service.operation.metric_type
- Examples:
  - order_service.create_order.duration
  - payment_service.process_payment.error_rate
  - user_service.authenticate.success_count
```

**Appropriate Metric Types:**
- **Counters**: Cumulative values (total requests, errors)
- **Gauges**: Point-in-time values (CPU usage, queue depth)
- **Histograms**: Distribution of values (response times)
- **Summaries**: Quantiles and totals (percentiles)

This comprehensive guide provides the foundation for implementing effective monitoring and observability in modern distributed systems. The key is to start with business requirements and build observability that provides actionable insights for maintaining reliable, performant systems.
## Decision Matrix

```
┌─────────────────────────────────────────────────────────────┐
│           MONITORING & OBSERVABILITY DECISION MATRIX        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              MONITORING APPROACHES                      │ │
│  │                                                         │ │
│  │  Approach    │Complexity│Insight   │Cost    │Use Case  │ │
│  │  ──────────  │─────────│─────────│───────│─────────  │ │
│  │  Metrics Only│ ✅ Low   │ ❌ Limited│✅ Low │Basic     │ │
│  │  Logs Only   │ ⚠️ Medium│ ⚠️ Medium│⚠️ Med │Debug     │ │
│  │  APM Tools   │ ⚠️ Medium│ ✅ High  │❌ High│Enterprise│ │
│  │  Full Stack  │ ❌ High  │ ✅ Complete│❌ High│Critical  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              AWS MONITORING SERVICES                    │ │
│  │                                                         │ │
│  │  Service     │Purpose   │Complexity│Integration│Cost   │ │
│  │  ──────────  │─────────│─────────│──────────│──────  │ │
│  │  CloudWatch  │ Metrics  │ ✅ Low   │ ✅ Native │✅ Low │ │
│  │  X-Ray       │ Tracing  │ ⚠️ Medium│ ✅ Native │⚠️ Med │ │
│  │  CloudTrail  │ Audit    │ ✅ Low   │ ✅ Native │✅ Low │ │
│  │  OpenSearch  │ Logs     │ ❌ High  │ ⚠️ Custom │❌ High│ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              ALERTING STRATEGIES                        │ │
│  │                                                         │ │
│  │  Strategy    │Accuracy  │Noise     │Response  │Use Case│ │
│  │  ──────────  │─────────│─────────│─────────│───────│ │
│  │  Threshold   │ ⚠️ Basic │ ❌ High  │ ✅ Fast  │Simple │ │
│  │  Anomaly     │ ✅ Smart │ ✅ Low   │ ⚠️ Medium│Advanced│ │
│  │  Composite   │ ✅ High  │ ✅ Low   │ ⚠️ Medium│Complex │ │
│  │  ML-Based    │ ✅ Adaptive│✅ Minimal│❌ Slow  │AI     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │           OBSERVABILITY TOOL SELECTION                  │ │
│  │                                                         │ │
│  │  Tool Type   │Setup Time│Learning  │Features │Cost    │ │
│  │  ──────────  │─────────│─────────│────────│───────  │ │
│  │  CloudWatch  │ ✅ 1 day │ ✅ Easy  │⚠️ Basic│✅ Low  │ │
│  │  Datadog     │ ⚠️ 1 week│ ⚠️ Medium│✅ Rich │❌ High │ │
│  │  New Relic   │ ⚠️ 1 week│ ⚠️ Medium│✅ Rich │❌ High │ │
│  │  Grafana     │ ❌ 2 weeks│❌ Hard  │✅ Custom│⚠️ Med  │ │
│  │  ELK Stack   │ ❌ 3 weeks│❌ Hard  │✅ Full │⚠️ Med  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              INCIDENT RESPONSE TOOLS                    │ │
│  │                                                         │ │
│  │  Tool        │Integration│Automation│Workflow │Price  │ │
│  │  ──────────  │──────────│─────────│────────│──────  │ │
│  │  PagerDuty   │ ✅ Excellent│✅ Advanced│✅ Rich│❌ High│ │
│  │  Opsgenie    │ ✅ Good    │✅ Good   │✅ Good │⚠️ Med │ │
│  │  VictorOps   │ ⚠️ Basic   │⚠️ Basic  │⚠️ Basic│✅ Low │ │
│  │  SNS + Lambda│ ⚠️ Custom  │✅ Full   │❌ DIY  │✅ Low │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Selection Guidelines

**Choose CloudWatch When:**
- AWS-native applications
- Basic metrics and alarms needed
- Cost-effective solution required
- Simple implementation preferred

**Choose Full Observability When:**
- Complex distributed systems
- Root cause analysis critical
- Performance optimization needed
- Compliance requirements exist

**Choose Anomaly Detection When:**
- Dynamic workloads
- Reducing alert fatigue
- Intelligent monitoring needed
- Machine learning capabilities available

### Implementation Decision Framework

```
┌─────────────────────────────────────────────────────────────┐
│              OBSERVABILITY IMPLEMENTATION FLOW              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐                                            │
│  │   START     │                                            │
│  │ Assessment  │                                            │
│  └──────┬──────┘                                            │
│         │                                                   │
│         ▼                                                   │
│  ┌─────────────┐    No     ┌─────────────┐                 │
│  │System Size  │──────────▶│ Basic       │                 │
│  │< 10 Services│           │ CloudWatch  │                 │
│  └──────┬──────┘           └─────────────┘                 │
│         │ Yes                                               │
│         ▼                                                   │
│  ┌─────────────┐    No     ┌─────────────┐                 │
│  │Budget       │──────────▶│ Open Source │                 │
│  │> $10k/month │           │ ELK + Jaeger│                 │
│  └──────┬──────┘           └─────────────┘                 │
│         │ Yes                                               │
│         ▼                                                   │
│  ┌─────────────┐    No     ┌─────────────┐                 │
│  │Team Size    │──────────▶│ Managed     │                 │
│  │> 5 DevOps   │           │ SaaS Tools  │                 │
│  └──────┬──────┘           └─────────────┘                 │
│         │ Yes                                               │
│         ▼                                                   │
│  ┌─────────────┐                                            │
│  │ Enterprise  │                                            │
│  │ Custom Stack│                                            │
│  └─────────────┘                                            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```
