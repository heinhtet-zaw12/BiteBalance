/// Thrown when the user submits a non-food item for analysis.
class InvalidFoodException implements Exception {
  final String message;

  const InvalidFoodException([
    this.message = "That doesn't look like food. Please enter a food or drink item.",
  ]);

  @override
  String toString() => message;
}
