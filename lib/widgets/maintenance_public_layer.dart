import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

/// Only bundled maintenance illustration (flat / transparent PNG).
abstract final class MaintenanceAssetPaths {
  static const menAtWork = 'assets/images/maintenance/menatwork-removebg-preview.png';
}

/// Provides [maintenanceMode] to the portfolio scroll subtree (for empty sections).
class MaintenanceModeScope extends InheritedWidget {
  final bool maintenanceMode;

  const MaintenanceModeScope({
    super.key,
    required this.maintenanceMode,
    required super.child,
  });

  static bool of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MaintenanceModeScope>()?.maintenanceMode ?? false;
  }

  @override
  bool updateShouldNotify(MaintenanceModeScope oldWidget) {
    return oldWidget.maintenanceMode != maintenanceMode;
  }
}

Widget _menAtWorkAsset({
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
}) {
  return Image.asset(
    MaintenanceAssetPaths.menAtWork,
    width: width,
    height: height,
    fit: fit,
    gaplessPlayback: true,
    filterQuality: FilterQuality.medium,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Icon(
          Icons.engineering_rounded,
          size: height != null ? math.min(height * 0.35, 72) : 56,
          color: const Color(0xFF38BDF8).withValues(alpha: 0.45),
        ),
      );
    },
  );
}

/// Art for empty sections when maintenance is on — responsive layout + framed illustration.
/// No-op if maintenance is off.
class MaintenanceEmptySectionFiller extends StatelessWidget {
  final String? caption;
  final double maxHeight;

  /// When true, wide screens place image on the **start** (left in LTR); when false, on the **end** (right).
  final bool imageLeadingOnWide;

  const MaintenanceEmptySectionFiller({
    super.key,
    this.caption,
    this.maxHeight = 240,
    this.imageLeadingOnWide = true,
  });

  static const _accent = Color(0xFF38BDF8);
  static const _purple = Color(0xFFA855F7);

  Widget _framedIllustration(BuildContext context, {required double boxHeight, required double maxImgWidth}) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxImgWidth),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B).withValues(alpha: 0.95),
            const Color(0xFF0F172A).withValues(alpha: 0.98),
          ],
        ),
        border: Border.all(color: _accent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: _accent.withValues(alpha: 0.15),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: _purple.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: SizedBox(
        height: boxHeight,
        width: double.infinity,
        child: _menAtWorkAsset(fit: BoxFit.contain),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -6, duration: 3.seconds, curve: Curves.easeInOut);
  }

  Widget _captionBlock(BuildContext context, {required TextAlign align}) {
    if (caption == null) return const SizedBox.shrink();
    final cross = switch (align) {
      TextAlign.center => CrossAxisAlignment.center,
      TextAlign.right => CrossAxisAlignment.end,
      _ => CrossAxisAlignment.start,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: cross,
        children: [
          Container(
            width: 36,
            height: 3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(colors: [_accent, _purple]),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            caption!,
            textAlign: align,
            style: GoogleFonts.poppins(
              color: Colors.white60,
              fontSize: 13,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!MaintenanceModeScope.of(context)) return const SizedBox.shrink();

    final screenW = MediaQuery.sizeOf(context).width;
    final padH = screenW > 800 ? 0.0 : 8.0;

    // Explicit heights so the PNG always paints (avoids zero-height layout gaps).
    final imgBoxH = screenW < 420
        ? math.min(maxHeight, 200.0)
        : screenW < 720
            ? math.min(maxHeight + 20, 260.0)
            : math.min(maxHeight + 60, 300.0);

    final maxImgW = screenW < 520 ? screenW - 56 : math.min(440.0, screenW * 0.42);

    final captionWide = screenW >= 720;

    // Desktop / tablet: side-by-side — image left or right for balance with viewport.
    if (captionWide) {
      if (caption == null) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
          child: Center(
            child: _framedIllustration(
              context,
              boxHeight: imgBoxH,
              maxImgWidth: math.min(520.0, screenW - 80),
            ),
          ),
        );
      }

      final imageFirst = imageLeadingOnWide;
      final img = Expanded(
        flex: 10,
        child: Align(
          alignment: imageFirst ? Alignment.centerRight : Alignment.centerLeft,
          child: _framedIllustration(context, boxHeight: imgBoxH, maxImgWidth: maxImgW),
        ),
      );
      final text = Expanded(
        flex: 9,
        child: Align(
          alignment: imageFirst ? Alignment.centerLeft : Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padH + 12),
            child: _captionBlock(context, align: imageFirst ? TextAlign.left : TextAlign.right),
          ),
        ),
      );

      return Padding(
        padding: EdgeInsets.fromLTRB(8, 16, 8, 24),
        child: screenW >= 960
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: imageFirst ? [img, const SizedBox(width: 28), text] : [text, const SizedBox(width: 28), img],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: imageFirst ? [img, const SizedBox(width: 16), text] : [text, const SizedBox(width: 16), img],
              ),
      );
    }

    // Phone: stacked, illustration centered — maximum clarity.
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: _framedIllustration(context, boxHeight: imgBoxH, maxImgWidth: screenW - 40),
          ),
          if (caption != null) ...[
            const SizedBox(height: 18),
            _captionBlock(context, align: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Scrollable intro ribbon — sits below the app bar inside the page.
class MaintenanceIntroRibbon extends StatelessWidget {
  const MaintenanceIntroRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 520;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, isNarrow ? 12 : 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF59E0B).withValues(alpha: 0.95),
              const Color(0xFFEA580C).withValues(alpha: 0.92),
              const Color(0xFFCA8A04).withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: _menAtWorkAsset(height: 80)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.02, 1.02),
                          duration: 2.4.seconds,
                          curve: Curves.easeInOut,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Under maintenance',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1C1917),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Polishing sections & shipping upgrades — everything still works. Thanks for looking!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF292524),
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _menAtWorkAsset(width: 100, height: 84)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.03, 1.03),
                          duration: 2.5.seconds,
                          curve: Curves.easeInOut,
                        ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Under maintenance',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF1C1917),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Polishing sections & shipping upgrades — everything still works. Thanks for looking!',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF292524),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.05, curve: Curves.easeOut);
  }
}

/// Light viewport accents — does not block interaction. Main art lives in empty sections + ribbon.
class MaintenanceSpriteOverlay extends StatelessWidget {
  final bool enabled;

  const MaintenanceSpriteOverlay({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    final size = MediaQuery.sizeOf(context);

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              bottom: size.height * 0.12,
              left: size.width * 0.06,
              child: _bobbingEmoji('🧰', 26),
            ),
            Positioned(
              bottom: size.height * 0.2,
              right: size.width * 0.06,
              child: _bobbingEmoji('🔧', 24, delayMs: 400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bobbingEmoji(String emoji, double fontSize, {int delayMs = 0}) {
    return Opacity(
      opacity: 0.75,
      child: Text(emoji, style: TextStyle(fontSize: fontSize)),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -7, duration: 2.2.seconds, delay: delayMs.ms, curve: Curves.easeInOut)
        .fadeIn(duration: 400.ms);
  }
}

/// Strip between sections when maintenance is on.
class MaintenanceSectionAccent extends StatelessWidget {
  const MaintenanceSectionAccent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.55,
            child: _menAtWorkAsset(height: 26),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '·',
              style: GoogleFonts.poppins(color: Colors.white30, fontSize: 14),
            ),
          ),
          Text(
            '🔧',
            style: const TextStyle(fontSize: 18),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(begin: 1, end: 0.45, duration: 1.8.seconds),
        ],
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .fadeIn(duration: 600.ms),
    );
  }
}
