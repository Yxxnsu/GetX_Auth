import 'package:cadevo/constants/firebase.dart';
import 'package:cadevo/helpers/showLoading.dart';
import 'package:cadevo/models/user.dart';
import 'package:cadevo/screens/authentication/auth.dart';
import 'package:cadevo/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController{
  static AuthController instance = Get.find();
  late Rx<User?> firebaseUser;
  RxBool isLoggedIn = false.obs;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  String userCollection = 'user';
  Rx<UserModel> userModel = UserModel().obs;


  @override
  void onReady(){
    super.onReady();
    firebaseUser = Rx<User>(auth.currentUser!);

    //Resign 될 때에 firebaseUser Update 해준다!
    firebaseUser.bindStream(auth.userChanges()); 

    //Reasign시 굉장히 유용하다!
    // ever => (listener, callback) 인데 즉, firebase User에 변화가 일어나면 _setInialScreen을 호출해준다!
    ever(firebaseUser, _setInitialScreen);
  }
  
  _setInitialScreen(User? user){
    if(user == null){
      Get.offAll(() => AuthenticationScreen());
    }else{
      Get.offAll(() => HomeScreen());
    }
  }

  void signIn()async{
    try{
      snowLoading();
      await auth.signInWithEmailAndPassword(
        email: email.text.trim(), 
        password: password.text.trim()).then((result) {
          String _userId = result.user!.uid;
          _initializeUserModel(_userId);
          _clearController();
        });

    } catch(e){
      debugPrint(e.toString());
      Get.snackbar('Sign In Failed', 'Try again',);
    }    
  }
   void signUp() async {
      try{
        snowLoading();
        await auth.createUserWithEmailAndPassword(
        email: email.text.trim(), password: password.text.trim()).then((result){
          String _userId = result.user!.uid;
          _initializeUserModel(_userId);
          _addUserToFirestore(_userId);
          _clearController();
        });
    } catch(e){
      debugPrint(e.toString());
      Get.snackbar('Sign In Failed', 'Try again');
    }  
  }
   void signOut() async {
    auth.signOut();
  }

  _addUserToFirestore(String userId){
    firebaseFirestore.collection(userCollection).doc(userId).set({
      "name": name.text.trim(),
      'id': userId,
      "email": email.text.trim()
    });
  }
  
  _initializeUserModel(String userId) async {

    userModel.value = await firebaseFirestore
      .collection(userCollection).doc(userId)
      .get()
      .then((doc) => UserModel.fromSnapshot(doc));
  }

  _clearController(){
    name.clear();
    email.clear();
    password.clear();
  }
}
   