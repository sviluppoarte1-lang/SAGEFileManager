import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

bool _primaryFocusInEditableText() {
  final ctx = FocusManager.instance.primaryFocus?.context;
  if (ctx == null) return false;
  return ctx.findAncestorWidgetOfExactType<EditableText>() != null;
}

/// Avvolge il contenuto di un dialog: Invio / Invio numerico conferma se il focus
/// non è in un campo di testo (così i [TextField] restano utilizzabili).
class DialogEnterScope extends StatelessWidget {
  const DialogEnterScope({
    super.key,
    required this.onEnterPressed,
    required this.child,
  });

  final VoidCallback onEnterPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.enter): () {
          if (_primaryFocusInEditableText()) return;
          onEnterPressed();
        },
        const SingleActivator(LogicalKeyboardKey.numpadEnter): () {
          if (_primaryFocusInEditableText()) return;
          onEnterPressed();
        },
      },
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: child,
      ),
    );
  }
}
