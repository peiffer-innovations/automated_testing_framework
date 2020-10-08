import 'package:flutter_test/flutter_test.dart';

void main() {
  test('variables', () {
    var regex = RegExp(r'\{\{[^(})]*}}]*');

    var matches = regex.allMatches('foo');
    expect(matches.isEmpty, true);

    matches = regex.allMatches('{{a}}');
    expect(matches.first.group(0), '{{a}}');
    expect(matches.length == 1, true);
    expect(matches.first.start, 0);
    expect(matches.first.end, 5);

    matches = regex.allMatches('{{a}}_{{b}}');
    expect(matches.length == 2, true);
    expect(matches.first.group(0), '{{a}}');
    expect(matches.first.start, 0);
    expect(matches.first.end, 5);
    expect(matches.last.group(0), '{{b}}');
    expect(matches.last.start, 6);
    expect(matches.last.end, 11);

    matches = regex.allMatches('{{a}}_{{b}} YeeHaw!!! {{c}}');
    expect(matches.length == 3, true);
    expect(matches.first.group(0), '{{a}}');
    expect(matches.first.start, 0);
    expect(matches.first.end, 5);
    expect(matches.last.group(0), '{{c}}');
    expect(matches.last.start, 22);
    expect(matches.last.end, 27);
  });
}
