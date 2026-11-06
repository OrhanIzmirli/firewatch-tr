import 'package:flutter_test/flutter_test.dart';
import 'package:firewatch_tr/core/utils/risk_display.dart';
void main() {
  test('Risk boundaries agree across all consumers', () {
    expect([0,24,25,49,50,74,75,100].map(riskLevelForScore), ['Low','Low','Medium','Medium','High','High','Critical','Critical']);
    expect({for (final n in [0,25,50,75]) riskScoreColor(n)}.length, 4);
  });
}
