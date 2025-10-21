# Family Management Endpoints

This document describes the family management endpoints for the Staccato API server.

## Overview

The family management system provides endpoints for creating, reading, updating, and deleting family groups. Each family has a primary administrator and can contain multiple members with different permission levels.

## Endpoints

### Create Family

**POST** `/api/families`

Creates a new family group with the authenticated user as the primary administrator.

**Request Body:**
```json
{
  "name": "The Smith Family",
  "settings": {
    "timezone": "America/New_York",
    "maxFamilyMembers": 10,
    "allowChildRegistration": true,
    "requireAdultApproval": true
  }
}
```

**Response (201 Created):**
```json
{
  "id": "family_123",
  "name": "The Smith Family",
  "primaryUserId": "user_456",
  "settings": {
    "timezone": "America/New_York",
    "maxFamilyMembers": 10,
    "allowChildRegistration": true,
    "requireAdultApproval": true
  },
  "createdAt": "2025-01-10T14:30:00Z",
  "updatedAt": "2025-01-10T14:30:00Z"
}
```

### List Families

**GET** `/api/families`

Retrieves all families where the authenticated user is the primary administrator.

**Query Parameters:**
- `limit` (optional): Maximum number of families to return
- `offset` (optional): Number of families to skip for pagination

**Response (200 OK):**
```json
[
  {
    "id": "family_123",
    "name": "The Smith Family",
    "primaryUserId": "user_456",
    "settings": { ... },
    "createdAt": "2025-01-10T14:30:00Z",
    "updatedAt": "2025-01-10T14:30:00Z"
  }
]
```

### Get Family

**GET** `/api/families/{id}`

Retrieves a specific family by ID, optionally including member details.

**Path Parameters:**
- `id`: The unique family identifier

**Query Parameters:**
- `includeMembers` (optional): Whether to include member details (default: true)

**Response (200 OK) with members:**
```json
{
  "family": {
    "id": "family_123",
    "name": "The Smith Family",
    "primaryUserId": "user_456",
    "settings": { ... },
    "createdAt": "2025-01-10T14:30:00Z",
    "updatedAt": "2025-01-10T14:30:00Z"
  },
  "members": [
    {
      "id": "user_456",
      "displayName": "John Smith",
      "permissionLevel": "primary",
      "profileImageUrl": "https://..."
    },
    {
      "id": "user_789",
      "displayName": "Jane Smith",
      "permissionLevel": "adult",
      "profileImageUrl": "https://..."
    }
  ],
  "memberCount": 2,
  "isAtMemberLimit": false
}
```

### Update Family

**PUT** `/api/families/{id}`

Updates an existing family. Only the primary administrator can update family settings.

**Path Parameters:**
- `id`: The unique family identifier

**Request Body:**
```json
{
  "name": "Updated Family Name",
  "settings": {
    "timezone": "America/Los_Angeles",
    "maxFamilyMembers": 15
  }
}
```

**Response (200 OK):**
```json
{
  "id": "family_123",
  "name": "Updated Family Name",
  "primaryUserId": "user_456",
  "settings": {
    "timezone": "America/Los_Angeles",
    "maxFamilyMembers": 15,
    "allowChildRegistration": true,
    "requireAdultApproval": true
  },
  "createdAt": "2025-01-10T14:30:00Z",
  "updatedAt": "2025-01-10T15:45:00Z"
}
```

### Delete Family

**DELETE** `/api/families/{id}`

Permanently deletes a family group. Only the primary administrator can delete a family.

**Path Parameters:**
- `id`: The unique family identifier

**Response (204 No Content):** Empty response body on successful deletion.

## Error Responses

### 400 Bad Request
```json
{
  "error": "Validation failed",
  "code": "VALIDATION_ERROR",
  "field": "name"
}
```

### 401 Unauthorized
```json
{
  "error": "Authentication required"
}
```

### 403 Forbidden
```json
{
  "error": "Only the primary administrator can delete the family"
}
```

### 404 Not Found
```json
{
  "error": "Family not found"
}
```

### 500 Internal Server Error
```json
{
  "error": "Internal server error"
}
```

## Authentication

All endpoints require authentication. The authenticated user's ID is used to:
- Set the primary administrator when creating families
- Filter families in list operations
- Validate permissions for update and delete operations

## Data Models

### Family Settings

```json
{
  "timezone": "America/New_York",
  "maxFamilyMembers": 10,
  "allowChildRegistration": true,
  "requireAdultApproval": true
}
```

### Family Member Summary

```json
{
  "id": "user_456",
  "displayName": "John Smith",
  "permissionLevel": "primary",
  "profileImageUrl": "https://..."
}
```

## Implementation Notes

- Family IDs are generated as UUIDs
- All timestamps are in ISO 8601 format with UTC timezone
- Member lists are automatically sorted (primary first, then adults, then children)
- Family deletion is permanent and cannot be undone
- Maximum family size is configurable per family (default: 10 members)