import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_loader.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileInfo>(
      stream: FirebaseService().getProfileInfo(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(height: 300, child: CustomLoader(text: 'Loading profile...'));
        }
        final info = snap.data!;
        return _HeroContent(info: info);
      },
    );
  }
}

class _HeroContent extends StatefulWidget {
  final ProfileInfo info;
  const _HeroContent({required this.info});

  @override
  State<_HeroContent> createState() => _HeroContentState();
}

class _HeroContentState extends State<_HeroContent> {
  bool _isHovered = false;

  Future<void> _openCv(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CV link is invalid. Update it in Admin.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }
    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: kIsWeb ? '_blank' : null,
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open CV.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 100 : 24,
        vertical: isDesktop ? 80 : 50,
      ),
      child: isDesktop
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildInfo(context)),
                const SizedBox(width: 60),
                _buildPhotoCard(context),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildPhotoCard(context),
                const SizedBox(height: 40),
                _buildInfo(context),
              ],
            ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final align = isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center;
    final textAlign = isDesktop ? TextAlign.left : TextAlign.center;

    return Column(
      crossAxisAlignment: align,
      children: [
        // Greeting badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
          ),
          child: Text(
            '👋 Hi there!',
            style: GoogleFonts.poppins(color: const Color(0xFF38BDF8), fontSize: 13),
          ),
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: 20),

        Text(
          widget.info.name.isNotEmpty ? "I'm ${widget.info.name}" : "I'm Ashif Saheer",
          style: GoogleFonts.poppins(
            fontSize: isDesktop ? 52 : (isMobile ? 32 : 40),
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.1,
          ),
          textAlign: textAlign,
        )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, curve: Curves.bounceOut),

        const SizedBox(height: 12),

        // Gradient title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
          ).createShader(bounds),
          child: Text(
            widget.info.title.isNotEmpty ? widget.info.title : 'Software Developer',
            style: GoogleFonts.poppins(
              fontSize: isDesktop ? 28 : (isMobile ? 18 : 24),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: textAlign,
          ),
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms)
            .slideX(begin: -0.2, curve: Curves.easeOutQuad),

        const SizedBox(height: 24),

        Text(
          widget.info.description.isNotEmpty
              ? widget.info.description
              : 'I craft incredible digital experiences, transforming innovative ideas into cutting-edge, scalable software solutions.',
          style: GoogleFonts.poppins(
            color: Colors.white70,
            height: 1.7,
            fontSize: 15,
          ),
          textAlign: textAlign,
        )
            .animate(delay: 400.ms)
            .fadeIn(duration: 700.ms),

        const SizedBox(height: 36),

        // CTA Buttons
        Wrap(
          alignment: isDesktop ? WrapAlignment.start : WrapAlignment.center,
          spacing: 16,
          runSpacing: 12,
          children: [
            if (widget.info.cvUrl.isNotEmpty)
              _glowButton(context, 'Download CV', Icons.download_rounded, onTap: () {
                _openCv(widget.info.cvUrl);
              })
                  .animate(delay: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
          ],
        ),
      ],
    );
  }

  Widget _glowButton(BuildContext context, String label, IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final size = isMobile ? 200.0 : 280.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_isHovered ? 0.05 : 0)
          ..rotateY(_isHovered ? -0.05 : 0),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF38BDF8).withValues(alpha: _isHovered ? 0.7 : 0.4),
                blurRadius: _isHovered ? 60 : 30,
                spreadRadius: _isHovered ? 10 : 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipOval(
            child: widget.info.photoUrl.isNotEmpty
                ? Image.network(
                    widget.info.photoUrl,
                    key: ValueKey<String>(widget.info.photoUrl),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading hero image: $error');
                      return Container(
                        color: const Color(0xFF1E293B),
                        child: Icon(Icons.broken_image, size: size * 0.3, color: Colors.white54),
                      );
                    },
                  )
                : Container(
                    color: const Color(0xFF1E293B),
                    child: Icon(Icons.person, size: size * 0.3, color: Colors.white54),
                  ),
          ),
        ),
      ).animate().scale(delay: 300.ms, duration: 800.ms, curve: Curves.elasticOut),
    );
  }
}
