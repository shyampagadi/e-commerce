# Resilience Patterns

## Overview

Resilience patterns are essential design strategies that enable systems to handle failures gracefully, maintain availability, and recover quickly from disruptions. This document covers key resilience patterns with practical implementations and AWS examples.

## Table of Contents
- [Circuit Breaker Pattern](#circuit-breaker-pattern)
- [Retry Pattern](#retry-pattern)
- [Bulkhead Pattern](#bulkhead-pattern)
- [Timeout Pattern](#timeout-pattern)
- [Rate Limiting](#rate-limiting)
- [Graceful Degradation](#graceful-degradation)
- [AWS Implementation](#aws-implementation)
- [Decision Matrix](#decision-matrix)

## Circuit Breaker Pattern

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    CIRCUIT BREAKER STATES                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    Failure Rate    ┌─────────────┐        │
│  │   CLOSED    │    Exceeds         │    OPEN     │        │
│  │             │    Threshold       │             │        │
│  │ ✅ Requests │ ─────────────────▶ │ ❌ Requests │        │
│  │    Pass     │                    │    Blocked  │        │
│  │    Through  │                    │             │        │
│  └─────────────┘                    └─────────────┘        │
│         ▲                                    │              │
│         │                                    │              │
│         │ Success Rate                       │ Timeout      │
│         │ Above Threshold                    │ Expires      │
│         │                                    │              │
│         │           ┌─────────────┐          │              │
│         └───────────│ HALF-OPEN   │◀─────────┘              │
│                     │             │                         │
│                     │ ⚠️ Limited  │                         │
│                     │   Requests  │                         │
│                     │   Allowed   │                         │
│                     └─────────────┘                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```python
import time
import threading
from enum import Enum
from typing import Callable, Any

class CircuitState(Enum):
    CLOSED = "closed"
    OPEN = "open"
    HALF_OPEN = "half_open"

class CircuitBreaker:
    def __init__(self, failure_threshold=5, timeout=60, expected_exception=Exception):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.expected_exception = expected_exception
        
        self.failure_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED
        self.lock = threading.Lock()
    
    def call(self, func: Callable, *args, **kwargs) -> Any:
        with self.lock:
            if self.state == CircuitState.OPEN:
                if time.time() - self.last_failure_time > self.timeout:
                    self.state = CircuitState.HALF_OPEN
                else:
                    raise Exception("Circuit breaker is OPEN")
            
            try:
                result = func(*args, **kwargs)
                self._on_success()
                return result
            except self.expected_exception as e:
                self._on_failure()
                raise e
    
    def _on_success(self):
        self.failure_count = 0
        self.state = CircuitState.CLOSED
    
    def _on_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            self.state = CircuitState.OPEN

# Usage Example
circuit_breaker = CircuitBreaker(failure_threshold=3, timeout=30)

def unreliable_service():
    # Simulate service call
    import random
    if random.random() < 0.7:  # 70% failure rate
        raise Exception("Service unavailable")
    return "Success"

try:
    result = circuit_breaker.call(unreliable_service)
    print(f"Result: {result}")
except Exception as e:
    print(f"Circuit breaker prevented call: {e}")
```

## Retry Pattern

### Exponential Backoff Strategy

```
┌─────────────────────────────────────────────────────────────┐
│                    EXPONENTIAL BACKOFF                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  RETRY TIMELINE                         │ │
│  │                                                         │ │
│  │  Attempt 1: ■ (Immediate)                               │ │
│  │             ↓ Failure                                   │ │
│  │  Attempt 2: ──■ (1 second delay)                        │ │
│  │               ↓ Failure                                 │ │
│  │  Attempt 3: ────■ (2 second delay)                      │ │
│  │                 ↓ Failure                               │ │
│  │  Attempt 4: ────────■ (4 second delay)                  │ │
│  │                     ↓ Failure                           │ │
│  │  Attempt 5: ────────────■ (8 second delay)              │ │
│  │                         ↓ Success ✓                     │ │
│  │                                                         │ │
│  │  Formula: delay = base_delay × 2^(attempt - 1)          │ │
│  │  With Jitter: delay ± random(0, jitter_range)          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                  RETRY STRATEGIES                       │ │
│  │                                                         │ │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │ │
│  │  │   LINEAR    │  │EXPONENTIAL  │  │   CUSTOM    │     │ │
│  │  │   BACKOFF   │  │  BACKOFF    │  │  STRATEGY   │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ 1s, 2s, 3s  │  │1s,2s,4s,8s  │  │ Business    │     │ │
│  │  │ 4s, 5s...   │  │16s, 32s...  │  │ Logic Based │     │ │
│  │  │             │  │             │  │             │     │ │
│  │  │ Pros:       │  │ Pros:       │  │ Pros:       │     │ │
│  │  │ • Simple    │  │ • Reduces   │  │ • Optimized │     │ │
│  │  │ • Predictable│ │   Load      │  │ • Flexible  │     │ │
│  │  │             │  │ • Scales    │  │             │     │ │
│  │  │ Cons:       │  │             │  │ Cons:       │     │ │
│  │  │ • May       │  │ Cons:       │  │ • Complex   │     │ │
│  │  │   Overload  │  │ • Long      │  │ • Hard to   │     │ │
│  │  │   Service   │  │   Delays    │  │   Test      │     │ │
│  │  └─────────────┘  └─────────────┘  └─────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────┐
│                    RETRY PATTERN TIMELINE                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Attempt 1: t=0s        ❌ Failed                          │
│  Attempt 2: t=1s        ❌ Failed                          │
│  Attempt 3: t=3s        ❌ Failed                          │
│  Attempt 4: t=7s        ❌ Failed                          │
│  Attempt 5: t=15s       ✅ Success                         │
│                                                             │
│  Backoff Formula: delay = base_delay * (2 ^ attempt)       │
│  With Jitter: delay += random(0, jitter_max)               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```python
import time
import random
import logging
from functools import wraps

def retry_with_backoff(max_retries=3, base_delay=1, max_delay=60, backoff_factor=2):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_retries + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == max_retries:
                        logging.error(f"Max retries exceeded for {func.__name__}")
                        raise e
                    
                    delay = min(base_delay * (backoff_factor ** attempt), max_delay)
                    jitter = random.uniform(0, delay * 0.1)
                    sleep_time = delay + jitter
                    
                    logging.warning(f"Attempt {attempt + 1} failed, retrying in {sleep_time:.2f}s")
                    time.sleep(sleep_time)
            
        return wrapper
    return decorator

# Usage
@retry_with_backoff(max_retries=5, base_delay=1, backoff_factor=2)
def call_external_api():
    import requests
    response = requests.get("https://api.example.com/data", timeout=10)
    response.raise_for_status()
    return response.json()
```

## Bulkhead Pattern

### Resource Isolation Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    BULKHEAD PATTERN                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 SHIP BULKHEAD ANALOGY                   │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │ │ │
│  │  │ │Compartment│Compartment│Compartment│Compartment│   │ │ │
│  │  │ │    1     │    2     │    3     │    4     │   │ │ │
│  │  │ │         │ │         │ │  💧     │ │         │   │ │ │
│  │  │ │         │ │         │ │ Flooded │ │         │   │ │ │
│  │  │ │    ✓    │ │    ✓    │ │    ❌    │ │    ✓    │   │ │ │
│  │  │ └─────────┘ └─────────┘ └─────────┘ └─────────┘   │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  Result: Ship stays afloat despite one compartment     │ │
│  │          flooding - damage is contained                │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              SYSTEM RESOURCE ISOLATION                  │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                 THREAD POOLS                        │ │ │
│  │  │                                                     │ │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │ │ │
│  │  │  │   CRITICAL  │  │   NORMAL    │  │ BACKGROUND  │ │ │ │
│  │  │  │  OPERATIONS │  │ OPERATIONS  │  │ OPERATIONS  │ │ │ │
│  │  │  │             │  │             │  │             │ │ │ │
│  │  │  │ 🧵🧵🧵🧵🧵   │  │ 🧵🧵🧵🧵🧵   │  │ 🧵🧵🧵       │ │ │ │
│  │  │  │ 20 Threads  │  │ 30 Threads  │  │ 10 Threads  │ │ │ │
│  │  │  │             │  │             │  │             │ │ │ │
│  │  │  │ • User Auth │  │ • Product   │  │ • Analytics │ │ │ │
│  │  │  │ • Payments  │  │   Catalog   │  │ • Cleanup   │ │ │ │
│  │  │  │ • Orders    │  │ • Search    │  │ • Reports   │ │ │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │               CONNECTION POOLS                      │ │ │
│  │  │                                                     │ │ │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │ │ │
│  │  │  │  DATABASE   │  │   CACHE     │  │ EXTERNAL    │ │ │ │
│  │  │  │ CONNECTIONS │  │ CONNECTIONS │  │ API CALLS   │ │ │ │
│  │  │  │             │  │             │  │             │ │ │ │
│  │  │  │ 🔗🔗🔗🔗🔗   │  │ 🔗🔗🔗🔗     │  │ 🔗🔗🔗       │ │ │ │
│  │  │  │ 50 Conns    │  │ 20 Conns    │  │ 10 Conns    │ │ │ │
│  │  │  │             │  │             │  │             │ │ │ │
│  │  │  │ • Primary   │  │ • Redis     │  │ • Payment   │ │ │ │
│  │  │  │   DB        │  │ • Memcached │  │   Gateway   │ │ │ │
│  │  │  │ • Read      │  │             │  │ • Email     │ │ │ │
│  │  │  │   Replicas  │  │             │  │   Service   │ │ │ │
│  │  │  └─────────────┘  └─────────────┘  └─────────────┘ │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────┐
│                    BULKHEAD PATTERN                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                  ┌─────────────────┐                       │
│                  │  APPLICATION    │                       │
│                  │     LAYER       │                       │
│                  └─────────┬───────┘                       │
│                            │                               │
│              ┌─────────────┼─────────────┐                 │
│              │             │             │                 │
│              ▼             ▼             ▼                 │
│        ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│        │BULKHEAD A│  │BULKHEAD B│  │BULKHEAD C│           │
│        │          │  │          │  │          │           │
│        │Thread    │  │Thread    │  │Thread    │           │
│        │Pool: 10  │  │Pool: 15  │  │Pool: 5   │           │
│        │          │  │          │  │          │           │
│        │Critical  │  │Normal    │  │Batch     │           │
│        │Services  │  │Services  │  │Jobs      │           │
│        └──────────┘  └──────────┘  └──────────┘           │
│                                                             │
│        If one bulkhead fails, others remain operational    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```python
import concurrent.futures
import threading
from typing import Dict, Any

class BulkheadExecutor:
    def __init__(self):
        self.executors: Dict[str, concurrent.futures.ThreadPoolExecutor] = {}
        self.lock = threading.Lock()
    
    def create_bulkhead(self, name: str, max_workers: int):
        with self.lock:
            if name not in self.executors:
                self.executors[name] = concurrent.futures.ThreadPoolExecutor(
                    max_workers=max_workers,
                    thread_name_prefix=f"bulkhead-{name}"
                )
    
    def submit_to_bulkhead(self, bulkhead_name: str, func, *args, **kwargs):
        if bulkhead_name not in self.executors:
            raise ValueError(f"Bulkhead {bulkhead_name} not found")
        
        return self.executors[bulkhead_name].submit(func, *args, **kwargs)
    
    def shutdown_all(self):
        for executor in self.executors.values():
            executor.shutdown(wait=True)

# Usage
bulkhead = BulkheadExecutor()

# Create separate resource pools
bulkhead.create_bulkhead("critical", max_workers=10)
bulkhead.create_bulkhead("normal", max_workers=20)
bulkhead.create_bulkhead("batch", max_workers=5)

# Submit tasks to appropriate bulkheads
critical_future = bulkhead.submit_to_bulkhead("critical", process_payment, order_id)
normal_future = bulkhead.submit_to_bulkhead("normal", send_email, user_email)
batch_future = bulkhead.submit_to_bulkhead("batch", generate_report, report_params)
```

## Timeout Pattern

### Timeout Configuration

```
┌─────────────────────────────────────────────────────────────┐
│                    TIMEOUT PATTERN                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 TIMEOUT SCENARIOS                       │ │
│  │                                                         │ │
│  │  ┌─────────────┐    Request     ┌─────────────┐         │ │
│  │  │   CLIENT    │ ──────────────▶│   SERVICE   │         │ │
│  │  │             │                │             │         │ │
│  │  │ Timeout:    │                │ Processing  │         │ │
│  │  │ 5 seconds   │                │ Time: ???   │         │ │
│  │  │             │                │             │         │ │
│  │  │ ⏰ Timer    │                │             │         │ │
│  │  │ Started     │                │             │         │ │
│  │  └─────────────┘                └─────────────┘         │ │
│  │                                                         │ │
│  │  Scenario 1: Fast Response (2s)                         │ │
│  │  ┌─────────────┐    Response    ┌─────────────┐         │ │
│  │  │   CLIENT    │ ◀──────────────│   SERVICE   │         │ │
│  │  │ ✅ Success  │                │ ✅ Complete │         │ │
│  │  │ Timer: 2s   │                │             │         │ │
│  │  └─────────────┘                └─────────────┘         │ │
│  │                                                         │ │
│  │  Scenario 2: Timeout (6s)                               │ │
│  │  ┌─────────────┐    Timeout     ┌─────────────┐         │ │
│  │  │   CLIENT    │ ❌ Abort       │   SERVICE   │         │ │
│  │  │ ❌ Timeout  │                │ 🐌 Still    │         │ │
│  │  │ Timer: 5s   │                │ Processing  │         │ │
│  │  └─────────────┘                └─────────────┘         │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────┐
│                    TIMEOUT HIERARCHY                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              CLIENT REQUEST (30s)                       ││
│  │  ┌─────────────────────────────────────────────────────┐││
│  │  │           SERVICE CALL (20s)                        │││
│  │  │  ┌─────────────────────────────────────────────────┐│││
│  │  │  │         DATABASE QUERY (10s)                    ││││
│  │  │  │  ┌─────────────────────────────────────────────┐││││
│  │  │  │  │       CONNECTION TIMEOUT (5s)               │││││
│  │  │  │  └─────────────────────────────────────────────┘││││
│  │  │  └─────────────────────────────────────────────────┘│││
│  │  └─────────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
│  Rule: Each layer should have shorter timeout than parent  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```python
import asyncio
import aiohttp
from contextlib import asynccontextmanager

class TimeoutManager:
    def __init__(self):
        self.timeouts = {
            'connection': 5,
            'read': 10,
            'total': 30
        }
    
    @asynccontextmanager
    async def timeout_context(self, operation_type: str):
        timeout = self.timeouts.get(operation_type, 30)
        try:
            async with asyncio.timeout(timeout):
                yield
        except asyncio.TimeoutError:
            raise TimeoutError(f"{operation_type} operation timed out after {timeout}s")

# Usage with HTTP client
async def make_api_call(url: str):
    timeout_mgr = TimeoutManager()
    
    connector = aiohttp.TCPConnector(
        limit=100,
        limit_per_host=30,
        keepalive_timeout=30
    )
    
    timeout = aiohttp.ClientTimeout(
        total=30,
        connect=5,
        sock_read=10
    )
    
    async with aiohttp.ClientSession(
        connector=connector,
        timeout=timeout
    ) as session:
        async with timeout_mgr.timeout_context('api_call'):
            async with session.get(url) as response:
                return await response.json()
```

## Rate Limiting

### Token Bucket Algorithm

```
┌─────────────────────────────────────────────────────────────┐
│                    RATE LIMITING ALGORITHMS                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 TOKEN BUCKET                            │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │                   BUCKET                            │ │ │
│  │  │  Capacity: 10 tokens                                │ │ │
│  │  │  Refill Rate: 2 tokens/second                       │ │ │
│  │  │                                                     │ │ │
│  │  │  ┌─────────────────────────────────────────────────┐ │ │ │
│  │  │  │ 🪙🪙🪙🪙🪙🪙🪙🪙 (8 tokens available)          │ │ │ │
│  │  │  │                                                 │ │ │ │
│  │  │  │                                                 │ │ │ │
│  │  │  └─────────────────────────────────────────────────┘ │ │ │
│  │  │                     ▲                               │ │ │
│  │  │                     │ Refill                        │ │ │
│  │  │              ┌─────────────┐                        │ │ │
│  │  │              │ Token       │                        │ │ │
│  │  │              │ Generator   │                        │ │ │
│  │  │              │ (2/sec)     │                        │ │ │
│  │  │              └─────────────┘                        │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  Request Processing:                                    │ │
│  │  1. Request arrives → Check bucket                      │ │
│  │  2. Token available? → Remove token, process request    │ │
│  │  3. No token? → Reject request (429 Too Many Requests) │ │
│  │  4. Bucket refills continuously at fixed rate          │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                 SLIDING WINDOW                          │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Time Window: 60 seconds, Limit: 100 requests       │ │ │
│  │  │                                                     │ │ │
│  │  │ Current Time: 14:30:45                              │ │ │
│  │  │ Window: 14:29:45 - 14:30:45                         │ │ │
│  │  │                                                     │ │ │
│  │  │ ┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬──┐            │ │ │
│  │  │ │5│8│3│7│2│9│4│6│1│8│5│3│7│9│2│4│6│8│12│ Requests  │ │ │
│  │  │ └─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴──┘ per 3s    │ │ │
│  │  │                                                     │ │ │
│  │  │ Total in window: 95 requests (✅ Under limit)       │ │ │
│  │  │ Next request: Allowed                               │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────┐
│                    TOKEN BUCKET ALGORITHM                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    ┌─────────────────┐                     │
│                    │   TOKEN BUCKET  │                     │
│                    │                 │                     │
│                    │  Capacity: 100  │                     │
│                    │  Current: 75    │                     │
│                    │  Refill: 10/sec │                     │
│                    └─────────┬───────┘                     │
│                              │                             │
│                              ▼                             │
│  ┌─────────────┐    ┌─────────────────┐    ┌─────────────┐│
│  │   Request   │───▶│  Rate Limiter   │───▶│   Allow/    ││
│  │             │    │                 │    │   Deny      ││
│  │ Needs 1     │    │ Check & Consume │    │             ││
│  │ Token       │    │ Token           │    │             ││
│  └─────────────┘    └─────────────────┘    └─────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```python
import time
import threading
from typing import Dict

class TokenBucket:
    def __init__(self, capacity: int, refill_rate: float):
        self.capacity = capacity
        self.tokens = capacity
        self.refill_rate = refill_rate
        self.last_refill = time.time()
        self.lock = threading.Lock()
    
    def consume(self, tokens: int = 1) -> bool:
        with self.lock:
            self._refill()
            
            if self.tokens >= tokens:
                self.tokens -= tokens
                return True
            return False
    
    def _refill(self):
        now = time.time()
        tokens_to_add = (now - self.last_refill) * self.refill_rate
        self.tokens = min(self.capacity, self.tokens + tokens_to_add)
        self.last_refill = now

class RateLimiter:
    def __init__(self):
        self.buckets: Dict[str, TokenBucket] = {}
        self.lock = threading.Lock()
    
    def is_allowed(self, key: str, capacity: int = 100, refill_rate: float = 10) -> bool:
        with self.lock:
            if key not in self.buckets:
                self.buckets[key] = TokenBucket(capacity, refill_rate)
            
            return self.buckets[key].consume()

# Usage
rate_limiter = RateLimiter()

def api_endpoint(user_id: str):
    if not rate_limiter.is_allowed(f"user:{user_id}", capacity=100, refill_rate=10):
        return {"error": "Rate limit exceeded"}, 429
    
    # Process request
    return {"data": "success"}, 200
```

## Graceful Degradation

### Service Degradation Levels

```
┌─────────────────────────────────────────────────────────────┐
│                 GRACEFUL DEGRADATION LEVELS                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              E-COMMERCE DEGRADATION EXAMPLE             │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Level 0: FULL SERVICE (Normal Operation)            │ │ │
│  │  │                                                     │ │ │
│  │  │ ✅ Product recommendations                           │ │ │
│  │  │ ✅ Real-time inventory                               │ │ │
│  │  │ ✅ Personalized pricing                              │ │ │
│  │  │ ✅ Advanced search filters                           │ │ │
│  │  │ ✅ User reviews and ratings                          │ │ │
│  │  │ ✅ Related products                                  │ │ │
│  │  │ ✅ Wishlist functionality                            │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                           │                             │ │
│  │                           ▼ High Load                   │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Level 1: REDUCED FEATURES (Minor Degradation)       │ │ │
│  │  │                                                     │ │ │
│  │  │ ⚠️ Basic recommendations (cached)                    │ │ │
│  │  │ ✅ Real-time inventory                               │ │ │
│  │  │ ⚠️ Standard pricing (no personalization)            │ │ │
│  │  │ ✅ Basic search                                      │ │ │
│  │  │ ✅ User reviews (cached)                             │ │ │
│  │  │ ❌ Related products disabled                         │ │ │
│  │  │ ✅ Wishlist functionality                            │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                           │                             │ │
│  │                           ▼ Critical Load               │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Level 2: CORE FUNCTIONS (Major Degradation)         │ │ │
│  │  │                                                     │ │ │
│  │  │ ❌ No recommendations                                │ │ │
│  │  │ ⚠️ Cached inventory (5min delay)                     │ │ │
│  │  │ ⚠️ Standard pricing only                             │ │ │
│  │  │ ✅ Basic search                                      │ │ │
│  │  │ ❌ Reviews disabled                                  │ │ │
│  │  │ ❌ Related products disabled                         │ │ │
│  │  │ ❌ Wishlist disabled                                 │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                           │                             │ │
│  │                           ▼ Emergency Mode              │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │ Level 3: ESSENTIAL ONLY (Survival Mode)             │ │ │
│  │  │                                                     │ │ │
│  │  │ ❌ No recommendations                                │ │ │
│  │  │ ❌ No real-time inventory                            │ │ │
│  │  │ ✅ Basic product display                             │ │ │
│  │  │ ✅ Shopping cart                                     │ │ │
│  │  │ ✅ Checkout process                                  │ │ │
│  │  │ ✅ Payment processing                                │ │ │
│  │  │ ❌ All non-essential features disabled               │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

```
┌─────────────────────────────────────────────────────────────┐
│                 GRACEFUL DEGRADATION LEVELS                 │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Level 0: Full Service                                      │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ ✅ Real-time data  ✅ Personalization  ✅ Analytics    ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                             │
│                              ▼ High Load                   │
│  Level 1: Reduced Features                                  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ ✅ Real-time data  ⚠️ Basic features   ❌ Analytics    ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                             │
│                              ▼ Critical Load               │
│  Level 2: Essential Only                                    │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ ⚠️ Cached data    ❌ Personalization  ❌ Analytics    ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                             │
│                              ▼ System Overload             │
│  Level 3: Maintenance Mode                                  │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ ❌ All features   ✅ Status page      ✅ Error msg     ││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

```python
import psutil
from enum import Enum
from typing import Dict, Any

class ServiceLevel(Enum):
    FULL = 0
    REDUCED = 1
    ESSENTIAL = 2
    MAINTENANCE = 3

class GracefulDegradation:
    def __init__(self):
        self.current_level = ServiceLevel.FULL
        self.thresholds = {
            'cpu_percent': 80,
            'memory_percent': 85,
            'error_rate': 0.05
        }
    
    def check_system_health(self) -> ServiceLevel:
        cpu_usage = psutil.cpu_percent(interval=1)
        memory_usage = psutil.virtual_memory().percent
        
        if cpu_usage > 90 or memory_usage > 95:
            return ServiceLevel.MAINTENANCE
        elif cpu_usage > 80 or memory_usage > 85:
            return ServiceLevel.ESSENTIAL
        elif cpu_usage > 70 or memory_usage > 75:
            return ServiceLevel.REDUCED
        else:
            return ServiceLevel.FULL
    
    def get_feature_config(self, level: ServiceLevel) -> Dict[str, bool]:
        configs = {
            ServiceLevel.FULL: {
                'real_time_data': True,
                'personalization': True,
                'analytics': True,
                'recommendations': True
            },
            ServiceLevel.REDUCED: {
                'real_time_data': True,
                'personalization': False,
                'analytics': False,
                'recommendations': False
            },
            ServiceLevel.ESSENTIAL: {
                'real_time_data': False,
                'personalization': False,
                'analytics': False,
                'recommendations': False
            },
            ServiceLevel.MAINTENANCE: {
                'real_time_data': False,
                'personalization': False,
                'analytics': False,
                'recommendations': False
            }
        }
        return configs.get(level, configs[ServiceLevel.MAINTENANCE])

# Usage
degradation = GracefulDegradation()

def api_handler(request):
    current_level = degradation.check_system_health()
    features = degradation.get_feature_config(current_level)
    
    response = {"data": get_basic_data()}
    
    if features['personalization']:
        response['personalized'] = get_personalized_content(request.user_id)
    
    if features['analytics']:
        track_user_action(request.user_id, request.action)
    
    return response
```

## AWS Implementation

### Auto Scaling with Circuit Breaker

```yaml
# CloudFormation for Resilient Architecture
Resources:
  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Type: application
      Scheme: internet-facing
      SecurityGroups: [!Ref ALBSecurityGroup]
      Subnets: [!Ref PublicSubnet1, !Ref PublicSubnet2]

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      MinSize: 2
      MaxSize: 10
      DesiredCapacity: 3
      LaunchTemplate:
        LaunchTemplateId: !Ref LaunchTemplate
        Version: !GetAtt LaunchTemplate.LatestVersionNumber
      TargetGroupARNs: [!Ref TargetGroup]
      HealthCheckType: ELB
      HealthCheckGracePeriod: 300

  ScaleUpPolicy:
    Type: AWS::AutoScaling::ScalingPolicy
    Properties:
      AutoScalingGroupName: !Ref AutoScalingGroup
      PolicyType: TargetTrackingScaling
      TargetTrackingConfiguration:
        PredefinedMetricSpecification:
          PredefinedMetricType: ASGAverageCPUUtilization
        TargetValue: 70
```

### Lambda with Dead Letter Queue

```yaml
# Lambda Function with Resilience
Resources:
  ProcessingFunction:
    Type: AWS::Lambda::Function
    Properties:
      Runtime: python3.9
      Handler: index.handler
      DeadLetterConfig:
        TargetArn: !GetAtt DeadLetterQueue.Arn
      ReservedConcurrencyLimit: 100
      Timeout: 30
      
  DeadLetterQueue:
    Type: AWS::SQS::Queue
    Properties:
      MessageRetentionPeriod: 1209600  # 14 days
      
  RetryQueue:
    Type: AWS::SQS::Queue
    Properties:
      VisibilityTimeoutSeconds: 60
      RedrivePolicy:
        deadLetterTargetArn: !GetAtt DeadLetterQueue.Arn
        maxReceiveCount: 3
```

## Decision Matrix

```
┌─────────────────────────────────────────────────────────────┐
│              RESILIENCE PATTERNS DECISION MATRIX            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                PATTERN COMPARISON                       │ │
│  │                                                         │ │
│  │  Pattern         │Complexity│Performance│Use Case       │ │
│  │  ──────────────  │─────────│──────────│──────────────  │ │
│  │  Circuit Breaker │ ⚠️ Med   │ ⚠️ Low    │External APIs   │ │
│  │  Retry           │ ✅ Low   │ ⚠️ Med    │Transient Fails │ │
│  │  Bulkhead        │ ❌ High  │ ⚠️ Med    │Resource Isolate│ │
│  │  Timeout         │ ✅ Low   │ ✅ Min    │All Operations  │ │
│  │  Rate Limiting   │ ⚠️ Med   │ ⚠️ Low    │API Protection  │ │
│  │  Graceful Degrade│ ❌ High  │ ✅ Pos    │System Overload │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              PATTERN SELECTION FLOWCHART                │ │
│  │                                                         │ │
│  │                    ┌─────────────┐                     │ │
│  │                    │ What type   │                     │ │
│  │                    │ of failure? │                     │ │
│  │                    └──────┬──────┘                     │ │
│  │                           │                            │ │
│  │              ┌────────────┼────────────┐               │ │
│  │              │            │            │               │ │
│  │              ▼            ▼            ▼               │ │
│  │     ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │ │
│  │     │ External    │ │ Transient   │ │ Resource    │    │ │
│  │     │ Service     │ │ Network     │ │ Contention  │    │ │
│  │     │ Failures    │ │ Failures    │ │             │    │ │
│  │     └──────┬──────┘ └──────┬──────┘ └──────┬──────┘    │ │
│  │            │               │               │           │ │
│  │            ▼               ▼               ▼           │ │
│  │     ┌─────────────┐ ┌─────────────┐ ┌─────────────┐    │ │
│  │     │ Circuit     │ │ Retry +     │ │ Bulkhead +  │    │ │
│  │     │ Breaker +   │ │ Exponential │ │ Resource    │    │ │
│  │     │ Timeout     │ │ Backoff     │ │ Pools       │    │ │
│  │     └─────────────┘ └─────────────┘ └─────────────┘    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              PATTERN COMBINATIONS                       │ │
│  │                                                         │ │
│  │  ┌─────────────────────────────────────────────────────┐ │ │
│  │  │              HIGH AVAILABILITY STACK                │ │ │
│  │  │                                                     │ │ │
│  │  │  ┌─────────────┐                                    │ │ │
│  │  │  │Rate Limiting│ ← Protect from overload            │ │ │
│  │  │  └─────────────┘                                    │ │ │
│  │  │         │                                           │ │ │
│  │  │         ▼                                           │ │ │
│  │  │  ┌─────────────┐                                    │ │ │
│  │  │  │Circuit      │ ← Fast failure detection          │ │ │
│  │  │  │Breaker      │                                    │ │ │
│  │  │  └─────────────┘                                    │ │ │
│  │  │         │                                           │ │ │
│  │  │         ▼                                           │ │ │
│  │  │  ┌─────────────┐                                    │ │ │
│  │  │  │Retry with   │ ← Handle transient failures       │ │ │
│  │  │  │Backoff      │                                    │ │ │
│  │  │  └─────────────┘                                    │ │ │
│  │  │         │                                           │ │ │
│  │  │         ▼                                           │ │ │
│  │  │  ┌─────────────┐                                    │ │ │
│  │  │  │Timeout      │ ← Prevent hanging requests        │ │ │
│  │  │  └─────────────┘                                    │ │ │
│  │  │         │                                           │ │ │
│  │  │         ▼                                           │ │ │
│  │  │  ┌─────────────┐                                    │ │ │
│  │  │  │Graceful     │ ← Maintain partial functionality  │ │ │
│  │  │  │Degradation  │                                    │ │ │
│  │  │  └─────────────┘                                    │ │ │
│  │  └─────────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  Result: Robust, fault-tolerant system                  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

| Pattern | Complexity | Performance Impact | Use Case | Implementation |
|---------|------------|-------------------|----------|----------------|
| **Circuit Breaker** | ⚠️ Medium | ⚠️ Low | External Services | ✅ Easy |
| **Retry** | ✅ Low | ⚠️ Medium | Transient Failures | ✅ Easy |
| **Bulkhead** | ❌ High | ⚠️ Medium | Resource Isolation | ⚠️ Medium |
| **Timeout** | ✅ Low | ✅ Minimal | All Operations | ✅ Easy |
| **Rate Limiting** | ⚠️ Medium | ⚠️ Low | API Protection | ⚠️ Medium |
| **Graceful Degradation** | ❌ High | ✅ Positive | System Overload | ❌ Complex |

### Selection Guidelines

**Use Circuit Breaker When:**
- Calling external services
- Preventing cascade failures
- Fast failure detection needed

**Use Retry When:**
- Transient failures expected
- Network issues common
- Idempotent operations

**Use Bulkhead When:**
- Resource contention issues
- Different SLA requirements
- Fault isolation critical
