import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_loader.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Experience>>(
      stream: FirebaseService().getExperiences(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(height: 200, child: CustomLoader(text: 'Loading experience...'));
        }
        final experiences = snap.data!;
        if (experiences.isEmpty) return const SizedBox.shrink();

        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth > 800;
        final isMobile = screenWidth < 600;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 100 : 24,
            vertical: 60,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Experience',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 40 : (isMobile ? 28 : 32),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 10),
              Container(width: 60, height: 4, color: const Color(0xFF38BDF8)).animate().scaleX(delay: 200.ms),
              const SizedBox(height: 50),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: experiences.length,
                itemBuilder: (context, i) {
                  final exp = experiences[i];
                  return _buildExperienceCard(exp, isDesktop, i)
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 200 * i))
                      .slideX(begin: isDesktop ? (i % 2 == 0 ? -0.1 : 0.1) : 0.1);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExperienceCard(Experience exp, bool isDesktop, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 24, left: isDesktop ? 40 : 0, right: isDesktop ? 40 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot and line
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
              ),
              if (index >= 0) // Just to draw line down
                 Container(width: 2, height: 100, color: const Color(0xFF38BDF8).withValues(alpha: 0.2)),
            ],
          ),
          const SizedBox(width: 20),
          // Content card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exp.role,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.business, size: 14, color: Color(0xFF38BDF8)),
                          const SizedBox(width: 6),
                          Text(
                            exp.company,
                            style: GoogleFonts.poppins(color: const Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.white54),
                          const SizedBox(width: 6),
                          Text(
                            exp.duration,
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (exp.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      exp.description,
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, height: 1.6),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
