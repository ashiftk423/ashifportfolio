import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_loader.dart';
import '../widgets/project_screenshot_presenter.dart';
import '../widgets/maintenance_public_layer.dart';
import '../widgets/keyboard_scroll_shortcuts.dart';

class WorksSection extends StatelessWidget {
  const WorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Project>>(
      stream: FirebaseService().getProjects(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(height: 300, child: CustomLoader(text: 'Loading projects...'));
        }
        final projects = snap.data!;

        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;

        return Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
              ).createShader(bounds),
              child: Text(
                "My Masterpieces",
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.3),

            const SizedBox(height: 12),
            Text(
              'A showcase of my best work',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 50),

            if (projects.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Text(
                      'No projects yet. Add some from the Admin Dashboard!',
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const MaintenanceEmptySectionFiller(
                      caption: 'Site polish in progress — projects will shine here soon.',
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Wrap(
                  spacing: isMobile ? 20 : 40,
                  runSpacing: isMobile ? 20 : 40,
                  alignment: WrapAlignment.center,
                  children: projects.asMap().entries.map((entry) {
                    return WorkCard(
                      project: entry.value,
                      index: entry.key,
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class WorkCard extends StatefulWidget {
  final Project project;
  final int index;

  const WorkCard({super.key, required this.project, required this.index});

  @override
  State<WorkCard> createState() => _WorkCardState();
}

class _WorkCardState extends State<WorkCard> {
  int _currentImageIndex = 0;
  Timer? _timer;
  late final PageController _pageController;
  bool _isHovered = false;
  bool _isExpanded = false;
  List<ScreenshotKind>? _imageKinds;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.project.images.length > 1) _startTimer();
    _loadImageKinds();
  }

  Future<void> _loadImageKinds() async {
    if (widget.project.images.isEmpty) return;
    final kinds = await loadKindsForUrls(widget.project.images);
    if (mounted) setState(() => _imageKinds = kinds);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && widget.project.images.isNotEmpty) {
        _goToImage((_currentImageIndex + 1) % widget.project.images.length);
      }
    });
  }

  void _goToImage(int index) {
    if (widget.project.images.isEmpty) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goNext() {
    if (widget.project.images.length <= 1) return;
    final nextIndex = (_currentImageIndex + 1) % widget.project.images.length;
    _goToImage(nextIndex);
  }

  void _goPrevious() {
    if (widget.project.images.length <= 1) return;
    final previousIndex = (_currentImageIndex - 1 + widget.project.images.length) % widget.project.images.length;
    _goToImage(previousIndex);
  }

  Future<void> _openDetailsPopup() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => _ProjectDetailsDialog(project: widget.project),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final hasLink = widget.project.link != null && widget.project.link!.isNotEmpty;
    final hasLongText = widget.project.description.trim().length > 180;
    final collapsedHeight = isMobile ? 470.0 : 540.0;
    final expandedHeight = isMobile ? 620.0 : 700.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -10.0 : 0.0, 0.0)
            ..scale(_isHovered ? 1.04 : 1.0),
          width: isMobile ? screenWidth - 48 : 350,
          height: _isExpanded ? expandedHeight : collapsedHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? const Color(0xFF38BDF8).withValues(alpha: 0.35)
                    : Colors.black26,
                blurRadius: _isHovered ? 40 : 15,
                spreadRadius: _isHovered ? 5 : 0,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: _isHovered
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.5)
                  : Colors.white10,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Image Carousel
              if (widget.project.images.isNotEmpty)
                GestureDetector(
                  onTap: _openDetailsPopup,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                  height: isMobile ? 180 : 220,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        itemCount: widget.project.images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          if (_imageKinds == null || index >= _imageKinds!.length) {
                            return Container(
                              color: const Color(0xFF0F172A),
                              child: const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.8,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ),
                            );
                          }
                          return ProjectScreenshotPresenter(
                            imageUrl: widget.project.images[index],
                            kind: _imageKinds![index],
                          );
                        },
                      ),
                      // Image indicators
                      if (widget.project.images.length > 1)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(widget.project.images.length, (i) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _currentImageIndex ? 18 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: i == _currentImageIndex
                                      ? const Color(0xFF38BDF8)
                                      : Colors.white38,
                                ),
                              );
                            }),
                          ),
                        ),
                      if (widget.project.images.length > 1)
                        Positioned(
                          left: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _NavButton(
                              icon: Icons.chevron_left_rounded,
                              onTap: () {
                                _goPrevious();
                              },
                            ),
                          ),
                        ),
                      if (widget.project.images.length > 1)
                        Positioned(
                          right: 10,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _NavButton(
                              icon: Icons.chevron_right_rounded,
                              onTap: () {
                                _goNext();
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                )
              else
                Container(
                  height: 220,
                  color: const Color(0xFF0F172A),
                  child: const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white24, size: 60),
                  ),
                ),

              // Description
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    GestureDetector(
                      onTap: _openDetailsPopup,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        widget.project.heading,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF38BDF8),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: _openDetailsPopup,
                        behavior: HitTestBehavior.opaque,
                        child: _isExpanded
                            ? SingleChildScrollView(
                                child: Text(
                                  widget.project.description,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    height: 1.6,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  widget.project.description,
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    height: 1.6,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    if (hasLongText) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF38BDF8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => setState(() => _isExpanded = !_isExpanded),
                          child: Text(
                            _isExpanded ? 'Show less (compact card)' : 'Read more',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Optional Project Link
                    if (hasLink) ...[
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(widget.project.link!);
                          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'View Project',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      )
          .animate(delay: Duration(milliseconds: 100 * widget.index))
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.2, curve: Curves.easeOutQuad),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ProjectDetailsDialog extends StatefulWidget {
  final Project project;

  const _ProjectDetailsDialog({required this.project});

  @override
  State<_ProjectDetailsDialog> createState() => _ProjectDetailsDialogState();
}

class _ProjectDetailsDialogState extends State<_ProjectDetailsDialog> {
  late final Future<List<ScreenshotKind>> _kindsFuture;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _kindsFuture = loadKindsForUrls(widget.project.images);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final hasLink = project.link != null && project.link!.isNotEmpty;
    final width = MediaQuery.of(context).size.width;
    final dialogWidth = width < 900 ? width * 0.92 : 860.0;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 780),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            if (project.images.isNotEmpty)
              SizedBox(
                height: 320,
                child: FutureBuilder<List<ScreenshotKind>>(
                  future: _kindsFuture,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done || !snap.hasData) {
                      return const Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.8,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      );
                    }
                    final viewport = MediaQuery.sizeOf(context).width;
                    final slides = buildSlideSpecs(project.images, snap.data!, viewport);
                    return _ProjectSlideCarousel(slides: slides);
                  },
                ),
              ),
            Expanded(
              child: KeyboardScrollShortcuts(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.heading,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF38BDF8),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white70),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.75,
                      ),
                    ),
                    if (hasLink) ...[
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () async {
                          final uri = Uri.parse(project.link!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Open Project',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectSlideCarousel extends StatefulWidget {
  final List<ScreenshotSlideSpec> slides;

  const _ProjectSlideCarousel({required this.slides});

  @override
  State<_ProjectSlideCarousel> createState() => _ProjectSlideCarouselState();
}

class _ProjectSlideCarouselState extends State<_ProjectSlideCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    if (widget.slides.length <= 1) return;
    final next = (_index + delta + widget.slides.length) % widget.slides.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.slides.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) {
            return ProjectScreenshotSlide(spec: widget.slides[i]);
          },
        ),
        if (widget.slides.length > 1) ...[
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _go(-1),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _NavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _go(1),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.slides.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: i == _index ? const Color(0xFF38BDF8) : Colors.white38,
                  ),
                );
              }),
            ),
          ),
        ],
      ],
    );
  }
}
