# Database Internals and Algorithms

## Overview

Understanding database internals and algorithms is crucial for designing efficient, scalable database systems. This document covers the fundamental data structures, algorithms, and storage mechanisms that power modern databases.

## Core Data Structures

### 1. B-Tree and B+Tree

#### B-Tree Overview
B-Trees are balanced tree data structures that maintain sorted data and allow searches, sequential access, insertions, and deletions in logarithmic time.

```
┌─────────────────────────────────────────────────────────────┐
│                B-TREE STRUCTURE                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                        [50]                                │
│                       /    \                               │
│                    [25]    [75]                            │
│                   /  \    /  \                             │
│                [10] [40] [60] [90]                         │
│                / \  / \  / \  / \                          │
│              [5][15][30][45][55][65][80][95]               │
│                                                             │
│  Characteristics:                                           │
│  - All leaves at same level                                │
│  - Internal nodes have 2-4 children                        │
│  - Keys in sorted order                                    │
│  - Search time: O(log n)                                   │
└─────────────────────────────────────────────────────────────┘
```

#### B+Tree Overview
B+Trees are optimized for disk storage with all data in leaf nodes and internal nodes containing only keys.

```
┌─────────────────────────────────────────────────────────────┐
│                B+TREE STRUCTURE                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                        [50]                                │
│                       /    \                               │
│                    [25]    [75]                            │
│                   /  \    /  \                             │
│                [10] [40] [60] [90]                         │
│                / \  / \  / \  / \                          │
│              [5][15][30][45][55][65][80][95]               │
│              |  |  |  |  |  |  |  |                       │
│              v  v  v  v  v  v  v  v                       │
│            [Data][Data][Data][Data][Data][Data][Data][Data]│
│                                                             │
│  Characteristics:                                           │
│  - All data in leaf nodes                                  │
│  - Internal nodes are index only                           │
│  - Leaf nodes linked for sequential access                 │
│  - Better for range queries                                │
└─────────────────────────────────────────────────────────────┘
```

#### B-Tree Operations

##### Search Operation
```python
def btree_search(node, key):
    if node is None:
        return None
    
    # Find the appropriate child
    i = 0
    while i < len(node.keys) and key > node.keys[i]:
        i += 1
    
    # Check if key is in current node
    if i < len(node.keys) and key == node.keys[i]:
        return node.values[i]
    
    # Search in appropriate child
    return btree_search(node.children[i], key)
```

##### Insert Operation
```python
def btree_insert(root, key, value):
    if root.is_full():
        # Split root and create new root
        new_root = BTreeNode()
        new_root.children.append(root)
        split_child(new_root, 0)
        root = new_root
    
    insert_non_full(root, key, value)
    return root

def insert_non_full(node, key, value):
    i = len(node.keys) - 1
    
    if node.is_leaf():
        # Insert into leaf node
        node.keys.append(None)
        node.values.append(None)
        
        while i >= 0 and key < node.keys[i]:
            node.keys[i + 1] = node.keys[i]
            node.values[i + 1] = node.values[i]
            i -= 1
        
        node.keys[i + 1] = key
        node.values[i + 1] = value
    else:
        # Find appropriate child
        while i >= 0 and key < node.keys[i]:
            i -= 1
        i += 1
        
        if node.children[i].is_full():
            split_child(node, i)
            if key > node.keys[i]:
                i += 1
        
        insert_non_full(node.children[i], key, value)
```

#### B-Tree Advantages
- **Balanced Height**: O(log n) search, insert, delete
- **Disk-Optimized**: Minimizes disk I/O operations
- **Range Queries**: Efficient range scan operations
- **Concurrent Access**: Supports multiple readers/writers

#### B-Tree Disadvantages
- **Space Overhead**: Internal nodes store keys
- **Complex Implementation**: Splitting and merging logic
- **Write Amplification**: Updates may require multiple disk writes

### 2. LSM (Log-Structured Merge) Trees

#### LSM Tree Overview
LSM trees are optimized for write-heavy workloads by batching writes and using sequential I/O.

