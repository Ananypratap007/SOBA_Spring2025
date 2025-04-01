import 'package:soba_app/domain/profile_model.dart';

/// A presenter for the [ProfileScreen]
///
/// This presenter handles the business logic for changing the user's
/// profile information
class ProfilePresenter {
  ProfilePresenter({
    /// The currently logged in user.
    required ProfileModel currentUser,
  }) : _currentUser = currentUser;

  ProfileModel _currentUser;

  /// The user's full name
  String? get name => _currentUser.name;
  set name(String? newName) {
    if (newName == null || newName.length < 2) {
      throw ArgumentError('Name cannot be empty');
    }

    _currentUser.name = newName;

    // TODO: Send to the backing store
  }

  /// The user's email address
  String? get email => _currentUser.email;
  set email(String? newEmail) {
    if (newEmail == null || newEmail.contains('@')) {
      throw ArgumentError('Email must be a valid email address');
    }
    _currentUser.email = newEmail;

    // TODO: Send to the backing store
  }

  /// The mobile phone
  String? get mobile => _currentUser.mobile;
  set mobile(String? newMobile) {
    _currentUser.mobile = newMobile;

    // TODO: Send to the backing store
  }
}
