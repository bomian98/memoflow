import 'package:flutter_test/flutter_test.dart';
import 'package:memos_flutter_app/core/tags.dart';

void main() {
  test('normalizeTagPath preserves tag case', () {
    expect(normalizeTagPath('  #Work / Sub  '), 'Work/Sub');
    expect(normalizeTagPath('#work/Sub'), 'work/Sub');
  });

  test('extractTags preserves tag case and distinguishes variants', () {
    expect(extractTags('#Work #work'), const <String>['Work', 'work']);
  });

  test('extractTags preserves v0.27 backend-compatible characters', () {
    const eyeTag = 'watch\u{1F441}\uFE0F';
    const familyTag =
        'family\u{1F468}\u200D\u{1F469}\u200D\u{1F467}\u200D\u{1F466}';

    expect(
      extractTags('#science&tech #$eyeTag #$familyTag #work/project-2026'),
      const <String>[
        'family\u{1F468}\u200D\u{1F469}\u200D\u{1F467}\u200D\u{1F466}',
        'science&tech',
        'watch\u{1F441}\uFE0F',
        'work/project-2026',
      ],
    );
  });

  test('normalizeTagPath preserves v0.27 backend-compatible characters', () {
    expect(normalizeTagPath('#science&tech'), 'science&tech');
    expect(normalizeTagPath('#watch\u{1F441}\uFE0F'), 'watch\u{1F441}\uFE0F');
    expect(
      normalizeTagPath(
        '#family\u{1F468}\u200D\u{1F469}\u200D\u{1F467}\u200D\u{1F466}',
      ),
      'family\u{1F468}\u200D\u{1F469}\u200D\u{1F467}\u200D\u{1F466}',
    );
  });

  test('extractTags ignores link fragments while keeping real tags', () {
    expect(
      extractTags(
        'Read [section](https://example.com/article#intro) #Work\n\n[jump](#details)',
      ),
      const <String>['Work'],
    );
  });

  test('extractTags ignores fenced code blocks while keeping real tags', () {
    expect(
      extractTags('''#real

```c
#include <stdio.h>
#define DEBUG 1
```

after #done'''),
      const <String>['done', 'real'],
    );
  });

  test('extractTags ignores tilde fenced code blocks', () {
    expect(
      extractTags('''before #visible

~~~dart
final value = '#hidden';
~~~

after'''),
      const <String>['visible'],
    );
  });

  test('extractTags ignores inline code spans while keeping prose tags', () {
    expect(
      extractTags('Use `#include` and `#not-a-tag`, then file under #cpp'),
      const <String>['cpp'],
    );
  });

  test('extractTags keeps visible prose tags across markdown containers', () {
    expect(
      extractTags('''## Planning #heading-tag

- item #list-tag
> quoted #quote-tag

| Topic | Tag |
| - | - |
| Work | #table-tag |

plain #paragraph-tag'''),
      const <String>[
        'heading-tag',
        'list-tag',
        'paragraph-tag',
        'quote-tag',
        'table-tag',
      ],
    );
  });

  test('extractTags scans middle content lines', () {
    expect(
      extractTags('first line #first\n\nmiddle line #middle-tag\nlast line'),
      const <String>['first', 'middle-tag'],
    );
  });
}
