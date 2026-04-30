import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'sections/hero_section.dart';
import 'sections/skills_section.dart';
import 'sections/works_section.dart';
import 'sections/contact_section.dart';
import 'sections/social_section.dart';
import 'sections/experience_section.dart';
import 'sections/certificates_section.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Subtle background gradient blobs
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF38BDF8).withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFA855F7).withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top App Bar with Login Button
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.95),
                elevation: 0,
                title: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
                  ).createShader(bounds),
                  child: Text(
                    'Ashif.dev',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      icon: const Icon(Icons.lock_rounded, size: 16, color: Color(0xFF38BDF8)),
                      label: Text(
                        'Admin',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF38BDF8),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ),
                ],
              ),

              // Sections
              const SliverToBoxAdapter(child: HeroSection()),
              const SliverToBoxAdapter(child: _SectionDivider()),
              const SliverToBoxAdapter(child: SkillsSection()),
              const SliverToBoxAdapter(child: _SectionDivider()),
              const SliverToBoxAdapter(child: ExperienceSection()),
              const SliverToBoxAdapter(child: _SectionDivider()),
              const SliverToBoxAdapter(child: WorksSection()),
              const SliverToBoxAdapter(child: _SectionDivider()),
              const SliverToBoxAdapter(child: CertificatesSection()),
              const SliverToBoxAdapter(child: _SectionDivider()),
              const SliverToBoxAdapter(child: ContactSection()),
              const SliverToBoxAdapter(child: SocialSection()),
              const SliverToBoxAdapter(child: _Footer()),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xFF38BDF8), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 24),
          Text(
            '© 2026 Ashif Saheer — Built with Flutter & Firebase ♥',
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
