// Possible values for an icon.
enum CameraButtonIcons { record, recordActive, flip }

// File reference given an enum value
extension CameraButtonIconsImplementation on CameraButtonIcons {
  String? get name {
    switch (this) {
      case CameraButtonIcons.record:
        return 'assets/icons/record.png';
      case CameraButtonIcons.recordActive:
        return 'assets/icons/record-active.png';
      case CameraButtonIcons.flip:
        return 'assets/icons/flip.png';
      default:
        return null;
    }
  }
}
