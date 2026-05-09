import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Maps Page Up/Down, Home/End, and arrow keys to [ScrollController] movements (web-style).
class KeyboardScrollShortcuts extends StatelessWidget {
  const KeyboardScrollShortcuts({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  static void scrollByViewport(ScrollController c, double direction, {double fraction = 0.88}) {
    if (!c.hasClients) return;
    final position = c.position;
    final delta = direction * position.viewportDimension * fraction;
    final target = (position.pixels + delta).clamp(position.minScrollExtent, position.maxScrollExtent);
    c.jumpTo(target);
  }

  static void scrollToEdge(ScrollController c, bool top) {
    if (!c.hasClients) return;
    final position = c.position;
    c.jumpTo(top ? position.minScrollExtent : position.maxScrollExtent);
  }

  static void scrollByLines(ScrollController c, double direction, {double lineHeight = 56}) {
    if (!c.hasClients) return;
    final position = c.position;
    final delta = direction * lineHeight;
    final target = (position.pixels + delta).clamp(position.minScrollExtent, position.maxScrollExtent);
    c.jumpTo(target);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.pageDown): () => scrollByViewport(controller, 1),
        const SingleActivator(LogicalKeyboardKey.pageUp): () => scrollByViewport(controller, -1),
        const SingleActivator(LogicalKeyboardKey.home): () => scrollToEdge(controller, true),
        const SingleActivator(LogicalKeyboardKey.end): () => scrollToEdge(controller, false),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => scrollByLines(controller, 1),
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => scrollByLines(controller, -1),
      },
      child: child,
    );
  }
}

/// Owns a [ScrollController], keyboard shortcuts, and a vertical [SingleChildScrollView].
class KeyboardSingleChildScrollView extends StatefulWidget {
  const KeyboardSingleChildScrollView({
    super.key,
    required this.child,
    this.padding,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.physics,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final ScrollPhysics? physics;

  @override
  State<KeyboardSingleChildScrollView> createState() => _KeyboardSingleChildScrollViewState();
}

class _KeyboardSingleChildScrollViewState extends State<KeyboardSingleChildScrollView> {
  late final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardScrollShortcuts(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        padding: widget.padding,
        keyboardDismissBehavior: widget.keyboardDismissBehavior,
        physics: widget.physics,
        child: widget.child,
      ),
    );
  }
}
