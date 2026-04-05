import 'package:flutter_test/flutter_test.dart';
import 'package:filemanager/widgets/file_item_click_session.dart';

void main() {
  group('FileItemClickSession', () {
    test('single tap invokes select once', () {
      final session = FileItemClickSession();
      var selects = 0;
      var opens = 0;
      session.onPrimaryUpClick(
        select: () => selects++,
        openOnDouble: () => opens++,
      );
      expect(selects, 1);
      expect(opens, 0);
    });

    test('double tap within window invokes open, not second select', () async {
      final session = FileItemClickSession(
        doubleTapMaxInterval: const Duration(milliseconds: 400),
      );
      var selects = 0;
      var opens = 0;
      session.onPrimaryUpClick(
        select: () => selects++,
        openOnDouble: () => opens++,
      );
      expect(selects, 1);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      session.onPrimaryUpClick(
        select: () => selects++,
        openOnDouble: () => opens++,
      );
      expect(selects, 1);
      expect(opens, 1);
    });

    test('two slow clicks are two selects', () async {
      final session = FileItemClickSession(
        doubleTapMaxInterval: const Duration(milliseconds: 50),
      );
      var selects = 0;
      session.onPrimaryUpClick(
        select: () => selects++,
        openOnDouble: () {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
      session.onPrimaryUpClick(
        select: () => selects++,
        openOnDouble: () {},
      );
      expect(selects, 2);
    });

    test('reset clears double-tap pending window', () async {
      final session = FileItemClickSession(
        doubleTapMaxInterval: const Duration(milliseconds: 500),
      );
      var selects = 0;
      var opens = 0;
      session.onPrimaryUpClick(
        select: () => selects++,
        openOnDouble: () => opens++,
      );
      session.reset();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      session.onPrimaryUpClick(
        select: () => selects++,
        openOnDouble: () => opens++,
      );
      expect(selects, 2);
      expect(opens, 0);
    });
  });
}
