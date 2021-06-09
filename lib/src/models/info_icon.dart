/// Possible values for an icon in the [Info] widget.
enum InfoIcon { identity, photo, selfie, complete }

/// File reference of the possible icons in the [Info] widget.
extension InfoIconExension on InfoIcon? {
  String? get name {
    switch (this) {
      case InfoIcon.identity:
        return 'assets/icons/identity.png';
      case InfoIcon.photo:
        return 'assets/icons/photo.png';
      case InfoIcon.selfie:
        return 'assets/icons/selfie.png';
      case InfoIcon.complete:
        return 'assets/icons/check.png';
      default:
        return null;
    }
  }
}
