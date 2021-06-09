/// Possible values for an icon in the [Instructions] widget.
enum InstructionImage { front, reverse, selfie }

/// File reference of the possible icon in the [Instructions] widget.
extension InstructionImageExtension on InstructionImage {
  String? get name {
    switch (this) {
      case InstructionImage.front:
        return 'assets/icons/front.png';
      case InstructionImage.reverse:
        return 'assets/icons/back.png';
      case InstructionImage.selfie:
        return 'assets/icons/selfieExample.png';
      default:
        return null;
    }
  }
}
