# Rust: `Result`, `Option`, `match`, `unwrap`

## 1. `Result<T, E>`

Used when an **operation can succeed or fail**.

```rust
Result<T, E>
```

Two variants:

```rust
Ok(value)   // operation succeeded
Err(error)  // operation failed
```

Mental model:

```text
Result
├── Ok(value) → success
└── Err(error) → failure
```

Example:

```rust
let number = "42".parse::<i32>();
```

Type:

```rust
Result<i32, ParseIntError>
```

---

## 2. `Option<T>`

Used when a **value may or may not exist**.

```rust
Option<T>
```

Two variants:

```rust
Some(value) // value exists
None        // value doesn't exist
```

Mental model:

```text
Option
├── Some(value) → value exists
└── None        → no value
```

Example:

```rust
let user = users.get(0);
```

`get()` returns:

```rust
Option<&User>
```

`None` does **not mean an error**. It simply means there is no value.

---

## 3. `Result<Option<T>, E>`

This is important for real applications.

```rust
Result<Option<User>, DbError>
```

can represent three states:

```text
Ok(Some(user)) → operation succeeded + user found

Ok(None)       → operation succeeded + user not found

Err(error)     → operation itself failed
```

Mental model:

```text
Result
├── Err(error)
│     └── operation failed
│
└── Ok(Option)
      ├── Some(value) → value exists
      └── None        → value absent
```

**Remember:**

```text
Result → Did the operation succeed?
Option → Is there a value?
```

---

## 4. `match`

`match` **checks which pattern a value matches** and executes the corresponding branch.

Example with `Option`:

```rust
match user {
    Some(user) => println!("Found: {}", user),
    None => println!("Not found"),
}
```

Example with `Result`:

```rust
match result {
    Ok(value) => println!("Success: {}", value),
    Err(error) => println!("Error: {}", error),
}
```

With nested `Result<Option<T>, E>`:

```rust
match find_user("oqxo") {
    Ok(Some(user)) => println!("Found: {:?}", user),
    Ok(None) => println!("Not found"),
    Err(error) => println!("Database error: {:?}", error),
}
```

`_` means **anything else**:

```rust
match x {
    1 => println!("one"),
    2 => println!("two"),
    _ => println!("something else"),
}
```

`match` must be **exhaustive** — Rust makes you handle all possible cases.

---

## 5. `unwrap()`

`unwrap()` **extracts the successful/available value**.

For `Result`:

```rust
let result: Result<i32, _> = Ok(42);

let value = result.unwrap();
```

```text
Ok(42)
  ↓
unwrap()
  ↓
42
```

But:

```rust
Err(error).unwrap()
```

→ **panic**

For `Option`:

```rust
Some(42).unwrap()
```

→ `42`

```rust
None.unwrap()
```

→ **panic**

Mental model:

> **"I expect this to contain a value. Give it to me; otherwise panic."**

---

## Final cheat sheet

```text
Result<T, E>
    ↓
operation can fail
    ├── Ok(T)
    └── Err(E)


Option<T>
    ↓
value may be absent
    ├── Some(T)
    └── None


match
    ↓
inspect the variants/patterns
    ├── Ok(...)
    ├── Err(...)
    ├── Some(...)
    └── None


unwrap()
    ↓
extract the value
    ├── Ok(T)    → T
    ├── Some(T)  → T
    └── Err/None → panic
```

### The core mental model

**`Result` = operation outcome**
**`Option` = value existence**
**`match` = handle the possible states**
**`unwrap` = "I guarantee there's a value; give it to me or panic."**
