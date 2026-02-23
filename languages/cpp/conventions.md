# C++ Conventions

## Modern C++ (C++17/20)

Use C++17 minimum. Prefer C++20 features when available.

## Memory Management (RAII + Smart Pointers)

```cpp
// Never use raw new/delete in application code
// Use smart pointers:

// unique_ptr: sole ownership, not shared
auto connection = std::make_unique<DatabaseConnection>(config);

// shared_ptr: shared ownership (use sparingly — prefer unique_ptr)
auto logger = std::make_shared<Logger>("app.log");

// Stack allocation when possible (fastest, automatic cleanup)
User user{.id = 1, .email = "test@example.com"};
```

## Error Handling

```cpp
// Option 1: std::expected (C++23) — preferred for expected errors
#include <expected>

std::expected<User, std::string> GetUser(int id) {
    if (id <= 0) {
        return std::unexpected("User ID must be positive");
    }
    // ... fetch user
    return user;
}

auto result = GetUser(userId);
if (!result) {
    std::cerr << "Error: " << result.error() << "\n";
    return;
}
auto& user = result.value();

// Option 2: Exceptions for truly exceptional situations
// (not control flow)
```

## Naming Conventions

```cpp
// Classes: PascalCase
class UserRepository { ... };

// Functions and variables: snake_case
void process_user(const User& user);
int user_count = 0;

// Constants: UPPER_SNAKE_CASE
constexpr int MAX_CONNECTIONS = 100;

// Member variables: trailing underscore (or m_ prefix)
class Service {
    Database database_;      // or: Database m_database;
    int retry_count_ = 3;
};

// Template parameters: PascalCase
template<typename ValueType>
class Cache { ... };
```

## Resource Management

```cpp
// RAII: acquire in constructor, release in destructor
class FileHandle {
public:
    explicit FileHandle(const std::string& path) 
        : handle_(fopen(path.c_str(), "r")) {
        if (!handle_) throw std::runtime_error("Cannot open: " + path);
    }
    
    ~FileHandle() {
        if (handle_) fclose(handle_);
    }
    
    // Delete copy, allow move
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;
    FileHandle(FileHandle&&) = default;
    FileHandle& operator=(FileHandle&&) = default;
    
private:
    FILE* handle_;
};
```

## Build System (CMake)

```cmake
cmake_minimum_required(VERSION 3.20)
project(MyApp CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Enable warnings
add_compile_options(-Wall -Wextra -Wpedantic)

add_executable(myapp
    src/main.cpp
    src/users/service.cpp
)

target_include_directories(myapp PRIVATE include)

# Link libraries
find_package(nlohmann_json REQUIRED)
target_link_libraries(myapp PRIVATE nlohmann_json::nlohmann_json)
```
