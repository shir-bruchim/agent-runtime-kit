# C++ Testing (Google Test / Catch2)

## Google Test Setup (CMake)

```cmake
# CMakeLists.txt
include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/v1.14.0.tar.gz
)
FetchContent_MakeAvailable(googletest)

add_executable(tests
    tests/user_service_test.cpp
)
target_link_libraries(tests GTest::gtest_main)
include(GoogleTest)
gtest_discover_tests(tests)
```

## Writing Google Tests

```cpp
#include <gtest/gtest.h>

class UserServiceTest : public ::testing::Test {
protected:
    void SetUp() override {
        mock_repo_ = std::make_unique<MockUserRepo>();
        service_ = std::make_unique<UserService>(*mock_repo_);
    }

    std::unique_ptr<MockUserRepo> mock_repo_;
    std::unique_ptr<UserService> service_;
};

TEST_F(UserServiceTest, GetUser_ReturnsUser_WhenExists) {
    // Arrange
    User expected_user{.id = 1, .email = "test@example.com"};
    EXPECT_CALL(*mock_repo_, GetById(1))
        .WillOnce(Return(expected_user));

    // Act
    auto result = service_->GetUser(1);

    // Assert
    ASSERT_TRUE(result.has_value());
    EXPECT_EQ(result->email, "test@example.com");
}

TEST_F(UserServiceTest, GetUser_ReturnsError_WhenNotFound) {
    EXPECT_CALL(*mock_repo_, GetById(999))
        .WillOnce(Return(std::unexpected("Not found")));

    auto result = service_->GetUser(999);

    EXPECT_FALSE(result.has_value());
    EXPECT_EQ(result.error(), "Not found");
}

// Parametrized tests
struct ValidationTestCase {
    std::string input;
    bool expected_valid;
};

class EmailValidationTest : public ::testing::TestWithParam<ValidationTestCase> {};

TEST_P(EmailValidationTest, ValidatesCorrectly) {
    auto [input, expected] = GetParam();
    EXPECT_EQ(IsValidEmail(input), expected);
}

INSTANTIATE_TEST_SUITE_P(
    EmailValidation,
    EmailValidationTest,
    ::testing::Values(
        ValidationTestCase{"user@example.com", true},
        ValidationTestCase{"not-an-email", false},
        ValidationTestCase{"", false}
    )
);
```

## Running Tests

```bash
cmake --build build --target tests
./build/tests                      # Run all
./build/tests --gtest_filter="User*"  # Filter
./build/tests --gtest_list_tests   # List all tests
```
