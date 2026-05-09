import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Rough device category from intrinsic image dimensions (no extra metadata).
enum ScreenshotKind { mobile, tablet, desktop }

ScreenshotKind classifyScreenshotSize(double width, double height) {
  if (width <= 0 || height <= 0) return ScreenshotKind.tablet;
  if (height > width) {
    final tallRatio = height / width;
    if (tallRatio >= 1.12) return ScreenshotKind.mobile;
    return ScreenshotKind.tablet;
  }
  final wideRatio = width / height;
  if (wideRatio >= 1.22) return ScreenshotKind.desktop;
  return ScreenshotKind.tablet;
}

Future<Size?> decodeNetworkImageSize(String url) {
  final completer = Completer<Size?>();
  final provider = NetworkImage(url);
  final stream = provider.resolve(const ImageConfiguration());
  late ImageStreamListener listener;
  listener = ImageStreamListener(
    (ImageInfo info, bool _) {
      if (!completer.isCompleted) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }
      stream.removeListener(listener);
    },
    onError: (_, __) {
      if (!completer.isCompleted) completer.complete(null);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);
  return completer.future.timeout(const Duration(seconds: 12), onTimeout: () => null);
}

Future<List<ScreenshotKind>> loadKindsForUrls(List<String> urls) async {
  final out = <ScreenshotKind>[];
  for (final u in urls) {
    final s = await decodeNetworkImageSize(u);
    if (s == null) {
      out.add(ScreenshotKind.tablet);
    } else {
      out.add(classifyScreenshotSize(s.width, s.height));
    }
  }
  return out;
}

/// One carousel page: either a row of up to 3 phone frames, or a single framed shot.
class ScreenshotSlideSpec {
  final List<String> urls;
  final List<ScreenshotKind> kinds;
  final bool isMobileRow;

  const ScreenshotSlideSpec({
    required this.urls,
    required this.kinds,
    required this.isMobileRow,
  });
}

List<ScreenshotSlideSpec> buildSlideSpecs(
  List<String> urls,
  List<ScreenshotKind> kinds,
  double viewportWidth,
) {
  assert(urls.length == kinds.length);
  final wide = viewportWidth >= 640;
  final slides = <ScreenshotSlideSpec>[];
  var i = 0;
  while (i < urls.length) {
    final k = kinds[i];
    if (k == ScreenshotKind.mobile && wide) {
      final batchUrls = <String>[urls[i]];
      final batchKinds = <ScreenshotKind>[kinds[i]];
      i++;
      while (batchUrls.length < 3 && i < urls.length && kinds[i] == ScreenshotKind.mobile) {
        batchUrls.add(urls[i]);
        batchKinds.add(kinds[i]);
        i++;
      }
      slides.add(ScreenshotSlideSpec(urls: batchUrls, kinds: batchKinds, isMobileRow: true));
    } else if (k == ScreenshotKind.mobile && !wide) {
      slides.add(ScreenshotSlideSpec(urls: [urls[i]], kinds: [kinds[i]], isMobileRow: true));
      i++;
    } else {
      slides.add(ScreenshotSlideSpec(urls: [urls[i]], kinds: [kinds[i]], isMobileRow: false));
      i++;
    }
  }
  return slides;
}

/// Full image visible + blurred backdrop filling the area (no awkward center crop).
class ProjectScreenshotPresenter extends StatelessWidget {
  final String imageUrl;
  final ScreenshotKind kind;
  final double? maxHeight;
  final double? maxWidth;

  const ProjectScreenshotPresenter({
    super.key,
    required this.imageUrl,
    required this.kind,
    this.maxHeight,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = maxHeight ?? constraints.maxHeight;
        final w = maxWidth ?? constraints.maxWidth;
        return SizedBox(
          width: w.isFinite ? w : null,
          height: h.isFinite ? h : null,
          child: _BackdropImage(
            imageUrl: imageUrl,
            child: Center(
              child: switch (kind) {
                ScreenshotKind.mobile => _PhoneFrame(
                    child: _NetworkImageContain(url: imageUrl),
                  ),
                ScreenshotKind.tablet => _TabletFrame(
                    child: _NetworkImageContain(url: imageUrl),
                  ),
                ScreenshotKind.desktop => _MonitorFrame(
                    child: _NetworkImageContain(url: imageUrl),
                  ),
              },
            ),
          ),
        );
      },
    );
  }
}

class _NetworkImageContain extends StatelessWidget {
  final String url;

  const _NetworkImageContain({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              color: Color(0xFF38BDF8),
            ),
          ),
        );
      },
      errorBuilder: (_, __, ___) => const Icon(
        Icons.broken_image_outlined,
        color: Colors.white38,
        size: 40,
      ),
    );
  }
}

class _BackdropImage extends StatelessWidget {
  final String imageUrl;
  final Widget child;

  const _BackdropImage({required this.imageUrl, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Transform.scale(
              scale: 1.15,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF0F172A)),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0F172A).withValues(alpha: 0.45),
                  const Color(0xFF0F172A).withValues(alpha: 0.82),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  final Widget child;

  const _PhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxH = c.maxHeight;
        final phoneH = maxH * 0.92;
        final phoneW = phoneH * 0.48;
        return Container(
          width: phoneW + 14,
          height: phoneH + 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: ColoredBox(
              color: const Color(0xFF020617),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 7, 5, 7),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColoredBox(
                    color: Colors.black,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TabletFrame extends StatelessWidget {
  final Widget child;

  const _TabletFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxH = c.maxHeight;
        final maxW = c.maxWidth;
        final h = maxH * 0.9;
        final w = (h * 0.72).clamp(120.0, maxW * 0.88);
        return Container(
          width: w + 12,
          height: h + 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: ColoredBox(
              color: const Color(0xFF0B1220),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: Colors.black,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MonitorFrame extends StatelessWidget {
  final Widget child;

  const _MonitorFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;
        final maxH = c.maxHeight;
        final w = maxW * 0.94;
        final screenH = (w * 0.56).clamp(100.0, maxH * 0.78);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: w,
              height: screenH + 14,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 22,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ColoredBox(
                  color: const Color(0xFF111827),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ColoredBox(
                        color: Colors.black,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: w * 0.22,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
              ),
            ),
            Container(
              width: w * 0.42,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Popup slide: one or more URLs framed appropriately.
class ProjectScreenshotSlide extends StatelessWidget {
  final ScreenshotSlideSpec spec;

  const ProjectScreenshotSlide({
    super.key,
    required this.spec,
  });

  @override
  Widget build(BuildContext context) {
    if (spec.isMobileRow && spec.urls.length > 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(spec.urls.length, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ProjectScreenshotPresenter(
                imageUrl: spec.urls[i],
                kind: spec.kinds[i],
              ),
            ),
          );
        }),
      );
    }

    return ProjectScreenshotPresenter(
      imageUrl: spec.urls.first,
      kind: spec.kinds.first,
    );
  }
}
