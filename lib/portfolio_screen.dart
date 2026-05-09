import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/portfolio_models.dart';
import 'screens/login_screen.dart';
import 'sections/hero_section.dart';
import 'sections/skills_section.dart';
import 'sections/works_section.dart';
import 'sections/contact_section.dart';
import 'sections/social_section.dart';
import 'sections/experience_section.dart';
import 'sections/certificates_section.dart';
import 'services/firebase_service.dart';
import 'widgets/maintenance_public_layer.dart';
import 'widgets/keyboard_scroll_shortcuts.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileInfo>(
      stream: FirebaseService().getProfileInfo(),
      builder: (context, snap) {
        final maintenance = snap.data?.maintenanceMode ?? false;
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

              // Main Content (scrollable — stays interactive)
              MaintenanceModeScope(
                maintenanceMode: maintenance,
                child: KeyboardScrollShortcuts(
                  controller: _scrollController,
                  child: CustomScrollView(
                    controller: _scrollController,
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

                  if (maintenance)
                    const SliverToBoxAdapter(child: MaintenanceIntroRibbon()),

                  const SliverToBoxAdapter(child: HeroSection()),
                  SliverToBoxAdapter(child: _SectionDivider(maintenance: maintenance)),
                  const SliverToBoxAdapter(child: SkillsSection()),
                  SliverToBoxAdapter(child: _SectionDivider(maintenance: maintenance)),
                  const SliverToBoxAdapter(child: ExperienceSection()),
                  SliverToBoxAdapter(child: _SectionDivider(maintenance: maintenance)),
                  const SliverToBoxAdapter(child: WorksSection()),
                  SliverToBoxAdapter(child: _SectionDivider(maintenance: maintenance)),
                  const SliverToBoxAdapter(child: CertificatesSection()),
                  SliverToBoxAdapter(child: _SectionDivider(maintenance: maintenance)),
                  const SliverToBoxAdapter(child: ContactSection()),
                  const SliverToBoxAdapter(child: SocialSection()),
                  const SliverToBoxAdapter(child: _Footer()),
                ],
                  ),
                ),
              ),

              // Decorative sprites on top — IgnorePointer so UX unchanged
              MaintenanceSpriteOverlay(enabled: maintenance),
            ],
          ),
        );
      },
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final bool maintenance;

  const _SectionDivider({this.maintenance = false});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 600;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: narrow ? 28 : 60, vertical: narrow ? 40 : 60),
      child: Column(
        children: [
          Row(
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
          if (maintenance) const MaintenanceSectionAccent(),
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
