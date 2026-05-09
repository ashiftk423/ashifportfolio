import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/portfolio_models.dart';
import '../services/firebase_service.dart';
import '../widgets/keyboard_scroll_shortcuts.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedTab = 0;
  final _service = FirebaseService();
  final List<String> _tabs = ['Info', 'Projects', 'Skills', 'Socials', 'Certificates', 'Experience'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Admin Dashboard', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = _selectedTab == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: AnimatedContainer(
                    duration: 300.ms,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected ? const Color(0xFF38BDF8) : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[i],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: selected ? const Color(0xFF38BDF8) : Colors.white54,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        sizing: StackFit.expand,
        children: [
          _InfoEditor(service: _service),
          _ProjectsEditor(service: _service),
          _SkillsEditor(service: _service),
          _SocialsEditor(service: _service),
          _CertificatesEditor(service: _service),
          _ExperienceEditor(service: _service),
        ],
      ),
    );
  }
}

// ─────────────────────────── INFO EDITOR ─────────────────────────────────────
class _InfoEditor extends StatefulWidget {
  final FirebaseService service;
  const _InfoEditor({required this.service});

  @override
  State<_InfoEditor> createState() => _InfoEditorState();
}

class _InfoEditorState extends State<_InfoEditor> {
  final _name = TextEditingController();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _email = TextEditingController();
  final List<TextEditingController> _phoneCtrls = [TextEditingController()];
  final List<TextEditingController> _whatsappCtrls = [TextEditingController()];
  String _photoUrl = '';
  String _cvUrl = '';
  bool _saving = false;
  bool _loaded = false;
  final _scrollController = ScrollController();

  void _disposeCtrlList(List<TextEditingController> list) {
    for (final c in list) {
      c.dispose();
    }
    list.clear();
  }

