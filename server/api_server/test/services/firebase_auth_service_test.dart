import 'package:staccato_api_server/services/firebase_auth.dart';
import 'package:test/test.dart';

void main() {
  group('FirebaseUser', () {
    test('should create user from valid JSON', () {
      final Map<String, dynamic> userData = {
        'localId': 'user-123',
        'email': 'test@example.com',
        'providerUserInfo': [
          {'providerId': 'password'},
        ],
      };

      final FirebaseUser user = FirebaseUser.fromJson(userData);

      expect(user.uid, equals('user-123'));
      expect(user.email, equals('test@example.com'));
      expect(user.isAnonymous, false);
      expect(user.providers, contains('password'));
    });

    test('should handle anonymous user data correctly', () {
      final Map<String, dynamic> userData = {
        'localId': 'anon-user-456',
        'providerUserInfo': [
          {'providerId': 'anonymous'},
        ],
      };

      final FirebaseUser user = FirebaseUser.fromJson(userData);

      expect(user.uid, equals('anon-user-456'));
      expect(user.email, isNull);
      expect(user.isAnonymous, true);
      expect(user.providers, contains('anonymous'));
    });

    test('should serialize to JSON correctly', () {
      const FirebaseUser user = FirebaseUser(
        uid: 'user-789',
        email: 'serialize@example.com',
        isAnonymous: false,
        providers: ['password'],
      );

      final Map<String, dynamic> json = user.toJson();

      expect(json['uid'], equals('user-789'));
      expect(json['email'], equals('serialize@example.com'));
      expect(json['isAnonymous'], false);
      expect(json['providers'], equals(['password']));
    });
  });
}
