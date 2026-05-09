import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_loader.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileInfo>(
      stream: FirebaseService().getProfileInfo(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(height: 200, child: CustomLoader(text: 'Loading contact...'));
        }
        return _ContactContent(info: snap.data!);
      },
    );
  }
}

class _ContactContent extends StatelessWidget {
  final ProfileInfo info;
  const _ContactContent({required this.info});

  void _copy(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied!', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF38BDF8),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    final openInNewTab = kIsWeb && (uri.isScheme('http') || uri.isScheme('https'));
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: openInNewTab ? '_blank' : null,
    );
  }

  String _telUri(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s-]'), '');
    return 'tel:${Uri.encodeComponent(cleaned)}';
  }

  String _waUri(String wa) {
    final digits = wa.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return 'https://wa.me/';
    return 'https://wa.me/$digits';
  }

  /// Responsive width so 1 / 2 / 3 cards fit per row on phone / tablet / desktop.
  double _contactCardWidth(double screenWidth, bool isDesktop) {
    final horizontalPadding = isDesktop ? 200.0 : 48.0;
    final inner = screenWidth - horizontalPadding;
    final spacing = 20.0;
    if (screenWidth < 600) return inner.clamp(200.0, 520.0);
    if (screenWidth < 960) return ((inner - spacing) / 2).clamp(240.0, 400.0);
    return ((inner - spacing * 2) / 3).clamp(260.0, 360.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final isMobile = screenWidth < 600;
    final cardWidth = _contactCardWidth(screenWidth, isDesktop);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 100 : 24, vertical: 20),
      child: Column(
        children: [
          // Section heading
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
            ).createShader(bounds),
            child: Text(
              "Get In Touch",
              style: GoogleFonts.poppins(fontSize: isDesktop ? 36 : (isMobile ? 28 : 32), fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),
          const SizedBox(height: 10),
          Text(
            "Let's work together on something amazing!",
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 50),

          // Contact Cards (phones → email → WhatsApp; multiple numbers wrap cleanly)
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < info.phones.length; i++)
                _buildContactCard(
                  context,
                  icon: Icons.phone_rounded,
                  label: info.phones.length > 1 ? 'Phone ${i + 1}' : 'Phone',
                  value: info.phones[i],
                  color: const Color(0xFF22C55E),
                  onTap: () => _launch(_telUri(info.phones[i])),
                  onCopy: () => _copy(context, info.phones[i]),
                  width: cardWidth,
                ),

              if (info.email.isNotEmpty)
                _buildContactCard(
                  context,
                  icon: Icons.email_rounded,
                  label: 'Email',
                  value: info.email,
                  color: const Color(0xFF38BDF8),
                  onTap: () => _launch('mailto:${info.email}'),
                  onCopy: () => _copy(context, info.email),
                  width: cardWidth,
                ),

              for (var i = 0; i < info.whatsapps.length; i++)
                _buildContactCard(
                  context,
                  icon: Icons.chat_rounded,
                  label: info.whatsapps.length > 1 ? 'WhatsApp ${i + 1}' : 'WhatsApp',
                  value: info.whatsapps[i],
                  color: const Color(0xFF25D366),
                  onTap: () => _launch(_waUri(info.whatsapps[i])),
                  onCopy: () => _copy(context, info.whatsapps[i]),
                  width: cardWidth,
                ),
            ],
          ),

          const SizedBox(height: 36),

          // CV Download Button
          if (info.cvUrl.isNotEmpty)
            GestureDetector(
              onTap: () => _launch(info.cvUrl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFFA855F7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download_rounded, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'Download My CV',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 2.seconds, color: Colors.white24)
                .animate()
                .fadeIn(delay: 400.ms)
                .scale(begin: const Offset(0.9, 0.9), curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
    required VoidCallback onCopy,
    required double width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onCopy,
              icon: Icon(Icons.copy_rounded, color: color, size: 18),
              tooltip: 'Copy',
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms)
          .slideY(begin: 0.2, curve: Curves.easeOutQuad),
    );
  }
}
