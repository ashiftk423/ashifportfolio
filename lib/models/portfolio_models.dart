class ProfileInfo {
  final String name;
  final String title;
  final String description;
  final String email;
  final String phone;
  final String whatsapp;
  final String cvUrl;
  final String photoUrl;

  ProfileInfo({
    this.name = '',
    this.title = '',
    this.description = '',
    this.email = '',
    this.phone = '',
    this.whatsapp = '',
    this.cvUrl = '',
    this.photoUrl = '',
  });

  factory ProfileInfo.fromMap(Map<String, dynamic> map) {
    return ProfileInfo(
      name: map['name'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      cvUrl: map['cvUrl'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'description': description,
      'email': email,
      'phone': phone,
      'whatsapp': whatsapp,
      'cvUrl': cvUrl,
      'photoUrl': photoUrl,
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
