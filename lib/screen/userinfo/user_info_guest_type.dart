
enum GuestType {
  BOTH('둘 다'),
  GROOM('신랑'),
  BRIDE('신부');

  final String title;

  const GuestType(this.title);

  static GuestType? fromString(String? value) {
    if (value == null) return null;
    return GuestType.values.firstWhere(
          (type) => type.name == value.toLowerCase(),
      orElse: () => GuestType.BOTH,
    );
  }
}