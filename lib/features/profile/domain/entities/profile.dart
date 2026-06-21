class Profile {
  final String id;
  final String? fullName;
  final double? weight;
  final double? height;
  final String? goal;

  const Profile({
    required this.id,
    this.fullName,
    this.weight,
    this.height,
    this.goal,
  });
}
