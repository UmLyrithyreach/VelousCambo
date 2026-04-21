abstract class ProfileState {
  const ProfileState();
}

/// No save operation in progress.
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// A profile update is being written to Firestore.
class ProfileSaving extends ProfileState {
  const ProfileSaving();
}

/// Profile update completed successfully.
class ProfileSaved extends ProfileState {
  const ProfileSaved();
}

/// Profile update failed.
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}
