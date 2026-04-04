import 'package:bloc_test/bloc_test.dart';
import 'package:finance_companion/data/models/user_model.dart';
import 'package:finance_companion/data/repositories/auth_repository.dart';
import 'package:finance_companion/logic/auth/auth_cubit.dart';
import 'package:finance_companion/logic/auth/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class FakeUserModel extends Fake implements UserModel {}

void main() {
  late MockAuthRepository mockRepo;
  late AuthCubit cubit;

  final testUser = UserModel(
    id: 1,
    name: 'Test',
    email: 'test@example.com',
    passwordHash: 'hash',
    initialBalance: 1000.0,
    monthlyBudget: 500.0,
    currency: 'USD',
    createdAt: DateTime(2023),
  );

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockRepo = MockAuthRepository();
    cubit = AuthCubit(mockRepo);
  });

  tearDown(() {
    cubit.close();
  });

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(cubit.state, isA<AuthInitial>());
    });

    blocTest<AuthCubit, AuthState>(
      'checkAuth emits [AuthLoading, AuthAuthenticated] when user exists',
      build: () {
        when(() => mockRepo.getLoggedInUser()).thenAnswer((_) async => testUser);
        return cubit;
      },
      act: (cubit) => cubit.checkAuth(),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.user.name, 'name', 'Test'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'checkAuth emits [AuthLoading, AuthUnauthenticated] when user is null',
      build: () {
        when(() => mockRepo.getLoggedInUser()).thenAnswer((_) async => null);
        return cubit;
      },
      act: (cubit) => cubit.checkAuth(),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(() => mockRepo.login(email: 'test@example.com', password: 'password'))
            .thenAnswer((_) async => testUser);
        return cubit;
      },
      act: (cubit) => cubit.login(email: 'test@example.com', password: 'password'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having((s) => s.user.email, 'email', 'test@example.com'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'login emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockRepo.login(email: 'test', password: '123'))
            .thenThrow(Exception('Invalid credentials'));
        return cubit;
      },
      act: (cubit) => cubit.login(email: 'test', password: '123'),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((s) => s.message, 'message', 'Invalid credentials'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'logout emits [AuthUnauthenticated]',
      build: () {
        when(() => mockRepo.logout()).thenAnswer((_) async {});
        return cubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        isA<AuthUnauthenticated>(),
      ],
      verify: (_) {
        verify(() => mockRepo.logout()).called(1);
      },
    );
  });
}
