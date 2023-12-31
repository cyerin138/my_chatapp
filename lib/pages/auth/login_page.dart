import 'package:my_chatapp/helper/helper_function.dart';
import 'package:my_chatapp/pages/auth/register_page.dart';
import 'package:my_chatapp/pages/home_page.dart';
import 'package:my_chatapp/service/auth_service.dart';
import 'package:my_chatapp/service/database_service.dart';
import 'package:my_chatapp/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "콘톡",
                          style: TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'kbo'),
                        ),
                        SizedBox(height: 10),
                        Text("로그인을 하여 여러 사람들과 대화해보세요!",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400)),
                        SizedBox(height: 30),
                        Image.asset(
                          "assets/login.jpg",
                          width: 350,
                          fit: BoxFit.fill,
                        ),
                        SizedBox(height: 50),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              labelText: "이메일",
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Icon(
                                  Icons.email,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                          validator: (val) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "이메일을 다시 확인해주세요.";
                          },
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(
                              labelText: "비밀번호",
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Icon(
                                  Icons.lock,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (val) {
                            if (val!.length < 6) {
                              return "비밀번호는 6글자가 넘어야합니다.";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                padding: EdgeInsets.all(23)),
                            child: const Text(
                              "로그인",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            onPressed: () {
                              login();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text.rich(TextSpan(
                          text: "계정이 없으신가요?  ",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                          children: [
                            TextSpan(
                                text: "회원가입",
                                style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const RegisterPage());
                                  }),
                          ],
                        )),
                      ],
                    )),
              ),
            ),
    );
  }

  // 로그인 값 체크 와 로그인
  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginWithUserNameandPassword(email, password)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);
          // shared preferences에 저장
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['fullName']);
          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, '이메일과 비밀번호를 다시 확인해주세요.');
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}
