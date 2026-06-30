# Frontend Performance

- Minimize bundle size: code splitting, tree shaking, lazy loading
- Avoid layout thrashing (batch DOM reads/writes)
- Use `React.memo` / `useMemo` only when profiling shows need
- Images: proper format (WebP), sizes (srcset), lazy loading