# Go Testing

## Standard Library Testing

```go
// users_test.go
package users_test

import (
    "context"
    "errors"
    "testing"
)

func TestGetUser_ReturnsUser_WhenExists(t *testing.T) {
    // Arrange
    repo := &mockUserRepo{
        users: map[int]*User{1: {ID: 1, Email: "test@example.com"}},
    }
    service := NewUserService(repo)

    // Act
    user, err := service.GetUser(context.Background(), 1)

    // Assert
    if err != nil {
        t.Fatalf("expected no error, got: %v", err)
    }
    if user.Email != "test@example.com" {
        t.Errorf("expected email 'test@example.com', got '%s'", user.Email)
    }
}

func TestGetUser_ReturnsNotFound_WhenMissing(t *testing.T) {
    repo := &mockUserRepo{users: map[int]*User{}}
    service := NewUserService(repo)

    _, err := service.GetUser(context.Background(), 999)

    if !errors.Is(err, ErrNotFound) {
        t.Errorf("expected ErrNotFound, got: %v", err)
    }
}
```

## Table-Driven Tests

```go
func TestCalculateDiscount(t *testing.T) {
    tests := []struct {
        name     string
        price    float64
        percent  int
        expected float64
    }{
        {"10% off $100", 100.0, 10, 90.0},
        {"zero discount", 100.0, 0, 100.0},
        {"100% off", 100.0, 100, 0.0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := calculateDiscount(tt.price, tt.percent)
            if got != tt.expected {
                t.Errorf("calculateDiscount(%v, %v) = %v, want %v",
                    tt.price, tt.percent, got, tt.expected)
            }
        })
    }
}
```

## Mock Interfaces

```go
// Define mock in test file (not a separate package)
type mockUserRepo struct {
    users map[int]*User
    err   error // Return this error if set
}

func (m *mockUserRepo) GetByID(ctx context.Context, id int) (*User, error) {
    if m.err != nil {
        return nil, m.err
    }
    user, ok := m.users[id]
    if !ok {
        return nil, ErrNotFound
    }
    return user, nil
}

func (m *mockUserRepo) Create(ctx context.Context, user *User) error {
    m.users[user.ID] = user
    return m.err
}
```

## Running Tests

```bash
go test ./...              # All packages
go test ./internal/users/  # Single package
go test -v -run TestGetUser  # Verbose, filter by name
go test -race ./...        # Race condition detector (always use in CI)
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out  # HTML coverage report
```
