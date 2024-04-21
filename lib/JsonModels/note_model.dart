class NoteModel {
  final int? userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String createdAt;
  bool visited;
  NoteModel({
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,// Default value for visited, assuming it's an integer
    required this.createdAt,
    this.visited  =false,
  });
 void isDoneTask() {
    visited = !visited;
  }
  factory NoteModel.fromMap(Map<String, dynamic> json) => NoteModel(
        userId: json["userId"] as int?, // Handle nullable userId
        firstName: json["firstName"] as String,
        lastName: json["lastName"] as String,
        phoneNumber: json["phoneNumber"] as String,// Assuming visited is stored as an integer
        createdAt: json["createdAt"] as String,
      );

  Map<String, dynamic> toMap() => {
        "userId": userId,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "createdAt": createdAt,
      };
}
