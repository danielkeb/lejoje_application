//In here first we create the users json model
// To parse this JSON data, do
//

class Users {
  final int? usrId;
  final String usrName;
  final String phoneNumber;
  final String usrPassword;

  Users({
    this.usrId,
    required this.usrName,
    required this.phoneNumber,
    required this.usrPassword,
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        usrId: json["usrId"],
        usrName: json["usrName"],
        phoneNumber: json["phoneNumber"],
        usrPassword: json["usrPassword"],
      );

  Map<String, dynamic> toMap() => {
        "usrId": usrId,
        "usrName": usrName,
        "phoneNumber": phoneNumber,
        "usrPassword": usrPassword,
      };
}
