enum DocumentType { back, frontal }

extension DocumentTypeExtension on DocumentType {
  String get name {
    switch (this) {
      case DocumentType.back:
        return 'b';
      case DocumentType.frontal:
        return 'f';
      default:
        return null;
    }
  }
}
