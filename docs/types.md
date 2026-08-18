```text
                         RUST TYPES
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
     Primitive Types     Compound Types     User-defined Types
          │                  │                  │
     ┌────┼────┐         ┌───┴────┐        ┌───┴────┐
     │    │    │         │        │        │        │
    i32  f64  bool     Tuple    Array    Struct    Enum
    u64  f32  char
    usize
    str
```

Then **generics are a mechanism for making types reusable**. They aren't a category sitting underneath primitive types:

```text
                         GENERICS
                            │
              ┌─────────────┼─────────────┐
              │             │             │
          Option<T>      Result<T,E>     Vec<T>
              │             │
              │             │
        Option<String>  Result<User, Error>
        Option<i32>     Result<Response, Error>
```

And references are another type constructor:

```text
                         REFERENCES
                             │
                    ┌────────┴────────┐
                    │                 │
                   &T               &mut T
                    │                 │
                  &str            &mut String
```

### The key distinction

Think of it this way:

```text
i32
String
User
Error
Response
```

are **concrete types**.

Whereas:

```text
Option<T>
Result<T, E>
Vec<T>
```

are **generic type definitions** that become concrete when you give them types:

```text
Option<i32>
Option<String>

Vec<u8>
Vec<String>

Result<User, Error>
Result<Response, reqwest::Error>
```
