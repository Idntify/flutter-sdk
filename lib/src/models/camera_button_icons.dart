enum CameraButtonIcons {
  record,
  recordActive,
  flip
}

extension CameraButtonIconsImplementation on CameraButtonIcons {
  String get name {
    switch (this) {
      case CameraButtonIcons.record:
        return 'icons/record.png';
      case CameraButtonIcons.recordActive:
        return 'icons/record-active.png';
      case CameraButtonIcons.flip:
        return 'icons/flip.png';
      default:
        return null;
    }
  }
}   
