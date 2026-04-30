import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_loader.dart';

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
                padding: const EdgeInsets.all(40),
                child: Text(
                  'No projects yet. Add some from the Admin Dashboard!',
                  style: GoogleFonts.poppins(color: Colors.white54, fontSize: 15),
                  textAlign: TextAlign.center,
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
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    if (widget.project.images.length > 1) _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && widget.project.images.isNotEmpty) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % widget.project.images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final hasLink = widget.project.link != null && widget.project.link!.isNotEmpty;

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
                SizedBox(
                  height: isMobile ? 180 : 220,
                  child: Stack(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        child: Image.network(
                          widget.project.images[_currentImageIndex],
                          key: ValueKey<int>(_currentImageIndex),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 220,
                        ),
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
                    ],
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
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.heading,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF38BDF8),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.project.description,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        height: 1.6,
                        fontSize: 13,
                      ),
                    ),

                    // Optional Project Link
                    if (hasLink) ...[
                      const SizedBox(height: 16),
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
