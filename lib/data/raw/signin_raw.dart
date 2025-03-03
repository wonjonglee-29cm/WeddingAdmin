class SignInRaw {
  final String name;
  final String phoneNumber;

  SignInRaw({required this.name, required this.phoneNumber});

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumber': phoneNumber,
      };
}
