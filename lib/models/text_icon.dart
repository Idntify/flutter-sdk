enum TextIcon {
  first,
  second,
  front,
  reverse
}

extension TextIconExtension on TextIcon {
  String get name {
    switch (this) {
      case TextIcon.first:
        return 'assets/icons/instruction1.png';
      case TextIcon.second:
        return 'assets/icons/instruction2.png';
      case TextIcon.front:
        return 'assets/icons/idFront.png';
      case TextIcon.reverse:
        return 'assets/icons/idReverse.png';
      default:
        return null;
    }
  }
}
