enum InfoIcon {
  identity,
  photo,
  selfie,
  complete
}

extension InfoIconExension on InfoIcon {
  String get name {
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
