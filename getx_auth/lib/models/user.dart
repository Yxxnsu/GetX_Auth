import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const ID = "id";
  static const NAME = "name";
  static const EMAIL = "email";

   late final String id;
   late final String name;
   late final String email;


  UserModel.fromSnapshot(DocumentSnapshot snapshot) {
    name = snapshot.data()?[NAME];
    email = snapshot.data()?[EMAIL];
    id = snapshot.data()?[ID];
  }
}
