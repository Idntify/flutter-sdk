/// Identificators for possible documents (ID images).
enum DocumentType { back, frontal }

/// Values of the identificators for possible documents (ID images).
/// The values are set just as the IDntify services expected to be sent.
extension DocumentTypeExtension on DocumentType {
  String? get name {
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
