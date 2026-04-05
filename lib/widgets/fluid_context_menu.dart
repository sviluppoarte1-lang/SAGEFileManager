import 'package:flutter/material.dart';
import 'dart:async';

/// Widget per menu contestuali fluidi con hover e chiusura automatica
class FluidContextMenu {
  /// Mostra un menu contestuale fluido
  static OverlayEntry show(
    BuildContext context, {
    required Offset position,
    required List<Widget> menuItems,
    Function(String)? onSelected,
    VoidCallback? onDismiss,
    bool dismissOnSelect =
        true, // Whether to dismiss the menu when an item is selected
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    bool isRemoved = false; // Flag per evitare rimozioni multiple

    overlayEntry = OverlayEntry(
      builder: (context) => _FluidContextMenuOverlay(
        position: position,
        menuItems: menuItems,
        onSelected: (value) {
          if (!isRemoved) {
            // Only remove the menu if dismissOnSelect is true
            if (dismissOnSelect) {
              isRemoved = true;
              overlayEntry.remove();
              // Chiama i callback DOPO la rimozione
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onSelected?.call(value);
              });
            } else {
              // Don't dismiss, just call the callback
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onSelected?.call(value);
              });
            }
          }
        },
        onDismiss: () {
          if (!isRemoved) {
            isRemoved = true;
            overlayEntry.remove();
            // Chiama i callback DOPO la rimozione
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onDismiss?.call();
            });
          }
        },
      ),
    );

    overlay.insert(overlayEntry);
    return overlayEntry;
  }
}

class _FluidContextMenuOverlay extends StatefulWidget {
  final Offset position;
  final List<Widget> menuItems;
  final Function(String)? onSelected;
  final VoidCallback? onDismiss;

  const _FluidContextMenuOverlay({
    required this.position,
    required this.menuItems,
    this.onSelected,
    this.onDismiss,
  });

  @override
  State<_FluidContextMenuOverlay> createState() =>
      _FluidContextMenuOverlayState();
}

class _FluidContextMenuOverlayState extends State<_FluidContextMenuOverlay> {
  Timer? _hideTimer;
  bool _isHovering = false;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scheduleHide() {
    if (_isHovering) return;
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted && !_isHovering) {
        widget.onDismiss?.call();
      }
    });
  }

  void _cancelHide() {
    _hideTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calcola la posizione del menu, assicurandosi che non esca dallo schermo
    double left = widget.position.dx;
    double top = widget.position.dy;

    // Assicura che il menu non esca dallo schermo
    const menuWidth = 188.0;
    const menuHeight = 280.0;

    if (left + menuWidth > screenSize.width) {
      left = screenSize.width - menuWidth - 10;
    }
    if (left < 10) {
      left = 10;
    }

    if (top + menuHeight > screenSize.height) {
      top = screenSize.height - menuHeight - 10;
    }
    if (top < 10) {
      top = 10;
    }

    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          // Overlay per catturare click fuori dal menu
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                widget.onDismiss?.call();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Menu stesso - usa GestureDetector per bloccare la propagazione dei click
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () {
                // Blocca la propagazione del click al overlay sottostante
              },
              behavior: HitTestBehavior.opaque,
              child: MouseRegion(
                onEnter: (_) {
                  _isHovering = true;
                  _cancelHide();
                },
                onExit: (_) {
                  _isHovering = false;
                  _scheduleHide();
                },
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.menuItems.map<Widget>((item) {
                      if (item is PopupMenuDivider) {
                        return const Divider(height: 1);
                      }
                      if (item is PopupMenuItem<String>) {
                        final child = item.child;
                        if (child == null) {
                          return const SizedBox.shrink();
                        }
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: item.enabled != false
                                ? () {
                                    widget.onSelected?.call(item.value ?? '');
                                  }
                                : null,
                            child: Opacity(
                              opacity: item.enabled != false ? 1.0 : 0.5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: DefaultTextStyle(
                                  style:
                                      (Theme.of(context).textTheme.bodyMedium ??
                                              const TextStyle(fontSize: 14))
                                          .copyWith(fontSize: 12),
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return item;
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