```
┌─────────────────────────────────────────────────────────────┐
│                LSM TREE STRUCTURE                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                MEMORY (C0)                          │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   Write     │    │   Write     │    │ Write   │  │    │
│  │  │   Buffer    │    │   Buffer    │    │ Buffer  │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                             │                               │
│                             v                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                DISK (C1)                            │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   Sorted    │    │   Sorted    │    │ Sorted  │  │    │
│  │  │   Run 1     │    │   Run 2     │    │ Run 3   │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                             │                               │
│                             v                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                DISK (C2)                            │    │
│  │                                                     │    │
│  │  ┌─────────────┐    ┌─────────────┐    ┌─────────┐  │    │
│  │  │   Merged    │    │   Merged    │    │ Merged  │  │    │
│  │  │   Run 1     │    │   Run 2     │    │ Run 3   │  │    │
│  │  └─────────────┘    └─────────────┘    └─────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### LSM Tree Operations

##### Write Operation
```python
def lsm_write(key, value):
    # Write to memory buffer
    memory_buffer.append((key, value))
    
    # Check if buffer is full
    if len(memory_buffer) >= BUFFER_SIZE:
        # Flush to disk
        flush_to_disk()
        memory_buffer.clear()

def flush_to_disk():
    # Sort buffer by key
    memory_buffer.sort(key=lambda x: x[0])
    
    # Write to disk as sorted run
    run_file = create_new_run_file()
    for key, value in memory_buffer:
        run_file.write(key, value)
    run_file.close()
    
    # Trigger compaction if needed
    if should_compact():
        compact_runs()
```

##### Read Operation
```python
def lsm_read(key):
    # Search in memory buffer first
    for k, v in memory_buffer:
        if k == key:
            return v
    
    # Search in disk runs (from newest to oldest)
    for run in reversed(disk_runs):
        value = run.get(key)
        if value is not None:
            return value
    
    return None
```

##### Compaction Operation
```python
def compact_runs():
    # Merge multiple runs into one
    runs_to_merge = select_runs_for_compaction()
    
    merged_run = create_new_run_file()
    
    # Merge runs using external merge sort
    for key, value in merge_runs(runs_to_merge):
        merged_run.write(key, value)
    
    merged_run.close()
    
    # Remove old runs
    for run in runs_to_merge:
        run.delete()
```

#### LSM Tree Advantages
- **Write Performance**: Excellent write throughput
- **Sequential I/O**: Optimized for disk performance
- **Compression**: Built-in compression support
- **Concurrent Writes**: Multiple writers supported

#### LSM Tree Disadvantages
- **Read Performance**: May require multiple disk reads
- **Compaction Overhead**: Background compaction required
- **Space Amplification**: Temporary space overhead during compaction
- **Complex Implementation**: Compaction logic is complex

### 3. Hash Indexes

#### Hash Index Overview
Hash indexes provide O(1) average-case lookup time using hash tables.

```
┌─────────────────────────────────────────────────────────────┐
│                HASH INDEX STRUCTURE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Hash Function: h(key) = key % 7                           │
│                                                             │
│  ┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐      │
│  │  0  │    │  1  │    │  2  │    │  3  │    │  4  │      │
│  └─────┘    └─────┘    └─────┐    └─────┘    └─────┘      │
│     │         │              │       │         │           │
│     v         v              v       v         v           │
│  [14,data] [15,data]    [16,data] [17,data] [18,data]     │
│                                                             │
│  Key Lookup:                                                │
│  1. Calculate hash: h(key)                                 │
│  2. Access bucket: table[h(key)]                           │
│  3. Search chain: linear search in bucket                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Hash Index Operations

##### Insert Operation
```python
def hash_insert(key, value):
    bucket_index = hash_function(key) % table_size
    bucket = hash_table[bucket_index]
    
    # Check if key already exists
    for i, (k, v) in enumerate(bucket):
        if k == key:
            bucket[i] = (key, value)  # Update existing
            return
    
    # Insert new key-value pair
    bucket.append((key, value))
```

##### Lookup Operation
```python
def hash_lookup(key):
    bucket_index = hash_function(key) % table_size
    bucket = hash_table[bucket_index]
    
    # Search in bucket
    for k, v in bucket:
        if k == key:
            return v
    
    return None  # Key not found
```

##### Delete Operation
```python
def hash_delete(key):
    bucket_index = hash_function(key) % table_size
    bucket = hash_table[bucket_index]
    
    # Find and remove key
    for i, (k, v) in enumerate(bucket):
        if k == key:
            del bucket[i]
            return True
    
    return False  # Key not found
```

