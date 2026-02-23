---
name: api-design
description: REST API design principles and patterns. Use when designing new API endpoints, reviewing API structure, defining request/response schemas, handling errors consistently, or establishing API conventions for a project.
---

<objective>
Design clean, consistent, predictable APIs. Applies to REST APIs across all languages and frameworks (FastAPI, Express, Gin, etc.).
</objective>

<principles>

**1. Resource-Oriented Design**
```
# Good: Nouns for resources
GET    /users              → List users
POST   /users              → Create user
GET    /users/{id}         → Get user
PUT    /users/{id}         → Replace user
PATCH  /users/{id}         → Update user fields
DELETE /users/{id}         → Delete user

GET    /users/{id}/posts   → User's posts (nested resource)

# Bad: Verbs in paths
POST /createUser
GET  /getUsers
POST /deleteUser/{id}
```

**2. HTTP Status Codes (Use Them Correctly)**
```
200 OK              — Success with body
201 Created         — Resource created (include Location header)
204 No Content      — Success, no body (DELETE, some PATCHes)
400 Bad Request     — Client sent invalid data
401 Unauthorized    — Not authenticated
403 Forbidden       — Authenticated but not authorized
404 Not Found       — Resource doesn't exist
409 Conflict        — State conflict (duplicate, version mismatch)
422 Unprocessable   — Validation failed
429 Too Many Req.   — Rate limited
500 Internal Error  — Server bug (should never leak details)
```

**3. Consistent Error Response**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {"field": "email", "message": "Invalid email format"},
      {"field": "age", "message": "Must be 18 or older"}
    ]
  }
}
```

Always: same error shape across all endpoints. Never: different error formats in different routes.

**4. Versioning**
```
/api/v1/users    — URL versioning (most common, visible)
/api/v2/users    — New version for breaking changes
```

**5. Pagination**
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "has_next": true
  }
}
```

**6. Input Validation at Boundary**
```python
# FastAPI with Pydantic
class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str = Field(min_length=1, max_length=100)
    age: int = Field(ge=18)
    
@router.post("/users", status_code=201)
async def create_user(data: CreateUserRequest) -> UserResponse:
    ...
```

</principles>

<review_checklist>
When reviewing an API design:
- [ ] Resources are nouns, not verbs
- [ ] HTTP methods used correctly (GET=read, POST=create, etc.)
- [ ] Status codes appropriate for each response
- [ ] Error responses have consistent shape
- [ ] Authentication/authorization applied correctly
- [ ] Input validation on all user-provided data
- [ ] Sensitive data not exposed in responses (passwords, internal IDs)
- [ ] Pagination for list endpoints
- [ ] Versioning strategy defined
</review_checklist>

<language_examples>

### Python — FastAPI
```python
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr, Field

router = APIRouter(prefix="/users", tags=["users"])

class CreateUserRequest(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr

class UserResponse(BaseModel):
    id: int
    name: str
    email: str

@router.post("", status_code=status.HTTP_201_CREATED, response_model=UserResponse)
async def create_user(data: CreateUserRequest, db: Session = Depends(get_db)):
    if await db.get_by_email(data.email):
        raise HTTPException(status.HTTP_409_CONFLICT, "Email already registered")
    user = await db.create_user(data)
    return UserResponse.model_validate(user)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(user_id: int, db: Session = Depends(get_db)):
    user = await db.get_user(user_id)
    if not user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")
    return UserResponse.model_validate(user)
```

### Node.js — Express
```javascript
const router = express.Router();

// POST /users
router.post('/', validateBody(createUserSchema), async (req, res, next) => {
  try {
    const existing = await User.findByEmail(req.body.email);
    if (existing) {
      return res.status(409).json({
        error: { code: 'CONFLICT', message: 'Email already registered' }
      });
    }
    const user = await User.create(req.body);
    res.status(201).location(`/users/${user.id}`).json(toUserResponse(user));
  } catch (err) {
    next(err);
  }
});

// GET /users/:id
router.get('/:id', async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        error: { code: 'NOT_FOUND', message: 'User not found' }
      });
    }
    res.json(toUserResponse(user));
  } catch (err) {
    next(err);
  }
});

// Consistent error shape helper
function toErrorResponse(code, message, details = []) {
  return { error: { code, message, details } };
}
```
</language_examples>

<success_criteria>
API design reviewed or created with consistent resource naming, correct HTTP semantics, uniform error handling, and proper input validation at all boundaries.
</success_criteria>
