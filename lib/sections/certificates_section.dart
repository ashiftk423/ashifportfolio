import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_loader.dart';

class CertificatesSection extends StatelessWidget {
  const CertificatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Certificate>>(
      stream: FirebaseService().getCertificates(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(height: 200, child: CustomLoader(text: 'Loading certificates...'));
        }
        final certs = snap.data!;
        if (certs.isEmpty) return const SizedBox.shrink();

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
                'Certificates',
                style: GoogleFonts.poppins(
                  fontSize: isDesktop ? 40 : (isMobile ? 28 : 32),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
              
              const SizedBox(height: 10),
              Container(width: 60, height: 4, color: const Color(0xFF38BDF8)).animate().scaleX(delay: 200.ms),
              const SizedBox(height: 50),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : (screenWidth > 600 ? 2 : 1),
                  childAspectRatio: isDesktop ? 1.4 : 1.3,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: certs.length,
                itemBuilder: (context, i) {
                  return _CertificateCard(cert: certs[i], index: i);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CertificateCard extends StatefulWidget {
  final Certificate cert;
  final int index;
  const _CertificateCard({required this.cert, required this.index});

  @override
  State<_CertificateCard> createState() => _CertificateCardState();
}

class _CertificateCardState extends State<_CertificateCard> {
  bool _isHovered = false;

  Future<void> _launchUrl() async {
    if (widget.cert.link.isEmpty) return;
    final uri = Uri.parse(widget.cert.link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.cert.link.isNotEmpty ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _launchUrl,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _isHovered ? const Color(0xFF38BDF8) : Colors.white10),
            boxShadow: _isHovered
                ? [BoxShadow(color: const Color(0xFF38BDF8).withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 2)]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: widget.cert.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.cert.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.card_membership, size: 60, color: Colors.white12),
                        )
                      : const Icon(Icons.card_membership, size: 60, color: Colors.white12),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.cert.title,
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.cert.issuer} • ${widget.cert.date}',
                      style: GoogleFonts.poppins(color: const Color(0xFF38BDF8), fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 100 * widget.index)).slideY(begin: 0.1),
    );
  }
}
