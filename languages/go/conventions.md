# Go Conventions

## Project Structure

```
cmd/
└── server/
    └── main.go       # Entry point
internal/             # Private packages (not importable externally)
├── users/
│   ├── handler.go    # HTTP handlers
│   ├── service.go    # Business logic
│   ├── repository.go # Database layer
│   └── models.go     # Domain types
├── middleware/
│   ├── auth.go
│   └── logging.go
└── database/
    └── postgres.go
pkg/                  # Public packages (importable by external code)
└── validator/
go.mod
go.sum
```

## Idiomatic Go

```go
// Error handling: check errors explicitly, return early
func GetUser(id int) (*User, error) {
    user, err := db.QueryUser(id)
    if err != nil {
        return nil, fmt.Errorf("GetUser: %w", err) // Wrap with context
    }
    if user == nil {
        return nil, ErrNotFound
    }
    return user, nil
}

// Sentinel errors for expected error conditions
var (
    ErrNotFound   = errors.New("not found")
    ErrUnauthorized = errors.New("unauthorized")
)

// Use errors.Is() to check:
if errors.Is(err, ErrNotFound) { ... }
```

## Interfaces

```go
// Define interfaces where they're used (consumer-side), not where implemented
// Repository interface defined in service package, not repository package
type UserRepository interface {
    GetByID(ctx context.Context, id int) (*User, error)
    Create(ctx context.Context, user *User) error
    Update(ctx context.Context, user *User) error
}

type UserService struct {
    repo UserRepository // Depends on interface, not concrete type
}
```

## Context Usage

```go
// Always pass context as first parameter
func GetUser(ctx context.Context, id int) (*User, error) {
    // Check if context is cancelled
    select {
    case <-ctx.Done():
        return nil, ctx.Err()
    default:
    }
    
    return db.QueryContext(ctx, "SELECT ...", id)
}
```

## HTTP Handlers (standard library or chi)

```go
func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
    id, err := strconv.Atoi(chi.URLParam(r, "id"))
    if err != nil {
        http.Error(w, "Invalid user ID", http.StatusBadRequest)
        return
    }
    
    user, err := h.service.GetUser(r.Context(), id)
    if errors.Is(err, ErrNotFound) {
        http.Error(w, "User not found", http.StatusNotFound)
        return
    }
    if err != nil {
        http.Error(w, "Internal server error", http.StatusInternalServerError)
        return
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(user)
}
```
