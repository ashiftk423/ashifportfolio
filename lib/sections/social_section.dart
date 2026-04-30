import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';

class SocialSection extends StatelessWidget {
  const SocialSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SocialLink>>(
      stream: FirebaseService().getSocialLinks(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.isEmpty) return const SizedBox.shrink();
        final links = snap.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Text(
                'Find Me On',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13, letterSpacing: 2),
              ).animate().fadeIn(),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: links.asMap().entries.map((e) {
                  return _SocialChip(link: e.value, index: e.key);
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SocialChip extends StatefulWidget {
  final SocialLink link;
  final int index;
  const _SocialChip({required this.link, required this.index});

  @override
  State<_SocialChip> createState() => _SocialChipState();
}

class _SocialChipState extends State<_SocialChip> {
  bool _hovered = false;

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('github')) return Icons.code_rounded;
    if (n.contains('linkedin')) return Icons.work_rounded;
    if (n.contains('instagram')) return Icons.camera_alt_rounded;
    if (n.contains('twitter') || n.contains('x')) return Icons.alternate_email_rounded;
    if (n.contains('youtube')) return Icons.play_circle_rounded;
    return Icons.link_rounded;
  }

  Color _colorFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('github')) return const Color(0xFFE2E8F0);
    if (n.contains('linkedin')) return const Color(0xFF0A66C2);
    if (n.contains('instagram')) return const Color(0xFFE1306C);
    if (n.contains('twitter') || n.contains('x')) return const Color(0xFF1DA1F2);
    if (n.contains('youtube')) return const Color(0xFFFF0000);
    return const Color(0xFF38BDF8);
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(widget.link.username);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(widget.link.linkUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? color.withValues(alpha: 0.15) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: _hovered ? color : Colors.white12,
              width: 1.5,
            ),
            boxShadow: _hovered
                ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 2)]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.link.logoUrl.isNotEmpty)
                Image.network(
                  widget.link.logoUrl, 
                  width: 18, 
                  height: 18, 
                  fit: BoxFit.contain,
                  errorBuilder: (_,__,___) => Icon(_iconFor(widget.link.username), color: color, size: 18),
                )
              else
                Icon(_iconFor(widget.link.username), color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.link.username,
                style: GoogleFonts.poppins(
                  color: _hovered ? color : Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * widget.index))
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut);
  }
}
