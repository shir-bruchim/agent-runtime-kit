# TypeScript Conventions

## Strict Mode (Always On)

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noUncheckedIndexedAccess": true
  }
}
```

## Type Patterns

```typescript
// Prefer interfaces for object shapes
interface User {
  id: string;
  email: string;
  role: "admin" | "user";
  createdAt: Date;
}

// Use type for unions/intersections/mapped types
type ApiResponse<T> = 
  | { success: true; data: T }
  | { success: false; error: string };

type PartialUser = Partial<Pick<User, "email" | "role">>;

// Avoid: any (use unknown + type guards instead)
function processInput(input: unknown) {
  if (typeof input === "string") {
    return input.toUpperCase(); // TypeScript knows it's a string here
  }
}

// Use const assertions for literal types
const ROLES = ["admin", "user", "moderator"] as const;
type Role = typeof ROLES[number]; // "admin" | "user" | "moderator"
```

## Error Handling Pattern

```typescript
// Result type instead of throw for expected errors
type Result<T, E = Error> = 
  | { ok: true; value: T }
  | { ok: false; error: E };

async function createUser(email: string): Promise<Result<User, "EMAIL_TAKEN" | "INVALID_EMAIL">> {
  if (!isValidEmail(email)) {
    return { ok: false, error: "INVALID_EMAIL" };
  }
  const existing = await findByEmail(email);
  if (existing) {
    return { ok: false, error: "EMAIL_TAKEN" };
  }
  const user = await insertUser(email);
  return { ok: true, value: user };
}

// Caller handles each case explicitly
const result = await createUser(email);
if (!result.ok) {
  if (result.error === "EMAIL_TAKEN") { /* ... */ }
  if (result.error === "INVALID_EMAIL") { /* ... */ }
} else {
  console.log(result.value.id);
}
```
