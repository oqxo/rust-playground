# Rust Ownership, Move, Copy & Borrowing

## 1. Ownership

Every value in Rust has an **owner**.

```rust
let s = String::from("hello");
```

```text
s ──owns──→ "hello"
```

The owner is responsible for the value's lifetime.

When the owner goes out of scope, Rust automatically cleans up the value.

**No garbage collector is required.**

---

## 2. Move

For a non-`Copy` type, assigning it to another variable **moves ownership**.

```rust
let s1 = String::from("hello");
let s2 = s1;
```

Conceptually:

```text
Before:

s1 ──owns──→ heap data


After:

s2 ──owns──→ heap data
s1 ──X
```

`s1` can no longer be used.

### Why?

Rust avoids automatically making expensive/deep copies of resources.

```text
Move
 ↓
ownership changes
 ↓
underlying resource can remain where it is
```

---

## 3. Copy

Some types implement the `Copy` trait.

```rust
let a = 10;
let b = a;

println!("{}", a); // ✅
```

Conceptually:

```text
a → 10
b → 10
```

The value is copied instead of ownership being transferred.

Common `Copy` types:

```text
i32, i64, u32, u64
f32, f64
bool
char
```

References can also be `Copy` in appropriate cases.

### Mental model

```text
Copy
 ↓
duplicate the value
 ↓
original remains usable
```

---

## 4. Why isn't everything `Copy`?

Consider:

```rust
let a = String::from("hello");
let b = a;
```

`String` owns heap memory.

Automatically copying it could mean duplicating the heap data.

Instead Rust moves it.

If you really want a separate copy:

```rust
let b = a.clone();
```

```text
a ──owns──→ heap data A

b ──owns──→ heap data B
```

`clone()` is an **explicit copy** and can be expensive.

---

# 5. Borrowing

Borrowing means:

> **Use someone else's value without taking ownership.**

```rust
let s = String::from("hello");

let r = &s;
```

```text
s ──owns──→ heap data
              ↑
              │
              r ──borrows
```

`s` remains the owner.

---

## 6. Immutable Borrow — `&T`

```rust
let s = String::from("hello");

let r = &s;

println!("{}", r);
```

`r` can read the value but doesn't own it.

Multiple immutable borrows are allowed:

```rust
let r1 = &s;
let r2 = &s;
let r3 = &s;
```

Conceptually:

```text
              ┌── r1
              │
s ──owns──→ data ── r2
              │
              └── r3
```

Rule:

```text
Many immutable borrows (&T)
        OR
One mutable borrow (&mut T)
```

---

# 7. Mutable Borrow — `&mut T`

```rust
let mut s = String::from("hello");

let r = &mut s;

r.push_str(" world");
```

`r` doesn't own the `String`.

But it has **exclusive access** to modify it.

```text
s ──owns──→ data
              ↑
              │
          &mut s
              │
         read + write
```

While the mutable borrow is active, conflicting access is not allowed.

---

# 8. Move vs Borrow

This is one of the most important distinctions.

### Move

```rust
fn consume(s: String) {
}
```

```rust
let s = String::from("hello");

consume(s);

// s ❌
```

Ownership moves into the function.

```text
s
 ↓
function
 ↓
function owns it
```

### Borrow

```rust
fn inspect(s: &String) {
}
```

```rust
let s = String::from("hello");

inspect(&s);

// s ✅
```

The function only borrows it.

```text
s ──owns──→ data
              ↑
          function borrows
```

---

# 9. Four Core Operations

Memorize this:

```text
┌─────────────────────┬──────────────────────────────┐
│ Operation            │ Meaning                     │
├─────────────────────┼──────────────────────────────┤
│ Copy                 │ Duplicate value             │
│ Move                 │ Transfer ownership          │
│ &T                   │ Borrow for reading          │
│ &mut T               │ Borrow for modifying        │
└─────────────────────┴──────────────────────────────┘
```

And:

```text
COPY
→ original remains usable

MOVE
→ original becomes unusable

&T
→ no ownership + read access

&mut T
→ no ownership + exclusive read/write access
```

---

# 10. Shadowing is different

Shadowing is **not ownership**.

```rust
let x = 10;
let x = 20;
```

You're creating a new binding with the same name.

It can even change type:

```rust
let x = 10;       // i32
let x = "hello";  // &str
```

Compare:

```text
Mutation:
let mut x = 10;
x = 20;

Shadowing:
let x = 10;
let x = 20;
```

---

# 11. The Big Mental Model

When looking at Rust code, ask:

```text
1. Who owns this value?

2. Is the type Copy?

3. If I assign/pass it:
      → Copy?
      → Move?

4. If I use &T:
      → Borrow

5. If I use &mut T:
      → Mutable/exclusive Borrow

6. If I need an independent value:
      → Clone
```

The fundamental picture:

```text
                    VALUE
                      │
             ┌────────┴────────┐
             │                 │
           OWNED            BORROWED
             │                 │
       ┌─────┴─────┐       ┌───┴────┐
       │           │       │        │
     Copy        Move     &T      &mut T
       │           │       │        │
    duplicate   transfer  read    read/write
                ownership
```

**This is the foundation for understanding the Rust borrow checker.** Once this model is solid, concepts like lifetimes, `Rc`, `Arc`, `RefCell`, iterators, and many crate APIs become much easier to understand.
