// Basic smoke test for the MBG app.
//
// Verifies the app boots on the splash screen and shows the "GET STARTED"
// call-to-action without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App boots on splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MbgApp());
    await tester.pump();

    expect(find.text('MBG'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}