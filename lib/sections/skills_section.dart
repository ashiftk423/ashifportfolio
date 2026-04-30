import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_loader.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Skill>>(
      stream: FirebaseService().getSkills(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(height: 200, child: CustomLoader(text: 'Loading skills...'));
        }
        final skills = snap.data!;
        // Fallback to defaults if no data in Firebase yet
        if (skills.isEmpty) {
          return _buildContent(context, [
            Skill(id: '', name: 'Flutter', imageUrl: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png'),
            Skill(id: '', name: 'Firebase', imageUrl: 'https://firebase.google.com/static/downloads/brand-guidelines/PNG/logo-logomark.png'),
          ]);
        }
        return _buildContent(context, skills);
      },
    );
  }

  Widget _buildContent(BuildContext context, List<Skill> skills) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
          ).createShader(bounds),
          child: Text(
            "My Superpowers",
            style: GoogleFonts.poppins(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),

        const SizedBox(height: 16),
        Text(
          'Technologies I love working with',
          style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 50),

        Wrap(
          spacing: isMobile ? 30 : 60,
          runSpacing: isMobile ? 30 : 40,
          alignment: WrapAlignment.center,
          children: skills.asMap().entries.map((entry) {
            return _buildAnimated3DLogo(
              context,
              entry.value.name,
              entry.value.imageUrl,
              entry.key.isEven ? const Color(0xFF38BDF8) : const Color(0xFFA855F7),
              entry.key,
              isMobile,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAnimated3DLogo(BuildContext context, String title, String imageUrl, Color shadowColor, int index, bool isMobile) {
    final size = isMobile ? 80.0 : 120.0;
    return Column(
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 2 * math.pi),
          duration: Duration(seconds: 6 + index * 2),
          builder: (context, double value, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(math.sin(value) * 0.4)
                ..rotateX(math.cos(value) * 0.15),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: shadowColor.withValues(alpha: 0.08),
                  border: Border.all(color: shadowColor.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 14.0 : 22.0),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.contain)
                      : Icon(Icons.code, color: shadowColor, size: isMobile ? 30 : 40),
                ),
              ),
            );
          },
        )
            .animate(delay: Duration(milliseconds: index * 150))
            .fadeIn(duration: 600.ms)
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .slideY(begin: -0.08, end: 0.08, duration: Duration(seconds: 2 + index), curve: Curves.easeInOutSine),

        const SizedBox(height: 16),

        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            fontSize: isMobile ? 13 : 15,
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 400 + index * 100)),
      ],
    );
  }
}
