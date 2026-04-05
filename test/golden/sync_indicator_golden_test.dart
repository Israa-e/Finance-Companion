import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_companion/logic/connectivity/connectivity_cubit.dart';
import 'package:finance_companion/presentation/shared/widgets/sync_indicator.dart';
import '../helpers/font_test_helper.dart';

class MockConnectivityCubit extends Mock implements ConnectivityCubit {}

void main() {
  FontTestHelper.initialize();
  late MockConnectivityCubit mockCubit;

  setUp(() {
    mockCubit = MockConnectivityCubit();
  });

  Widget createWidgetUnderTest(ConnectivityStatus status) {
    when(() => mockCubit.state).thenReturn(ConnectivityState(status: status));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: BlocProvider<ConnectivityCubit>.value(
          value: mockCubit,
          child: const Center(
            child: SizedBox(
              width: 150,
              height: 50,
              child: SyncIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('SyncIndicator Golden Test - Online', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(ConnectivityStatus.online));
    await tester.pump();
    await expectLater(
      find.byType(SyncIndicator),
      matchesGoldenFile('goldens/sync_indicator_online.png'),
    );
  });

  testWidgets('SyncIndicator Golden Test - Offline', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(ConnectivityStatus.offline));
    await tester.pump();
    await expectLater(
      find.byType(SyncIndicator),
      matchesGoldenFile('goldens/sync_indicator_offline.png'),
    );
  });
}