  @override
  void dispose() {
    _name.dispose();
    _title.dispose();
    _desc.dispose();
    _email.dispose();
    _disposeCtrlList(_phoneCtrls);
    _disposeCtrlList(_whatsappCtrls);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData(ProfileInfo info) {
    if (_loaded) return;
    _loaded = true;
    _name.text = info.name;
    _title.text = info.title;
    _desc.text = info.description;
    _email.text = info.email;
    _disposeCtrlList(_phoneCtrls);
    _phoneCtrls.addAll(
      info.phones.isEmpty
          ? [TextEditingController()]
          : info.phones.map((e) => TextEditingController(text: e)),
    );
    _disposeCtrlList(_whatsappCtrls);
    _whatsappCtrls.addAll(
      info.whatsapps.isEmpty
          ? [TextEditingController()]
          : info.whatsapps.map((e) => TextEditingController(text: e)),
    );
    _photoUrl = info.photoUrl;
    _cvUrl = info.cvUrl;
  }

  void _showSnack(String msg) {
    final isError = msg.toLowerCase().contains('error') || msg.toLowerCase().contains('failed');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(color: isError ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF38BDF8),
    ));
  }

  Future<void> _uploadPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;
      final previousUrl = _photoUrl;
      setState(() => _saving = true);
      final url = await widget.service.uploadFile('info/photos/', file.bytes!, '${DateTime.now().millisecondsSinceEpoch}_${file.name}');
      await widget.service.mergeProfileFields({'photoUrl': url});
      if (previousUrl.isNotEmpty && previousUrl != url) {
        await widget.service.deleteStorageFileByUrl(previousUrl);
      }
      if (mounted) {
        setState(() {
          _photoUrl = url;
          _saving = false;
        });
        _showSnack('Photo updated and saved!');
      }
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      if (mounted) _showSnack('Error uploading photo: $e');
    }
  }

  Future<void> _uploadCv() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      if (file.bytes == null) return;
      final previousUrl = _cvUrl;
      setState(() => _saving = true);
      final url = await widget.service.uploadFile('info/cv/', file.bytes!, '${DateTime.now().millisecondsSinceEpoch}_${file.name}');
      await widget.service.mergeProfileFields({'cvUrl': url});
      if (previousUrl.isNotEmpty && previousUrl != url) {
        await widget.service.deleteStorageFileByUrl(previousUrl);
      }
      if (mounted) {
        setState(() {
          _cvUrl = url;
          _saving = false;
        });
        _showSnack('CV updated and saved!');
      }
    } catch (e) {
      if (mounted) setState(() => _saving = false);
      if (mounted) _showSnack('Error uploading CV: $e');
    }
  }

  List<String> _trimmedNonEmpty(List<TextEditingController> ctrls) {
    return ctrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
  }

  Future<void> _save({required bool maintenanceMode}) async {
    try {
      setState(() => _saving = true);
      await widget.service.updateProfileInfo(ProfileInfo(
        name: _name.text,
        title: _title.text,
        description: _desc.text,
        email: _email.text,
        phones: _trimmedNonEmpty(_phoneCtrls),
        whatsapps: _trimmedNonEmpty(_whatsappCtrls),
        photoUrl: _photoUrl,
        cvUrl: _cvUrl,
        maintenanceMode: maintenanceMode,
      ));
      setState(() => _saving = false);
      _showSnack('Info saved!');
    } catch (e) {
      setState(() => _saving = false);
      _showSnack('Error saving info: $e');
    }
  }

  Widget _repeatableContactFields({
    required String heading,
    required String subtitle,
    required String fieldBaseLabel,
    required IconData icon,
    required List<TextEditingController> ctrls,
    required VoidCallback onAdd,
    required void Function(int index) onRemove,
  }) {
    final narrow = MediaQuery.of(context).size.width < 520;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(subtitle, style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 10),
        ...List.generate(ctrls.length, (i) {
          final label = ctrls.length > 1 ? '$fieldBaseLabel ${i + 1}' : fieldBaseLabel;
          if (narrow) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _field(ctrls[i], label, icon),
                  if (ctrls.length > 1)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => onRemove(i),
                        icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.redAccent),
                        label: Text('Remove', style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _field(ctrls[i], label, icon)),
                if (ctrls.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 8),
                    child: IconButton(
                      tooltip: 'Remove',
                      onPressed: () => onRemove(i),
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF38BDF8), size: 22),
          label: Text('Add number', style: GoogleFonts.poppins(color: const Color(0xFF38BDF8), fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _multiPhoneFields() {
    return _repeatableContactFields(
      heading: 'Phone numbers',
      subtitle: 'Add all numbers you want visitors to see (include country code, e.g. +91, +966).',
      fieldBaseLabel: 'Phone',
      icon: Icons.phone,
      ctrls: _phoneCtrls,
      onAdd: () => setState(() => _phoneCtrls.add(TextEditingController())),
      onRemove: (i) {
        if (_phoneCtrls.length <= 1) return;
        setState(() {
          _phoneCtrls[i].dispose();
          _phoneCtrls.removeAt(i);
        });
      },
    );
  }

  Widget _multiWhatsappFields() {
    return _repeatableContactFields(
      heading: 'WhatsApp numbers',
      subtitle: 'Each line is a full WhatsApp number with country code.',
      fieldBaseLabel: 'WhatsApp',
      icon: Icons.chat,
      ctrls: _whatsappCtrls,
      onAdd: () => setState(() => _whatsappCtrls.add(TextEditingController())),
      onRemove: (i) {
        if (_whatsappCtrls.length <= 1) return;
        setState(() {
          _whatsappCtrls[i].dispose();
          _whatsappCtrls.removeAt(i);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProfileInfo>(
      stream: widget.service.getProfileInfo(),
      builder: (context, snap) {
        if (snap.hasData) _loadData(snap.data!);
        return KeyboardScrollShortcuts(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Profile Information'),
              const SizedBox(height: 20),
              Row(
                children: [
                  ClipOval(
                    child: Container(
                      width: 100, height: 100,
                      color: Colors.white12,
                      child: _photoUrl.isNotEmpty
                          ? Image.network(
                              _photoUrl,
                              key: ValueKey<String>(_photoUrl),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => const Icon(Icons.broken_image, size: 40, color: Colors.white54),
                            )
                          : const Icon(Icons.person, size: 40, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _actionButton('Upload Photo', Icons.photo_camera, _uploadPhoto),
                        const SizedBox(height: 8),
                        _actionButton('Upload CV (PDF)', Icons.upload_file, _uploadCv),
                        if (_cvUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text('CV uploaded ✓', style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _field(_name, 'Full Name', Icons.person),
              _field(_title, 'Title / Role', Icons.work),
              _field(_desc, 'Description', Icons.description, maxLines: 4),
              _field(_email, 'Email', Icons.email),
              _multiPhoneFields(),
              _multiWhatsappFields(),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: SwitchListTile.adaptive(
                  value: snap.data?.maintenanceMode ?? false,
                  onChanged: _saving
                      ? null
                      : (v) async {
                          try {
                            await widget.service.mergeProfileFields({'maintenanceMode': v});
                            if (mounted) {
                              _showSnack(
                                v ? 'Maintenance banner ON for visitors' : 'Maintenance banner OFF',
                              );
                            }
                          } catch (e) {
                            if (mounted) _showSnack('Error: $e');
                          }
                        },
                  title: Text(
                    'Public maintenance banner',
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  subtitle: Text(
                    'Playful “under construction” layer on the live site. Portfolio stays fully usable.',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                  ),
                  activeThumbColor: const Color(0xFF38BDF8),
                  activeTrackColor: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () => _save(maintenanceMode: snap.data?.maintenanceMode ?? false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.black87, strokeWidth: 2)
                      : Text('Save Info', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}

// ────────────────────────── PROJECTS EDITOR ──────────────────────────────────
class _ProjectsEditor extends StatefulWidget {
  final FirebaseService service;
  const _ProjectsEditor({required this.service});
  @override
  State<_ProjectsEditor> createState() => _ProjectsEditorState();
}

class _ProjectsEditorState extends State<_ProjectsEditor> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showProjectForm({Project? project}) {
    showDialog(
      context: context,
      builder: (_) => _ProjectFormDialog(service: widget.service, project: project),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Project>>(
      stream: widget.service.getProjects(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
        }
        final projects = snap.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Projects'),
                  ElevatedButton.icon(
                    onPressed: () => _showProjectForm(),
                    icon: const Icon(Icons.add),
                    label: Text('Add Project', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              child: KeyboardScrollShortcuts(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: projects.length,
                itemBuilder: (context, i) {
                  final p = projects[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        if (p.images.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(p.images.first, width: 70, height: 70, fit: BoxFit.cover),
                          ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.heading, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(p.description, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (p.link != null && p.link!.isNotEmpty)
                                Text(p.link!, style: GoogleFonts.poppins(color: const Color(0xFF38BDF8), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.edit, color: Color(0xFF38BDF8)), onPressed: () => _showProjectForm(project: p)),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                          onPressed: () async {
                            try {
                              await widget.service.deleteProject(p.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project deleted'), backgroundColor: Colors.redAccent));
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.redAccent));
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: 0.1);
                },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProjectFormDialog extends StatefulWidget {
  final FirebaseService service;
  final Project? project;
  const _ProjectFormDialog({required this.service, this.project});
  @override
  State<_ProjectFormDialog> createState() => _ProjectFormDialogState();
}

class _ProjectFormDialogState extends State<_ProjectFormDialog> {
  late final TextEditingController _heading;
  late final TextEditingController _desc;
  late final TextEditingController _link;
  final _scrollController = ScrollController();
  List<String> _images = [];
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _heading = TextEditingController(text: widget.project?.heading ?? '');
    _desc = TextEditingController(text: widget.project?.description ?? '');
    _link = TextEditingController(text: widget.project?.link ?? '');
    _images = List.from(widget.project?.images ?? []);
  }

  @override
  void dispose() {
    _heading.dispose(); _desc.dispose(); _link.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    final isError = msg.toLowerCase().contains('error') || msg.toLowerCase().contains('failed');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.poppins(color: isError ? Colors.white : Colors.black87, fontWeight: FontWeight.w500)),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF38BDF8),
    ));
  }

  Future<void> _uploadImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image, allowMultiple: true, withData: true,
      );
      if (result == null) return;
      setState(() => _uploading = true);
      for (final file in result.files) {
        if (file.bytes == null) continue;
        final url = await widget.service.uploadFile('projects/', file.bytes!, '${DateTime.now().millisecondsSinceEpoch}_${file.name}');
        _images.add(url);
      }
      setState(() => _uploading = false);
      _showSnack('Images uploaded!');
    } catch (e) {
      setState(() => _uploading = false);
      _showSnack('Error uploading images: $e');
    }
  }

  Future<void> _save() async {
    try {
      setState(() => _saving = true);
      final project = Project(
        id: widget.project?.id ?? '',
        heading: _heading.text,
        description: _desc.text,
        images: _images,
        link: _link.text.isNotEmpty ? _link.text : null,
      );
      await widget.service.saveProject(project);
      setState(() => _saving = false);
      _showSnack('Project saved!');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      _showSnack('Error saving project: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: KeyboardScrollShortcuts(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.project == null ? 'Add Project' : 'Edit Project',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _field(_heading, 'Project Title', Icons.title),
            _field(_desc, 'Description', Icons.description, maxLines: 4),
            _field(_link, 'Project Link (optional)', Icons.link),
            const SizedBox(height: 12),
            Text('Images (${_images.length})', style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 8),
            if (_images.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (c, i) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(_images[i], width: 80, height: 80, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 0, right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(i)),
                          child: Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                            child: const Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _uploading ? null : _uploadImages,
              icon: _uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.photo_library),
              label: Text(_uploading ? 'Uploading...' : 'Upload Images', style: GoogleFonts.poppins()),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E40AF), foregroundColor: Colors.white),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54))),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87)) : Text('Save', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

// ─────────────────────────── SKILLS EDITOR ───────────────────────────────────
class _SkillsEditor extends StatefulWidget {
  final FirebaseService service;
  const _SkillsEditor({required this.service});
  @override
  State<_SkillsEditor> createState() => _SkillsEditorState();
}

class _SkillsEditorState extends State<_SkillsEditor> {
  final _skillsScrollController = ScrollController();

  @override
  void dispose() {
    _skillsScrollController.dispose();
    super.dispose();
  }

  void _showForm({Skill? skill}) {
    final nameCtrl = TextEditingController(text: skill?.name ?? '');
    final urlCtrl = TextEditingController(text: skill?.imageUrl ?? '');
    bool uploading = false;
    bool saving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(skill == null ? 'Add Skill' : 'Edit Skill', style: GoogleFonts.poppins(color: Colors.white)),
            content: KeyboardSingleChildScrollView(
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameCtrl, 'Skill Name', Icons.code),
                _field(urlCtrl, 'Logo Image URL', Icons.image),
                const SizedBox(height: 12),
                Text('OR', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: uploading ? null : () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                      if (result == null || result.files.isEmpty) return;
                      setDialogState(() => uploading = true);
                      final file = result.files.first;
                      final url = await widget.service.uploadFile('skills/', file.bytes!, '${DateTime.now().millisecondsSinceEpoch}_${file.name}');
                      setDialogState(() {
                        urlCtrl.text = url;
                        uploading = false;
                      });
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded!'), backgroundColor: Color(0xFF38BDF8)));
                    } catch (e) {
                      setDialogState(() => uploading = false);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent));
                    }
                  },
                  icon: uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.upload_file),
                  label: Text(uploading ? 'Uploading...' : 'Upload Image', style: GoogleFonts.poppins()),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E40AF), foregroundColor: Colors.white),
                )
              ],
            ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87),
                onPressed: saving ? null : () async {
                  try {
                    setDialogState(() => saving = true);
                    await widget.service.saveSkill(Skill(id: skill?.id ?? '', name: nameCtrl.text, imageUrl: urlCtrl.text));
                    setDialogState(() => saving = false);
                    if (mounted) Navigator.pop(context);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Skill saved!'), backgroundColor: Color(0xFF38BDF8)));
                  } catch(e) {
                    setDialogState(() => saving = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent));
                  }
                },
                child: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87)) : Text('Save', style: GoogleFonts.poppins()),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Skill>>(
      stream: widget.service.getSkills(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
        final skills = snap.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Super Powers'),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(),
                    icon: const Icon(Icons.add),
                    label: Text('Add Skill', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              child: KeyboardScrollShortcuts(
                controller: _skillsScrollController,
                child: SingleChildScrollView(
                  controller: _skillsScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Wrap(
                    children: skills.map((s) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Chip(
                        backgroundColor: const Color(0xFF1E293B),
                        avatar: s.imageUrl.isNotEmpty 
                            ? ClipOval(
                                child: Image.network(
                                    s.imageUrl, 
                                    width: 24, height: 24, fit: BoxFit.cover,
                                    errorBuilder: (_,__,___) => const Icon(Icons.broken_image, size: 16)
                                )
                              ) 
                            : null,
                        label: Text(s.name, style: GoogleFonts.poppins(color: Colors.white)),
                        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                        onDeleted: () async {
                          try {
                            await widget.service.deleteSkill(s.id);
                          } catch (e) {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.redAccent));
                          }
                        },
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────── SOCIALS EDITOR ──────────────────────────────────
class _SocialsEditor extends StatefulWidget {
  final FirebaseService service;
  const _SocialsEditor({required this.service});
  @override
  State<_SocialsEditor> createState() => _SocialsEditorState();
}

class _SocialsEditorState extends State<_SocialsEditor> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showForm({SocialLink? link}) {
    final usernameCtrl = TextEditingController(text: link?.username ?? '');
    final urlCtrl = TextEditingController(text: link?.linkUrl ?? '');
    final logoUrlCtrl = TextEditingController(text: link?.logoUrl ?? '');
    bool uploading = false;
    bool saving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(link == null ? 'Add Social Link' : 'Edit Social Link', style: GoogleFonts.poppins(color: Colors.white)),
            content: KeyboardSingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(usernameCtrl, 'Username / Platform Name', Icons.person),
                  _field(urlCtrl, 'Profile URL', Icons.link),
                  _field(logoUrlCtrl, 'Logo Image URL (optional)', Icons.image),
                  const SizedBox(height: 12),
                  Text('OR', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: uploading ? null : () async {
                      try {
                        final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                        if (result == null || result.files.isEmpty) return;
                        setDialogState(() => uploading = true);
                        final file = result.files.first;
                        final url = await widget.service.uploadFile('socials/', file.bytes!, '${DateTime.now().millisecondsSinceEpoch}_${file.name}');
                        setDialogState(() {
                          logoUrlCtrl.text = url;
                          uploading = false;
                        });
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logo uploaded!'), backgroundColor: Color(0xFF38BDF8)));
                      } catch (e) {
                        setDialogState(() => uploading = false);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent));
                      }
                    },
                    icon: uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.upload_file),
                    label: Text(uploading ? 'Uploading...' : 'Upload Logo', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E40AF), foregroundColor: Colors.white),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87),
                onPressed: saving ? null : () async {
                  try {
                    setDialogState(() => saving = true);
                    await widget.service.saveSocialLink(SocialLink(id: link?.id ?? '', username: usernameCtrl.text, linkUrl: urlCtrl.text, logoUrl: logoUrlCtrl.text));
                    setDialogState(() => saving = false);
                    if (mounted) Navigator.pop(context);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Social Link saved!'), backgroundColor: Color(0xFF38BDF8)));
                  } catch(e) {
                    setDialogState(() => saving = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent));
                  }
                },
                child: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87)) : Text('Save', style: GoogleFonts.poppins()),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SocialLink>>(
      stream: widget.service.getSocialLinks(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
        final links = snap.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Social Links'),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(),
                    icon: const Icon(Icons.add),
                    label: Text('Add Social', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              child: KeyboardScrollShortcuts(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: links.length,
                itemBuilder: (context, i) {
                  final l = links[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        if (l.logoUrl.isNotEmpty)
                           Image.network(l.logoUrl, width: 24, height: 24, fit: BoxFit.contain)
                        else
                           const Icon(Icons.link, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.username, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(l.linkUrl, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.edit, color: Color(0xFF38BDF8)), onPressed: () => _showForm(link: l)),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                          onPressed: () async {
                            try {
                              await widget.service.deleteSocialLink(l.id);
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.redAccent));
                            }
                          }
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: 0.1);
                },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────── SHARED HELPERS ──────────────────────────────────
Widget _field(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: maxLines == 1 ? Icon(icon, color: const Color(0xFF38BDF8)) : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
        ),
      ),
    ),
  );
}

Widget _sectionTitle(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
  return OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 16, color: const Color(0xFF38BDF8)),
    label: Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: Colors.white12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

// ─────────────────────────── CERTIFICATES EDITOR ─────────────────────────────
class _CertificatesEditor extends StatefulWidget {
  final FirebaseService service;
  const _CertificatesEditor({required this.service});
  @override
  State<_CertificatesEditor> createState() => _CertificatesEditorState();
}

class _CertificatesEditorState extends State<_CertificatesEditor> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showForm({Certificate? cert}) {
    final titleCtrl = TextEditingController(text: cert?.title ?? '');
    final issuerCtrl = TextEditingController(text: cert?.issuer ?? '');
    final dateCtrl = TextEditingController(text: cert?.date ?? '');
    final linkCtrl = TextEditingController(text: cert?.link ?? '');
    final urlCtrl = TextEditingController(text: cert?.imageUrl ?? '');
    bool uploading = false;
    bool saving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(cert == null ? 'Add Certificate' : 'Edit Certificate', style: GoogleFonts.poppins(color: Colors.white)),
            content: KeyboardSingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(titleCtrl, 'Certificate Title', Icons.title),
                  _field(issuerCtrl, 'Issuer (e.g. Coursera)', Icons.business),
                  _field(dateCtrl, 'Date / Year', Icons.calendar_today),
                  _field(linkCtrl, 'Verification Link (optional)', Icons.link),
                  _field(urlCtrl, 'Image URL (optional)', Icons.image),
                  const SizedBox(height: 12),
                  Text('OR', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: uploading ? null : () async {
                      try {
                        final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                        if (result == null || result.files.isEmpty) return;
                        setDialogState(() => uploading = true);
                        final file = result.files.first;
                        final url = await widget.service.uploadFile('certificates/', file.bytes!, '${DateTime.now().millisecondsSinceEpoch}_${file.name}');
                        setDialogState(() {
                          urlCtrl.text = url;
                          uploading = false;
                        });
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded!'), backgroundColor: Color(0xFF38BDF8)));
                      } catch (e) {
                        setDialogState(() => uploading = false);
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent));
                      }
                    },
                    icon: uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.upload_file),
                    label: Text(uploading ? 'Uploading...' : 'Upload Image', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E40AF), foregroundColor: Colors.white),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87),
                onPressed: saving ? null : () async {
                  try {
                    setDialogState(() => saving = true);
                    await widget.service.saveCertificate(Certificate(id: cert?.id ?? '', title: titleCtrl.text, issuer: issuerCtrl.text, date: dateCtrl.text, imageUrl: urlCtrl.text, link: linkCtrl.text));
                    setDialogState(() => saving = false);
                    if (mounted) Navigator.pop(context);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Certificate saved!'), backgroundColor: Color(0xFF38BDF8)));
                  } catch(e) {
                    setDialogState(() => saving = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent));
                  }
                },
                child: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87)) : Text('Save', style: GoogleFonts.poppins()),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Certificate>>(
      stream: widget.service.getCertificates(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
        final certs = snap.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Certificates'),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(),
                    icon: const Icon(Icons.add),
                    label: Text('Add Certificate', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              child: KeyboardScrollShortcuts(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: certs.length,
                itemBuilder: (context, i) {
                  final c = certs[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        if (c.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(c.imageUrl, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image, color: Colors.white54)),
                          )
                        else
                          const Icon(Icons.card_membership, color: Color(0xFF38BDF8), size: 40),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('${c.issuer} • ${c.date}', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.edit, color: Color(0xFF38BDF8)), onPressed: () => _showForm(cert: c)),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                          onPressed: () async {
                            try {
                              await widget.service.deleteCertificate(c.id);
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.redAccent));
                            }
                          }
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: 0.1);
                },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────── EXPERIENCE EDITOR ───────────────────────────────
class _ExperienceEditor extends StatefulWidget {
  final FirebaseService service;
  const _ExperienceEditor({required this.service});
  @override
  State<_ExperienceEditor> createState() => _ExperienceEditorState();
}

class _ExperienceEditorState extends State<_ExperienceEditor> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showForm({Experience? exp}) {
    final roleCtrl = TextEditingController(text: exp?.role ?? '');
    final companyCtrl = TextEditingController(text: exp?.company ?? '');
    final durationCtrl = TextEditingController(text: exp?.duration ?? '');
    final descCtrl = TextEditingController(text: exp?.description ?? '');
    bool saving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: Text(exp == null ? 'Add Experience' : 'Edit Experience', style: GoogleFonts.poppins(color: Colors.white)),
            content: KeyboardSingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(roleCtrl, 'Role / Title', Icons.work),
                  _field(companyCtrl, 'Company', Icons.business),
                  _field(durationCtrl, 'Duration (e.g. Jan 2022 - Present)', Icons.calendar_today),
                  _field(descCtrl, 'Description', Icons.description, maxLines: 4),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.white54))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87),
                onPressed: saving ? null : () async {
                  try {
                    setDialogState(() => saving = true);
                    await widget.service.saveExperience(Experience(id: exp?.id ?? '', role: roleCtrl.text, company: companyCtrl.text, duration: durationCtrl.text, description: descCtrl.text));
                    setDialogState(() => saving = false);
                    if (mounted) Navigator.pop(context);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Experience saved!'), backgroundColor: Color(0xFF38BDF8)));
                  } catch(e) {
                    setDialogState(() => saving = false);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.redAccent));
                  }
                },
                child: saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87)) : Text('Save', style: GoogleFonts.poppins()),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Experience>>(
      stream: widget.service.getExperiences(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
        final exps = snap.data!;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle('Experience'),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(),
                    icon: const Icon(Icons.add),
                    label: Text('Add Experience', style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black87),
                  ),
                ],
              ),
            ),
            Expanded(
              child: KeyboardScrollShortcuts(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: exps.length,
                itemBuilder: (context, i) {
                  final e = exps[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.work_outline, color: Color(0xFF38BDF8), size: 30),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.role, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('${e.company} • ${e.duration}', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.edit, color: Color(0xFF38BDF8)), onPressed: () => _showForm(exp: e)),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                          onPressed: () async {
                            try {
                              await widget.service.deleteExperience(e.id);
                            } catch (error) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $error'), backgroundColor: Colors.redAccent));
                            }
                          }
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideX(begin: 0.1);
                },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
