# Node.js Conventions

## Runtime and Version Management

Use Node.js LTS (current: 20.x). Use `nvm` or `.nvmrc` for version pinning:
```
# .nvmrc
20.12.0
```

## Project Structure (Express/Fastify)

```
src/
├── app.ts           # Express app setup (no server start)
├── server.ts        # Server entry point (port binding)
├── config.ts        # Zod-validated environment variables
├── middleware/
│   ├── auth.ts      # JWT verification
│   └── errors.ts    # Global error handler
├── routes/
│   └── users.ts     # Route definitions
├── services/
│   └── users.ts     # Business logic
├── repositories/
│   └── users.ts     # Database queries
└── types/
    └── index.ts     # Shared type definitions
```

## Configuration with Zod

```typescript
import { z } from "zod";

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
});

export const config = envSchema.parse(process.env);
```

## Async/Error Handling

```typescript
// Always handle async errors — unhandled rejections crash the process
router.get("/users/:id", async (req, res, next) => {
  try {
    const user = await userService.getById(req.params.id);
    if (!user) return res.status(404).json({ error: "User not found" });
    res.json(user);
  } catch (err) {
    next(err); // Pass to error handler middleware
  }
});

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: "Internal server error" });
});
```

## TypeScript Setup

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "lib": ["ES2022"],
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "outDir": "dist",
    "rootDir": "src",
    "esModuleInterop": true
  }
}
```

## Package Scripts

```json
{
  "scripts": {
    "dev": "tsx watch src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest --runInBand",
    "test:watch": "jest --watch",
    "lint": "eslint src --ext .ts",
    "format": "prettier --write src"
  }
}
```
