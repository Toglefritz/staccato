# Firebase Architecture Guidelines

## Free Tier Constraints

This project must operate within Firebase free tier limits. All architectural decisions should consider these constraints:

### Firestore Limits (Spark Plan)
- **Reads**: 50,000 per day
- **Writes**: 20,000 per day  
- **Deletes**: 20,000 per day
- **Storage**: 1 GiB total
- **Bandwidth**: 10 GiB per month

### Firebase Storage Limits
- **Storage**: 5 GB total
- **Downloads**: 1 GB per day
- **Uploads**: 1 GB per day

### Cloud Functions Limits
- **Invocations**: 125,000 per month
- **GB-seconds**: 40,000 per month
- **CPU-seconds**: 40,000 per month

## Data Architecture Strategy

### Optimize for Read Efficiency
- Denormalize data to reduce read operations
- Use subcollections sparingly to avoid deep queries
- Cache frequently accessed data locally
- Implement offline-first architecture with sync

### Collection Structure

```
families/{familyId}
├── members/{memberId}
├── tasks/{taskId}
├── events/{eventId}
├── lists/{listId}
└── settings/config
```

### Document Design Patterns

#### Family Document
```dart
class Family {
  final String id;
  final String name;
  final List<String> memberIds;
  final Map<String, String> memberColors;
  final FamilySettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

#### Task Document (Denormalized)
```dart
class Task {
  final String id;
  final String familyId;
  final String title;
  final String description;
  final String assignedMemberId;
  final String assignedMemberName; // Denormalized for display
  final String assignedMemberColor; // Denormalized for UI
  final TaskStatus status;
  final DateTime dueDate;
  final bool isRecurring;
  final RecurrencePattern? recurrence;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

## Optimization Strategies

### Local Caching
- Cache all family data locally using Hive or SharedPreferences
- Implement background sync with conflict resolution
- Use Firestore offline persistence for automatic caching

### Batch Operations
- Group related writes into batch operations
- Use transactions for data consistency
- Minimize individual document updates

### Real-time Listeners
- Use targeted listeners with specific queries
- Implement listener lifecycle management
- Avoid listening to entire collections

### Image Optimization
- Compress images before upload
- Use Firebase Storage with CDN caching
- Implement progressive image loading
- Consider image resizing on upload

## Security Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Family access control
    match /families/{familyId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.memberIds;
      
      // Nested collections inherit family permissions
      match /{document=**} {
        allow read, write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/families/$(familyId)).data.memberIds;
      }
    }
  }
}
```

### Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /families/{familyId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid in firestore.get(/databases/(default)/documents/families/$(familyId)).data.memberIds;
    }
  }
}
```

## Performance Guidelines

### Query Optimization
- Use composite indexes for complex queries
- Limit query results with pagination
- Avoid array-contains queries on large arrays
- Use where clauses to filter at the database level

### Offline Strategy
- Implement robust offline functionality
- Handle network state changes gracefully
- Provide clear offline/online status indicators
- Queue operations for when connectivity returns

### Memory Management
- Dispose of Firestore listeners properly
- Use weak references for cached data
- Implement data cleanup for old tasks/events
- Monitor memory usage in kiosk mode

## Monitoring and Analytics

### Usage Tracking
- Monitor Firestore read/write operations
- Track Storage usage and bandwidth
- Set up alerts for approaching limits
- Implement usage analytics dashboard

### Error Handling
- Implement comprehensive error logging
- Handle quota exceeded scenarios gracefully
- Provide fallback functionality when limits reached
- User-friendly error messages for network issues

## Development Best Practices

### Testing Strategy
- Use Firebase Emulator Suite for local development
- Test offline scenarios thoroughly
- Validate security rules with unit tests
- Performance test with realistic data volumes

### Deployment Strategy
- Use Firebase projects for different environments
- Implement gradual rollout for updates
- Monitor performance after deployments
- Have rollback procedures ready