#### Hash Index Advantages
- **Fast Lookup**: O(1) average-case lookup time
- **Simple Implementation**: Straightforward hash table
- **Memory Efficient**: Direct key-value mapping

#### Hash Index Disadvantages
- **No Range Queries**: Cannot perform range scans
- **Hash Collisions**: Performance degrades with collisions
- **No Ordered Traversal**: Cannot iterate in sorted order
- **Memory Overhead**: Hash table overhead

### 4. Inverted Indexes

#### Inverted Index Overview
Inverted indexes map terms to documents containing those terms, enabling full-text search.

```
┌─────────────────────────────────────────────────────────────┐
│                INVERTED INDEX STRUCTURE                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Term Dictionary:                                           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │   "apple"   │    │   "banana"  │    │   "cherry"      │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│         │                   │                   │           │
│         v                   v                   v           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────┐  │
│  │ Posting     │    │ Posting     │    │ Posting         │  │
│  │ List        │    │ List        │    │ List            │  │
│  │             │    │             │    │                 │  │
│  │ Doc1: 3     │    │ Doc1: 1     │    │ Doc2: 2         │  │
│  │ Doc2: 1     │    │ Doc3: 2     │    │ Doc3: 1         │  │
│  │ Doc3: 2     │    │ Doc4: 1     │    │ Doc4: 3         │  │
│  └─────────────┘    └─────────────┘    └─────────────────┘  │
│                                                             │
│  Search Process:                                            │
│  1. Tokenize query: "apple banana" → ["apple", "banana"]   │
│  2. Lookup terms: Get posting lists for each term          │
│  3. Intersect lists: Find documents containing both terms  │
│  4. Rank results: Score and rank matching documents        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Inverted Index Operations

##### Index Construction
```python
def build_inverted_index(documents):
    inverted_index = {}
    
    for doc_id, document in enumerate(documents):
        # Tokenize document
        terms = tokenize(document)
        
        # Count term frequencies
        term_freq = {}
        for term in terms:
            term_freq[term] = term_freq.get(term, 0) + 1
        
        # Add to inverted index
        for term, freq in term_freq.items():
            if term not in inverted_index:
                inverted_index[term] = []
            inverted_index[term].append((doc_id, freq))
    
    return inverted_index
```

##### Search Operation
```python
def search_inverted_index(inverted_index, query):
    # Tokenize query
    query_terms = tokenize(query)
    
    # Get posting lists for each term
    posting_lists = []
    for term in query_terms:
        if term in inverted_index:
            posting_lists.append(inverted_index[term])
        else:
            return []  # Term not found
    
    # Intersect posting lists
    if not posting_lists:
        return []
    
    result = set(posting_lists[0])
    for posting_list in posting_lists[1:]:
        result = result.intersection(set(posting_list))
    
    return list(result)
```

#### Inverted Index Advantages
- **Full-Text Search**: Enables text search capabilities
- **Ranking**: Supports relevance scoring
- **Scalability**: Can handle large document collections
- **Flexibility**: Supports complex queries

#### Inverted Index Disadvantages
- **Storage Overhead**: Large index size
- **Update Complexity**: Expensive to update
- **Memory Usage**: May require significant memory
- **Complex Implementation**: Sophisticated algorithms needed

### 5. R-Trees (Spatial Indexes)

#### R-Tree Overview
R-Trees are tree data structures used for spatial indexing, particularly for multi-dimensional data.

```
┌─────────────────────────────────────────────────────────────┐
│                R-TREE STRUCTURE                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                        [Root]                              │
│                    /          \                            │
│                [R1]          [R2]                          │
│               /    \        /    \                         │
│            [R3]   [R4]   [R5]   [R6]                      │
│            /  \   /  \   /  \   /  \                       │
│          [P1][P2][P3][P4][P5][P6][P7][P8]                 │
│                                                             │
│  Each node contains:                                        │
│  - Bounding box (MBR - Minimum Bounding Rectangle)         │
│  - Child nodes or data points                              │
│  - Spatial coordinates (x1, y1, x2, y2)                   │
│                                                             │
│  Search Process:                                            │
│  1. Start at root                                           │
│  2. Check if query intersects node's bounding box          │
│  3. If yes, search child nodes                             │
│  4. If no, skip subtree                                    │
│  5. Continue until leaf nodes                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### R-Tree Operations

