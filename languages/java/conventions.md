# Java Conventions

## Modern Java (Java 17+)

```java
// Records for immutable data (Java 16+)
public record UserDto(long id, String email, String name) {}

// Sealed classes for restricted hierarchies (Java 17+)
public sealed interface Result<T> permits Result.Success, Result.Error {
    record Success<T>(T value) implements Result<T> {}
    record Error<T>(String message) implements Result<T> {}
}

// Pattern matching (Java 16+)
switch (result) {
    case Result.Success<User> s -> processUser(s.value());
    case Result.Error<User> e -> handleError(e.message());
}
```

## Spring Boot Conventions

```java
// Controller: handle HTTP, delegate to service
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
        return userService.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserDto createUser(@Valid @RequestBody CreateUserRequest request) {
        return userService.create(request);
    }
}

// Service: business logic only
@Service
@Transactional
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    public Optional<UserDto> findById(Long id) {
        return userRepository.findById(id)
            .map(UserMapper::toDto);
    }
}

// Repository: data access
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    List<User> findByActive(boolean active);
}
```

## Error Handling (Spring)

```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(UserNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleNotFound(UserNotFoundException ex) {
        return new ErrorResponse("USER_NOT_FOUND", ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleValidation(MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult()
            .getFieldErrors()
            .stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .toList();
        return new ErrorResponse("VALIDATION_ERROR", errors.toString());
    }
}
```
