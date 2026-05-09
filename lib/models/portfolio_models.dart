class ProfileInfo {
  final String name;
  final String title;
  final String description;
  final String email;
  /// Multiple numbers (international, local, etc.). Prefer this over [phone].
  final List<String> phones;
  /// Multiple WhatsApp numbers with country code. Prefer this over [whatsapp].
  final List<String> whatsapps;
  final String cvUrl;
  final String photoUrl;

  /// When true, public portfolio shows playful maintenance banners (site stays usable).
  final bool maintenanceMode;

  /// First phone for legacy reads / quick display.
  String get phone => phones.isNotEmpty ? phones.first : '';

  /// First WhatsApp for legacy reads.
  String get whatsapp => whatsapps.isNotEmpty ? whatsapps.first : '';

  ProfileInfo({
    this.name = '',
    this.title = '',
    this.description = '',
    this.email = '',
    List<String>? phones,
    List<String>? whatsapps,
    this.cvUrl = '',
    this.photoUrl = '',
    this.maintenanceMode = false,
  })  : phones = List.unmodifiable(_normalizeList(phones)),
        whatsapps = List.unmodifiable(_normalizeList(whatsapps));

  static List<String> _normalizeList(List<String>? list) {
    if (list == null || list.isEmpty) return const [];
    return list.map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
  }

  static List<String> _phonesFromFirestore(Map<String, dynamic> map) {
    final listKey = map['phones'];
    if (listKey is List) {
      return listKey.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    final legacy = map['phone'];
    if (legacy is String && legacy.trim().isNotEmpty) return [legacy.trim()];
    return [];
  }

  static List<String> _whatsappsFromFirestore(Map<String, dynamic> map) {
    final listKey = map['whatsapps'];
    if (listKey is List) {
      return listKey.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    final legacy = map['whatsapp'];
    if (legacy is String && legacy.trim().isNotEmpty) return [legacy.trim()];
    return [];
  }

  factory ProfileInfo.fromMap(Map<String, dynamic> map) {
    return ProfileInfo(
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      email: map['email'] ?? '',
      phones: _phonesFromFirestore(map),
      whatsapps: _whatsappsFromFirestore(map),
      cvUrl: map['cvUrl'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      maintenanceMode: map['maintenanceMode'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'description': description,
      'email': email,
      'phones': phones,
      'whatsapps': whatsapps,
      // Legacy single fields so older data consumers still see a primary number.
      'phone': phone,
      'whatsapp': whatsapp,
      'cvUrl': cvUrl,
      'photoUrl': photoUrl,
      'maintenanceMode': maintenanceMode,
    };
  }
}

class Project {
  final String id;
  final String heading;
  final String description;
  final List<String> images;
  final String? link;

  Project({
    required this.id,
    required this.heading,
    required this.description,
    required this.images,
    this.link,
  });

  factory Project.fromMap(String id, Map<String, dynamic> map) {
    return Project(
      id: id,
      heading: map['heading'] ?? '',
      description: map['description'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      link: map['link'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'heading': heading,
      'description': description,
      'images': images,
      'link': link,
    };
  }
}

class Skill {
  final String id;
  final String name;
  final String imageUrl;

  Skill({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Skill.fromMap(String id, Map<String, dynamic> map) {
    return Skill(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }
}

class SocialLink {
  final String id;
  final String username;
  final String linkUrl;
  final String logoUrl;

  SocialLink({
    required this.id,
    required this.username,
    required this.linkUrl,
    this.logoUrl = '',
  });

  factory SocialLink.fromMap(String id, Map<String, dynamic> map) {
    return SocialLink(
      id: id,
      username: map['username'] ?? '',
      linkUrl: map['linkUrl'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'linkUrl': linkUrl,
      'logoUrl': logoUrl,
    };
  }
}

class Certificate {
  final String id;
  final String title;
  final String issuer;
  final String date;
  final String imageUrl;
  final String link;

  Certificate({
    required this.id,
    required this.title,
    required this.issuer,
    required this.date,
    this.imageUrl = '',
    this.link = '',
  });

  factory Certificate.fromMap(String id, Map<String, dynamic> map) {
    return Certificate(
      id: id,
      title: map['title'] ?? '',
      issuer: map['issuer'] ?? '',
      date: map['date'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      link: map['link'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'issuer': issuer,
      'date': date,
      'imageUrl': imageUrl,
      'link': link,
    };
  }
}

class Experience {
  final String id;
  final String role;
  final String company;
  final String duration;
  final String description;

  Experience({
    required this.id,
    required this.role,
    required this.company,
    required this.duration,
    this.description = '',
  });

  factory Experience.fromMap(String id, Map<String, dynamic> map) {
    return Experience(
      id: id,
      role: map['role'] ?? '',
      company: map['company'] ?? '',
      duration: map['duration'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'company': company,
      'duration': duration,
      'description': description,
    };
  }
}