##### Insert Operation
```python
def rtree_insert(root, point):
    # Find appropriate leaf node
    leaf = choose_leaf(root, point)
    
    # Insert point into leaf
    leaf.add_point(point)
    
    # Check if leaf is full
    if leaf.is_full():
        # Split leaf
        new_leaf = split_leaf(leaf)
        
        # Update parent
        update_parent(leaf.parent, new_leaf)
        
        # Propagate splits up the tree
        if leaf.parent.is_full():
            split_node(leaf.parent)
```

##### Search Operation
```python
def rtree_search(node, query_rect):
    results = []
    
    # Check if query intersects node's bounding box
    if not intersects(node.bounding_box, query_rect):
        return results
    
    # If leaf node, check individual points
    if node.is_leaf():
        for point in node.points:
            if contains(query_rect, point):
                results.append(point)
    else:
        # Search child nodes
        for child in node.children:
            results.extend(rtree_search(child, query_rect))
    
    return results
```

#### R-Tree Advantages
- **Spatial Queries**: Efficient spatial range queries
- **Multi-dimensional**: Supports 2D, 3D, and higher dimensions
- **Range Queries**: Fast bounding box queries
- **Nearest Neighbor**: Supports proximity searches

#### R-Tree Disadvantages
- **Complex Implementation**: Sophisticated algorithms
- **Update Overhead**: Expensive insertions and deletions
- **Memory Usage**: May require significant memory
- **Performance Degradation**: Performance can degrade with updates

### 6. Bloom Filters

#### Bloom Filter Overview
Bloom filters are probabilistic data structures that test whether an element is a member of a set.

```
┌─────────────────────────────────────────────────────────────┐
│                BLOOM FILTER STRUCTURE                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Bit Array: [0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0] │
│                                                             │
│  Hash Functions:                                            │
│  h1(x) = (x * 3) % 15                                      │
│  h2(x) = (x * 5) % 15                                      │
│  h3(x) = (x * 7) % 15                                      │
│                                                             │
│  Insert "apple":                                            │
│  1. h1("apple") = 3  → Set bit 3                          │
│  2. h2("apple") = 5  → Set bit 5                          │
│  3. h3("apple") = 7  → Set bit 7                          │
│                                                             │
│  Query "apple":                                             │
│  1. h1("apple") = 3  → Check bit 3                        │
│  2. h2("apple") = 5  → Check bit 5                        │
│  3. h3("apple") = 7  → Check bit 7                        │
│  4. All bits set → "apple" might be in set                │
│                                                             │
│  Query "banana":                                            │
│  1. h1("banana") = 1 → Check bit 1                        │
│  2. h2("banana") = 2 → Check bit 2                        │
│  3. h3("banana") = 3 → Check bit 3                        │
│  4. Bit 2 not set → "banana" definitely not in set        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### Bloom Filter Operations

##### Insert Operation
```python
def bloom_filter_insert(bloom_filter, item):
    for hash_func in bloom_filter.hash_functions:
        index = hash_func(item) % bloom_filter.size
        bloom_filter.bit_array[index] = 1
```

##### Query Operation
```python
def bloom_filter_query(bloom_filter, item):
    for hash_func in bloom_filter.hash_functions:
        index = hash_func(item) % bloom_filter.size
        if bloom_filter.bit_array[index] == 0:
            return False  # Definitely not in set
    return True  # Might be in set (false positive possible)
