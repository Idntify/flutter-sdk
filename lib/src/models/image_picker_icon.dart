/// Possible values for the [ImagePickerSelector] icon depending on the state of the widget.
enum ImagePickerIcon { load, loading, loaded }

/// File reference of the possible [ImagePickerSelector] icons.
extension ImagePickerIconExtension on ImagePickerIcon {
  String? get name {
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
