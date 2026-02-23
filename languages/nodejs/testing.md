# Node.js Testing (Jest/Vitest)

## Setup (Vitest — recommended for new projects)

```bash
npm install -D vitest @vitest/coverage-v8 supertest
```

```typescript
// vitest.config.ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    globals: true,
    environment: "node",
    coverage: {
      provider: "v8",
      reporter: ["text", "html"],
      threshold: { lines: 80 },
    },
  },
});
```

## Writing Tests

```typescript
import { describe, it, expect, beforeEach, vi } from "vitest";

describe("UserService", () => {
  let userRepo: MockedObject<UserRepository>;
  let userService: UserService;

  beforeEach(() => {
    userRepo = {
      findById: vi.fn(),
      create: vi.fn(),
      update: vi.fn(),
    };
    userService = new UserService(userRepo);
  });

  describe("getUser", () => {
    it("returns user when found", async () => {
      const mockUser = { id: "1", email: "test@example.com" };
      userRepo.findById.mockResolvedValue(mockUser);

      const result = await userService.getUser("1");

      expect(result).toEqual(mockUser);
      expect(userRepo.findById).toHaveBeenCalledWith("1");
    });

    it("throws NotFoundError when user does not exist", async () => {
      userRepo.findById.mockResolvedValue(null);

      await expect(userService.getUser("999")).rejects.toThrow(NotFoundError);
    });
  });
});
```

## API Integration Tests

```typescript
import supertest from "supertest";
import { app } from "../src/app";

const request = supertest(app);

describe("POST /auth/login", () => {
  it("returns 200 and token with valid credentials", async () => {
    const response = await request
      .post("/auth/login")
      .send({ email: "user@example.com", password: "correct" });

    expect(response.status).toBe(200);
    expect(response.body).toHaveProperty("access_token");
  });

  it("returns 401 with invalid credentials", async () => {
    const response = await request
      .post("/auth/login")
      .send({ email: "user@example.com", password: "wrong" });

    expect(response.status).toBe(401);
  });
});
```

## Running Tests

```bash
npx vitest run           # Run once
npx vitest watch         # Watch mode
npx vitest run --coverage  # With coverage
npx vitest run -t "login"  # Filter by name
```
