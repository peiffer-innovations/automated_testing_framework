import 'package:automated_testing_framework/automated_testing_framework.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TestStatusAlignment', () {
    expect(TestStatusAlignment.bottom.toString(), 'bottom');
    expect(TestStatusAlignment.bottomSafe.toString(), 'bottomSafe');
    expect(TestStatusAlignment.center.toString(), 'center');
    expect(TestStatusAlignment.top.toString(), 'top');
    expect(TestStatusAlignment.topSafe.toString(), 'topSafe');

    expect(
      TestStatusAlignment.fromString('bottom'),
      TestStatusAlignment.bottom,
    );
    expect(
      TestStatusAlignment.fromString('bottomSafe'),
      TestStatusAlignment.bottomSafe,
    );
    expect(
      TestStatusAlignment.fromString('center'),
      TestStatusAlignment.center,
    );
    expect(
      TestStatusAlignment.fromString('top'),
      TestStatusAlignment.top,
    );
    expect(
      TestStatusAlignment.fromString('topSafe'),
      TestStatusAlignment.topSafe,
    );
  });
}
