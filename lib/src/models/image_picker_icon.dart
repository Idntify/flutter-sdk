enum ImagePickerIcon { load, loading, loaded }

extension ImagePickerIconExtension on ImagePickerIcon {
  String get name {
    switch (this) {
      case ImagePickerIcon.load:
        return 'assets/icons/upload-icon.png';
      case ImagePickerIcon.loading:
        return 'assets/icons/loader-icon.png';
      case ImagePickerIcon.loaded:
        return 'assets/icons/loaded-icon.png';
      default:
        return null;
    }
  }
}
