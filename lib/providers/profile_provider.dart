import 'package:flutter/foundation.dart';

import '../models/profile.dart';
import '../repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  List<Profile> _profiles = [];
  String? _activeProfileId;
  bool _isLoaded = false;
  int _idCounter = 0;

  bool get isLoaded => _isLoaded;
  List<Profile> get profiles => List.unmodifiable(_profiles);

  Profile? get activeProfile {
    if (_activeProfileId == null) return null;
    for (final profile in _profiles) {
      if (profile.id == _activeProfileId) return profile;
    }
    return null;
  }

  Future<void> init() async {
    final loaded = await _repository.loadProfiles();
    if (loaded.isEmpty) {
      final defaultProfile = Profile(
        id: 'profile_1',
        name: 'Người dùng 1',
        colorIndex: 0,
      );
      _profiles = [defaultProfile];
      _idCounter = 1;
      await _repository.saveProfiles(_profiles);
      _activeProfileId = defaultProfile.id;
      await _repository.saveActiveProfileId(_activeProfileId!);
    } else {
      _profiles = loaded;
      var maxId = 0;
      for (final profile in _profiles) {
        final parts = profile.id.split('_');
        final suffix = int.tryParse(parts.last);
        if (suffix != null && suffix > maxId) maxId = suffix;
      }
      _idCounter = maxId;

      final savedActiveId = await _repository.loadActiveProfileId();
      final stillExists = _profiles.any((p) => p.id == savedActiveId);
      _activeProfileId = stillExists ? savedActiveId : _profiles.first.id;
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addProfile(String name) async {
    _idCounter++;
    final profile = Profile(
      id: 'profile_$_idCounter',
      name: name,
      colorIndex: _profiles.length,
    );
    _profiles.add(profile);
    await _repository.saveProfiles(_profiles);
    notifyListeners();
  }

  Future<void> deleteProfile(String profileId) async {
    if (_profiles.length <= 1) return;
    _profiles.removeWhere((p) => p.id == profileId);
    await _repository.saveProfiles(_profiles);

    if (_activeProfileId == profileId) {
      _activeProfileId = _profiles.first.id;
      await _repository.saveActiveProfileId(_activeProfileId!);
    }
    notifyListeners();
  }

  Future<void> switchProfile(String profileId) async {
    if (_activeProfileId == profileId) return;
    _activeProfileId = profileId;
    await _repository.saveActiveProfileId(profileId);
    notifyListeners();
  }
}