```

#### Bloom Filter Advantages
- **Space Efficient**: Minimal memory usage
- **Fast Operations**: O(k) insert and query time
- **No False Negatives**: Never misses existing elements
- **Scalable**: Can handle large datasets

#### Bloom Filter Disadvantages
- **False Positives**: May report non-existent elements
- **No Deletion**: Cannot remove elements
- **Hash Dependency**: Performance depends on hash functions
- **Fixed Size**: Size must be known in advance

## Storage Engine Architecture

### 1. Row-Oriented Storage

#### Overview
Data is stored row by row, with all columns of a row stored together.

```
┌─────────────────────────────────────────────────────────────┐
│                ROW-ORIENTED STORAGE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Page 1:                                                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Row 1: [ID: 1, Name: "John", Age: 25, City: "NYC"] │    │
│  │ Row 2: [ID: 2, Name: "Jane", Age: 30, City: "LA"]  │    │
│  │ Row 3: [ID: 3, Name: "Bob", Age: 35, City: "CHI"]  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Page 2:                                                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Row 4: [ID: 4, Name: "Alice", Age: 28, City: "SF"] │    │
│  │ Row 5: [ID: 5, Name: "Charlie", Age: 32, City: "DC"]│    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Advantages:                                                │
│  - Fast row retrieval                                      │
│  - Good for OLTP workloads                                 │
│  - Simple implementation                                   │
│                                                             │
│  Disadvantages:                                            │
│  - Slow column-wise queries                                │
│  - Poor compression                                        │
│  - Inefficient for analytics                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2. Column-Oriented Storage

#### Overview
Data is stored column by column, with all values of a column stored together.

```
┌─────────────────────────────────────────────────────────────┐
│                COLUMN-ORIENTED STORAGE                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ID Column:                                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ [1, 2, 3, 4, 5]                                    │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Name Column:                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ ["John", "Jane", "Bob", "Alice", "Charlie"]        │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Age Column:                                                │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ [25, 30, 35, 28, 32]                               │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  City Column:                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ ["NYC", "LA", "CHI", "SF", "DC"]                   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Advantages:                                                │
│  - Fast column-wise queries                                │
│  - Excellent compression                                   │
│  - Good for analytics                                      │
│  - Vectorized operations                                   │
│                                                             │
│  Disadvantages:                                            │
│  - Slow row retrieval                                      │
│  - Complex implementation                                  │
│  - Poor for OLTP workloads                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3. Page-Based Storage

#### Overview
Data is stored in fixed-size pages, with each page containing multiple rows.

```
┌─────────────────────────────────────────────────────────────┐
│                PAGE-BASED STORAGE                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Page Header:                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Page ID: 1, Page Type: Data, Free Space: 100       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Row Directory:                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Row 1: Offset 100, Length 50                       │    │
│  │ Row 2: Offset 150, Length 60                       │    │
│  │ Row 3: Offset 210, Length 55                       │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Data Area:                                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ [Row 1 Data][Row 2 Data][Row 3 Data][Free Space]   │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Page Footer:                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Checksum: 0x12345678, LSN: 1000                    │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Advantages:                                                │
│  - Efficient disk I/O                                      │
│  - Good for B-Tree indexes                                 │
│  - Simple implementation                                   │
│  - Easy to manage                                          │
│                                                             │
│  Disadvantages:                                            │
│  - Fixed page size                                         │
│  - Fragmentation possible                                  │
│  - May waste space                                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Write-Ahead Logging (WAL)

### WAL Overview
WAL ensures durability by writing changes to a log before applying them to the database.

```
┌─────────────────────────────────────────────────────────────┐
│                WRITE-AHEAD LOGGING                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Transaction Flow:                                          │
│                                                             │
│  1. Begin Transaction                                       │
│     ┌─────────────────────────────────────────────────┐    │
│     │ Transaction ID: 1001                            │    │
│     │ Start Time: 2024-01-15 10:00:00                 │    │
│     └─────────────────────────────────────────────────┘    │
│                                                             │
│  2. Write to WAL                                           │
│     ┌─────────────────────────────────────────────────┐    │
│     │ LSN: 1000, TID: 1001, Operation: INSERT        │    │
│     │ Table: users, Key: 123, Value: "John"          │    │
│     └─────────────────────────────────────────────────┘    │
│                                                             │
│  3. Apply to Database                                      │
│     ┌─────────────────────────────────────────────────┐    │
│     │ Update in-memory data structures                │    │
│     │ Update disk pages (lazy)                        │    │
│     └─────────────────────────────────────────────────┘    │
│                                                             │
│  4. Commit Transaction                                     │
│     ┌─────────────────────────────────────────────────┐    │
│     │ LSN: 1001, TID: 1001, Operation: COMMIT        │    │
│     │ Commit Time: 2024-01-15 10:00:01                │    │
│     └─────────────────────────────────────────────────┘    │
│                                                             │
│  Recovery Process:                                          │
│  1. Read WAL from last checkpoint                         │
│  2. Replay committed transactions                          │
│  3. Rollback uncommitted transactions                      │
│  4. Restore database to consistent state                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### WAL Implementation

#### Write Operation
```python
def wal_write(transaction_id, operation, table, key, value):
    # Create log entry
    log_entry = LogEntry(
        lsn=next_lsn(),
        transaction_id=transaction_id,
        operation=operation,
        table=table,
        key=key,
        value=value,
        timestamp=current_timestamp()
    )
    
    # Write to WAL
    wal_file.write(log_entry)
    wal_file.flush()  # Ensure durability
    
    # Apply to database
    apply_to_database(log_entry)
