# Rust Data Structures

## 1. Array — `[T; N]`

Fixed-size collection of elements of the same type.

```rust
let numbers: [i32; 4] = [10, 20, 30, 40];
```

```text
[T; N]
 │  │
 │  └── number of elements
 └───── element type
```

Characteristics:

```text
Fixed size
Contiguous memory
Same type
Size known at compile time
No heap allocation required
```

Access:

```rust
numbers[0]
```

Useful when the size is known and doesn't change.

---

## 2. Tuple — `(T, U, ...)`

Groups values of **different types**.

```rust
let user = ("oqxo", 35, true);
```

```text
(&str, i32, bool)
```

Access:

```rust
user.0
user.1
user.2
```

Destructuring:

```rust
let (name, age, active) = user;
```

Characteristics:

```text
Fixed size
Can contain different types
Usually stored inline
Useful for small groups of related values
```

---

## 3. Slice — `&[T]`

A **view into a sequence of elements**.

```rust
let numbers = [10, 20, 30, 40];

let slice = &numbers[1..3];
```

```text
numbers
┌────┬────┬────┬────┐
│ 10 │ 20 │ 30 │ 40 │
└────┴────┴────┴────┘
       ↑         ↑
       └─ slice ─┘
```

A slice does **not own** the data.

```text
&[T]
 ↓
borrows existing data
```

This is extremely important:

```rust
fn sum(numbers: &[i32]) {
    // ...
}
```

The function can accept:

```text
[i32; 5]
Vec<i32>
other contiguous storage
```

through a slice.

---

# 4. `Vec<T>`

A growable, heap-allocated, contiguous collection.

```rust
let mut numbers = Vec::new();

numbers.push(10);
numbers.push(20);
numbers.push(30);
```

Conceptually:

```text
STACK

Vec
┌───────────────┐
│ pointer       │──────┐
│ length = 3    │      │
│ capacity = ?  │      │
└───────────────┘      │
                       ↓
HEAP
┌────┬────┬────┐
│ 10 │ 20 │ 30 │
└────┴────┴────┘
```

Characteristics:

```text
Dynamic size
Heap allocated
Contiguous
Same type
Can grow/shrink
Uses allocator
```

Very commonly used.

---

# 5. `String`

An owned, growable UTF-8 string.

```rust
let mut name = String::from("oqxo");

name.push_str(" rust");
```

Conceptually similar to `Vec<u8>`:

```text
String
  ↓
heap
  ↓
UTF-8 bytes
```

Characteristics:

```text
Owned
Growable
Heap allocated
UTF-8 encoded
Uses allocator
```

Important distinction:

```text
String  → owns the string data
&str    → borrows string data
```

---

# 6. `HashMap<K, V>`

Stores **key → value** associations.

```rust
use std::collections::HashMap;

let mut users = HashMap::new();

users.insert("oqxo", 35);
users.insert("alice", 30);
```

Conceptually:

```text
HashMap

key      → value
───────────────
"oqxo"   → 35
"alice"  → 30
```

Lookup:

```rust
users.get("oqxo");
```

Characteristics:

```text
Key → value
Dynamic
Heap allocated
Hash-based
Fast average lookup
```

Typical complexity:

```text
insert  → O(1) average
lookup  → O(1) average
remove  → O(1) average
```

---

# 7. `HashSet<T>`

Stores **unique values**.

```rust
use std::collections::HashSet;

let mut names = HashSet::new();

names.insert("oqxo");
names.insert("alice");
names.insert("oqxo");
```

The second `"oqxo"` isn't added.

Conceptually:

```text
HashSet

┌────────┐
│ "oqxo" │
├────────┤
│ "alice"│
└────────┘
```

Characteristics:

```text
Unique elements
Dynamic
Heap allocated
Hash-based
Fast average lookup
```

Typical complexity:

```text
insert  → O(1) average
contains → O(1) average
remove  → O(1) average
```

---

# 8. `VecDeque<T>`

A **double-ended queue**.

```rust
use std::collections::VecDeque;

let mut queue = VecDeque::new();

queue.push_back(10);
queue.push_back(20);

queue.push_front(5);
```

Conceptually:

```text
        front              back
          ↓                 ↓
       ┌────┬────┬────┐
       │  5 │ 10 │ 20 │
       └────┴────┴────┘
```

You can efficiently add/remove from both ends:

```rust
queue.push_front(1);
queue.push_back(30);

queue.pop_front();
queue.pop_back();
```

Characteristics:

```text
Dynamic
Heap allocated
Double-ended
Efficient front/back operations
```

Typical:

```text
push_front → O(1) amortized
push_back  → O(1) amortized
pop_front  → O(1)
pop_back   → O(1)
```

Useful for:

```text
queues
stacks
sliding-window algorithms
BFS
```

---

# Quick Comparison

| Structure      | Size         | Same Type | Heap | Main Use             |
| -------------- | ------------ | --------- | ---- | -------------------- |
| `[T; N]`       | Fixed        | Yes       | No*  | Fixed collection     |
| `(T, U)`       | Fixed        | No        | No*  | Small grouped values |
| `&[T]`         | Dynamic view | Yes       | No   | Borrowed sequence    |
| `Vec<T>`       | Dynamic      | Yes       | Yes  | General collection   |
| `String`       | Dynamic      | UTF-8     | Yes  | Text                 |
| `HashMap<K,V>` | Dynamic      | Key/Value | Yes  | Key → value          |
| `HashSet<T>`   | Dynamic      | Yes       | Yes  | Unique values        |
| `VecDeque<T>`  | Dynamic      | Yes       | Yes  | Queue/deque          |

`*` They don't require heap allocation themselves; they can contain values that themselves use heap allocation.

### The mental model

```text
Array
 ↓
fixed contiguous memory

Slice
 ↓
borrowed view of contiguous memory

Vec
 ↓
growable contiguous memory

String
 ↓
growable UTF-8 bytes

HashMap
 ↓
key → value lookup

HashSet
 ↓
unique values

VecDeque
 ↓
efficient front + back operations

Tuple
 ↓
small fixed group of values
```
