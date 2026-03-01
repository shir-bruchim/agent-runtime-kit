# TypeScript + React Patterns

> **Optional** — include when your project uses React. Pair with `languages/typescript/conventions.md`.

## Component Props

```typescript
// Always type props with an interface
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled?: boolean;
  variant?: "primary" | "secondary" | "danger";
}

export function Button({ label, onClick, disabled = false, variant = "primary" }: ButtonProps) {
  return (
    <button onClick={onClick} disabled={disabled} className={`btn btn-${variant}`}>
      {label}
    </button>
  );
}
```

## Custom Hooks

```typescript
// Return a typed object — easier to consume and extend
function useUser(userId: string): { user: User | null; loading: boolean; error: Error | null } {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  return { user, loading, error };
}
```

## Rules

- Prefer function components over class components.
- Extract logic into custom hooks; keep JSX thin.
- Avoid `any` in event handlers — use `React.ChangeEvent<HTMLInputElement>` etc.
- Use `React.memo` only when profiling shows a real win.