```

#### Recovery Process
```python
def wal_recovery():
    # Find last checkpoint
    checkpoint_lsn = find_last_checkpoint()
    
    # Read WAL from checkpoint
    log_entries = read_wal_from_lsn(checkpoint_lsn)
    
    # Group by transaction
    transactions = group_by_transaction(log_entries)
    
    # Replay committed transactions
    for transaction_id, entries in transactions.items():
        if is_committed(transaction_id):
            replay_transaction(entries)
        else:
            rollback_transaction(transaction_id)
```

## Buffer Pool Management

### Buffer Pool Overview
Buffer pools manage in-memory pages to reduce disk I/O operations.

```
┌─────────────────────────────────────────────────────────────┐
│                BUFFER POOL MANAGEMENT                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Buffer Pool (Memory):                                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Page 1: [Data] [Dirty: No] [Pin Count: 0]          │    │
│  │ Page 2: [Data] [Dirty: Yes] [Pin Count: 1]         │    │
│  │ Page 3: [Data] [Dirty: No] [Pin Count: 0]          │    │
│  │ Page 4: [Data] [Dirty: Yes] [Pin Count: 0]         │    │
│  │ Page 5: [Data] [Dirty: No] [Pin Count: 2]          │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  LRU List:                                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Page 3 → Page 1 → Page 4 → Page 2 → Page 5        │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Free List:                                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ Empty slots available for new pages                │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  Operations:                                                │
│  1. Page Request: Check buffer pool first                 │
│  2. Page Hit: Return page from memory                     │
│  3. Page Miss: Load page from disk                        │
│  4. Eviction: Remove least recently used page             │
│  5. Flush: Write dirty pages to disk                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Buffer Pool Operations

#### Page Request
```python
def buffer_pool_get_page(page_id):
    # Check if page is in buffer pool
    if page_id in buffer_pool:
        page = buffer_pool[page_id]
        # Update LRU list
        lru_list.move_to_end(page_id)
        return page
    
    # Page not in buffer pool, load from disk
    return load_page_from_disk(page_id)

def load_page_from_disk(page_id):
    # Check if buffer pool is full
    if len(buffer_pool) >= max_pages:
        # Evict least recently used page
        evict_lru_page()
    
    # Load page from disk
    page = disk.read_page(page_id)
    
    # Add to buffer pool
    buffer_pool[page_id] = page
    lru_list.append(page_id)
    
    return page
```

#### Page Eviction
```python
def evict_lru_page():
    # Find least recently used page
    lru_page_id = lru_list[0]
    page = buffer_pool[lru_page_id]
    
    # Check if page is dirty
    if page.is_dirty():
        # Flush dirty page to disk
        disk.write_page(lru_page_id, page)
    
    # Remove from buffer pool
    del buffer_pool[lru_page_id]
    lru_list.remove(lru_page_id)
```

## Conclusion

Understanding database internals and algorithms is essential for designing efficient, scalable database systems. The key data structures and algorithms covered include:

1. **B-Trees and B+Trees**: Balanced tree structures for indexing
2. **LSM Trees**: Write-optimized structures for high-throughput systems
3. **Hash Indexes**: Fast key-value lookups
4. **Inverted Indexes**: Full-text search capabilities
5. **R-Trees**: Spatial indexing for multi-dimensional data
6. **Bloom Filters**: Probabilistic membership testing
7. **Storage Engines**: Row-oriented vs column-oriented storage
8. **Write-Ahead Logging**: Durability and recovery mechanisms
9. **Buffer Pool Management**: In-memory page management

These concepts form the foundation of modern database systems and are crucial for understanding how databases work internally, optimizing performance, and making informed architectural decisions.

