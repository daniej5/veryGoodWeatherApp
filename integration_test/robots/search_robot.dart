import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SearchRobot {
  const SearchRobot(this.tester);

  final WidgetTester tester;

  Future<void> enterSearchTerm(String term) async {
    await tester.enterText(find.byType(TextField), term);
    await tester.pumpAndSettle();
  }

  Future<void> submitSearch() async {
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
  }
}
