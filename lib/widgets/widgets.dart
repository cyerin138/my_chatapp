import 'package:flutter/material.dart';

// 로그인, 회원가입 디자인
const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(255,185, 235, 226), width: 1.5),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color:Color.fromARGB(255, 185, 235, 226), width: 1.5),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(255,58, 199, 173), width: 2),
  ),
);

// 다음 화면으로 넘어가는 기능
void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

// 다음 화면으로 아예 전환할때 쓰는 기능
void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

// 밑에 경고 문이나 알림 보여줄 때 쓰는 기능
void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );
}
