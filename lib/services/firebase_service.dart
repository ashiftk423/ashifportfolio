import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/portfolio_models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(message, name: 'FirebaseService', error: error, stackTrace: stackTrace);
  }

  // PROFILE INFO
  Stream<ProfileInfo> getProfileInfo() {
    _log('Starting stream for ProfileInfo...');
    return _firestore.collection('info').doc('main').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _log('Fetched ProfileInfo successfully.');
        return ProfileInfo.fromMap(snapshot.data()!);
      }
      _log('ProfileInfo not found, returning default.');
      return ProfileInfo();
    }).handleError((error, stackTrace) {
      _log('Error streaming ProfileInfo', error: error, stackTrace: stackTrace);
      throw error;
    });
  }

  Future<void> updateProfileInfo(ProfileInfo info) async {
    try {
      _log('Updating ProfileInfo...');
      await _firestore.collection('info').doc('main').set(info.toMap(), SetOptions(merge: true));
      _log('ProfileInfo updated successfully.');
    } catch (e, stack) {
      _log('Failed to update ProfileInfo', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Merges only the given fields (e.g. after a Storage upload) so the live site updates immediately.
  Future<void> mergeProfileFields(Map<String, dynamic> fields) async {
    try {
      _log('Merging ProfileInfo fields: ${fields.keys.join(", ")}...');
      await _firestore.collection('info').doc('main').set(fields, SetOptions(merge: true));
      _log('ProfileInfo fields merged.');
    } catch (e, stack) {
      _log('Failed to merge ProfileInfo', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Deletes a file in Firebase Storage from its download URL. No-op if URL is empty or invalid.
  Future<void> deleteStorageFileByUrl(String? downloadUrl) async {
    if (downloadUrl == null || downloadUrl.isEmpty) return;
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
      _log('Deleted storage object for URL.');
    } catch (e, stack) {
      _log('deleteStorageFileByUrl skipped or failed (object missing/invalid URL is OK)',
          error: e, stackTrace: stack);
    }
  }

  // PROJECTS
  Stream<List<Project>> getProjects() {
    _log('Starting stream for Projects...');
    return _firestore.collection('projects').snapshots().map((snapshot) {
      _log('Fetched \${snapshot.docs.length} Projects.');
      return snapshot.docs.map((doc) => Project.fromMap(doc.id, doc.data())).toList();
    }).handleError((error, stackTrace) {
      _log('Error streaming Projects', error: error, stackTrace: stackTrace);
      throw error;
    });
  }

  Future<void> saveProject(Project project) async {
    try {
      _log('Saving Project: \${project.heading}...');
      if (project.id.isEmpty) {
        await _firestore.collection('projects').add(project.toMap());
      } else {
        await _firestore.collection('projects').doc(project.id).set(project.toMap(), SetOptions(merge: true));
      }
      _log('Project saved successfully.');
    } catch (e, stack) {
      _log('Failed to save Project', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      _log('Deleting Project ID: \$id...');
      await _firestore.collection('projects').doc(id).delete();
      _log('Project deleted successfully.');
    } catch (e, stack) {
      _log('Failed to delete Project', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // SKILLS
  Stream<List<Skill>> getSkills() {
    _log('Starting stream for Skills...');
    return _firestore.collection('skills').snapshots().map((snapshot) {
      _log('Fetched \${snapshot.docs.length} Skills.');
      return snapshot.docs.map((doc) => Skill.fromMap(doc.id, doc.data())).toList();
    }).handleError((error, stackTrace) {
      _log('Error streaming Skills', error: error, stackTrace: stackTrace);
      throw error;
    });
  }

  Future<void> saveSkill(Skill skill) async {
    try {
      _log('Saving Skill: \${skill.name}...');
      if (skill.id.isEmpty) {
        await _firestore.collection('skills').add(skill.toMap());
      } else {
        await _firestore.collection('skills').doc(skill.id).set(skill.toMap(), SetOptions(merge: true));
      }
      _log('Skill saved successfully.');
    } catch (e, stack) {
      _log('Failed to save Skill', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteSkill(String id) async {
    try {
      _log('Deleting Skill ID: \$id...');
      await _firestore.collection('skills').doc(id).delete();
      _log('Skill deleted successfully.');
    } catch (e, stack) {
      _log('Failed to delete Skill', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // SOCIAL LINKS
  Stream<List<SocialLink>> getSocialLinks() {
    _log('Starting stream for SocialLinks...');
    return _firestore.collection('social_links').snapshots().map((snapshot) {
      _log('Fetched \${snapshot.docs.length} SocialLinks.');
      return snapshot.docs.map((doc) => SocialLink.fromMap(doc.id, doc.data())).toList();
    }).handleError((error, stackTrace) {
      _log('Error streaming SocialLinks', error: error, stackTrace: stackTrace);
      throw error;
    });
  }

  Future<void> saveSocialLink(SocialLink link) async {
    try {
      _log('Saving SocialLink: \${link.username}...');
      if (link.id.isEmpty) {
        await _firestore.collection('social_links').add(link.toMap());
      } else {
        await _firestore.collection('social_links').doc(link.id).set(link.toMap(), SetOptions(merge: true));
      }
      _log('SocialLink saved successfully.');
    } catch (e, stack) {
      _log('Failed to save SocialLink', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteSocialLink(String id) async {
    try {
      _log('Deleting SocialLink ID: \$id...');
      await _firestore.collection('social_links').doc(id).delete();
      _log('SocialLink deleted successfully.');
    } catch (e, stack) {
      _log('Failed to delete SocialLink', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // CERTIFICATES
  Stream<List<Certificate>> getCertificates() {
    _log('Starting stream for Certificates...');
    return _firestore.collection('certificates').snapshots().map((snapshot) {
      _log('Fetched ${snapshot.docs.length} Certificates.');
      return snapshot.docs.map((doc) => Certificate.fromMap(doc.id, doc.data())).toList();
    }).handleError((error, stackTrace) {
      _log('Error streaming Certificates', error: error, stackTrace: stackTrace);
      throw error;
    });
  }

  Future<void> saveCertificate(Certificate cert) async {
    try {
      _log('Saving Certificate: ${cert.title}...');
      if (cert.id.isEmpty) {
        await _firestore.collection('certificates').add(cert.toMap());
      } else {
        await _firestore.collection('certificates').doc(cert.id).set(cert.toMap(), SetOptions(merge: true));
      }
      _log('Certificate saved successfully.');
    } catch (e, stack) {
      _log('Failed to save Certificate', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteCertificate(String id) async {
    try {
      _log('Deleting Certificate ID: $id...');
      await _firestore.collection('certificates').doc(id).delete();
      _log('Certificate deleted successfully.');
    } catch (e, stack) {
      _log('Failed to delete Certificate', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // EXPERIENCE
  Stream<List<Experience>> getExperiences() {
    _log('Starting stream for Experiences...');
    // We can order by a specific field if we added one, but for now we'll just pull them
    return _firestore.collection('experience').snapshots().map((snapshot) {
      _log('Fetched ${snapshot.docs.length} Experiences.');
      return snapshot.docs.map((doc) => Experience.fromMap(doc.id, doc.data())).toList();
    }).handleError((error, stackTrace) {
      _log('Error streaming Experiences', error: error, stackTrace: stackTrace);
      throw error;
    });
  }

  Future<void> saveExperience(Experience exp) async {
    try {
      _log('Saving Experience: ${exp.role}...');
      if (exp.id.isEmpty) {
        await _firestore.collection('experience').add(exp.toMap());
      } else {
        await _firestore.collection('experience').doc(exp.id).set(exp.toMap(), SetOptions(merge: true));
      }
      _log('Experience saved successfully.');
    } catch (e, stack) {
      _log('Failed to save Experience', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteExperience(String id) async {
    try {
      _log('Deleting Experience ID: $id...');
      await _firestore.collection('experience').doc(id).delete();
      _log('Experience deleted successfully.');
    } catch (e, stack) {
      _log('Failed to delete Experience', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // STORAGE UPLOADS
  Future<String> uploadFile(String path, Uint8List fileBytes, String fileName) async {
    try {
      _log('Uploading file to storage path: $path$fileName...');
      final ref = _storage.ref().child('$path$fileName');
      final uploadTask = ref.putData(fileBytes);
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      _log('File uploaded successfully. URL: \$url');
      return url;
    } catch (e, stack) {
      _log('Failed to upload file', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
