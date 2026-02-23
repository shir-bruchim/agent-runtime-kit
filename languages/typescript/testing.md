# TypeScript Testing

See `languages/nodejs/testing.md` for Jest/Vitest setup.

## TypeScript-Specific Patterns

```typescript
// Type-safe mocks
import { vi, MockedFunction } from "vitest";

const mockFetch: MockedFunction<typeof fetch> = vi.fn();

mockFetch.mockResolvedValue({
  ok: true,
  json: async () => ({ id: "1", name: "Test" }),
} as Response);
```

## Testing React Components (Testing Library)

```typescript
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

describe("LoginForm", () => {
  it("calls onSubmit with credentials when form submitted", async () => {
    const mockSubmit = vi.fn();
    const user = userEvent.setup();

    render(<LoginForm onSubmit={mockSubmit} />);

    await user.type(screen.getByLabelText("Email"), "test@example.com");
    await user.type(screen.getByLabelText("Password"), "secret");
    await user.click(screen.getByRole("button", { name: "Login" }));

    expect(mockSubmit).toHaveBeenCalledWith({
      email: "test@example.com",
      password: "secret",
    });
  });

  it("shows error message when email is invalid", async () => {
    const user = userEvent.setup();
    render(<LoginForm onSubmit={vi.fn()} />);

    await user.type(screen.getByLabelText("Email"), "not-an-email");
    await user.click(screen.getByRole("button", { name: "Login" }));

    expect(screen.getByText("Invalid email address")).toBeInTheDocument();
  });
});
```
