// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
void main() {
  testWidgets('Basic MaterialApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Center(child: Text('ok')))));
    expect(find.text('ok'), findsOneWidget);
  });
}
