import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';

import 'package:my_chatapp/helper/helper_function.dart';
import 'package:my_chatapp/pages/auth/login_page.dart';
import 'package:my_chatapp/pages/search_page.dart';
import 'package:my_chatapp/pages/drawing_page.dart';
import 'package:my_chatapp/service/auth_service.dart';
import 'package:my_chatapp/service/database_service.dart';
import 'package:my_chatapp/widgets/group_tile.dart';
import 'package:my_chatapp/widgets/widgets.dart';
import 'package:my_chatapp/widgets/group_draw.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 요소 세팅
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";
  final gkeytemp = GlobalKey();

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }
  
  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  // 해당 유저 데이터 가져오기
  gettingUserData() async {
    await HelperFunctions.getUserEmailFromSF().then((value) {
      setState(() {
        email = value!;
      });
    });
    await HelperFunctions.getUserNameFromSF().then((val) {
      setState(() {
        userName = val!;
      });
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((snapshot) {
      setState(() {
        groups = snapshot;
      });
    });
  }

  int _selectedIndex = 0;

  // 밑에 바 움직일 때 이벤트
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "콘톡",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'kbo'),
        ),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 20,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: Icon(
                  Icons.format_list_bulleted,
                  size: 30,
                ),
              ),
              label: '방 목록',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: Icon(
                  Icons.search,
                  size: 30,
                ),
              ),
              label: '방 검색',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: Icon(
                  Icons.sentiment_satisfied_alt,
                  size: 30,
                ),
              ),
              label: '임티',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                child: Icon(
                  Icons.person,
                  size: 30,
                ),
              ),
              label: '계정',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
          unselectedFontSize: 12,
          selectedFontSize: 12,
          onTap: _onItemTapped,
        ),
      ),
      body: Center(
        child: [
          groupList(),
          new SearchPage(),
          new DrawingPage(gkeytemp: gkeytemp),
          userProfile()
        ].elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 0 ?  FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ) : null,
    );
  }

  // 방 생성하는 모달 창
  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: const Text(
                "방 생성",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? Center(
                          child: CircularProgressIndicator(
                              color: Theme.of(context).primaryColor),
                        )
                      : TextField(
                          onChanged: (val) {
                            setState(() {
                              groupName = val;
                            });
                          },
                          style: TextStyle(color: Colors.black),
                          decoration: textInputDecoration.copyWith(
                              labelText: "방 이름",
                              labelStyle: TextStyle(color: Colors.grey)),
                        ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 110,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (groupName != "") {
                              setState(() {
                                _isLoading = true;
                              });
                              DatabaseService(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .createGroup(
                                      userName,
                                      FirebaseAuth.instance.currentUser!.uid,
                                      groupName)
                                  .whenComplete(() {
                                _isLoading = false;
                              });
                              Navigator.of(context).pop();
                              showSnackbar(
                                  context, Colors.green, "성공적으로 방이 생성되었습니다.");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 18),
                          ),
                          child: Text("방 생성"),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                              side: BorderSide(
                                width: 0.5,
                                color: Color.fromARGB(255, 65, 232, 201),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 18),
                              backgroundColor: Colors.white),
                          child: Text("닫기",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }));
        });
  }

  // 위젯 이미지로 바꾸기
  imageChange() async {
    final PathProviderWindows provider = PathProviderWindows();
    final path = Path.join(
        await provider.getTemporaryPath() as String,
        '${DateTime.now()}.png'
    );

    if(gkeytemp != null) {
      final RenderRepaintBoundary rojecet = gkeytemp.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image tempscreen = await rojecet.toImage(
          pixelRatio: MediaQuery.of(gkeytemp.currentContext!).devicePixelRatio
      );
      final ByteData? byteData = await tempscreen.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List png8Byttes = byteData!.buffer.asUint8List();
      final File file = File(path);
      await file.writeAsBytes(png8Byttes);

    } else {
      print("error");
    }

  }

// 해당 유저가 입장 되어있는 방 목록
  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snapshot) {
        // make some checks
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reverseIndex = snapshot.data['groups'].length - index - 1;
                  return GroupTile(
                      groupId: getId(snapshot.data['groups'][reverseIndex]),
                      groupName: getName(snapshot.data['groups'][reverseIndex]),
                      userName: snapshot.data['fullName']);
                },
              );
            } else {
              return noGroupWidget();
            }
          } else {
            return noGroupWidget();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor),
          );
        }
      },
    );
  }

  
  // 만약 유저가 아무 방에도 입장해있지 않을 경우
  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[400],
              size: 75,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 280,
            child: Text(
              "입장한 방이 없습니다. 추가 아이콘을 눌러 방을 생성하거나 방 검색에서 방에 입장해보세요!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
            ),
          )
        ],
      ),
    );
  }

// 계정 화면
  userProfile() {
    return  Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          children: [
            Icon(
              Icons.account_circle,
              size: 150,
              color: Colors.grey[600],
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
            ),
            SizedBox(
              height: 12,
            ),
            Text(
              email,
              textAlign: TextAlign.center,
              style: TextStyle( fontSize: 16, color: Colors.grey),
            ),
            SizedBox(
              height: 40,
            ),
            const Divider(
              height: 2,
            ),

            ListTile(
              onTap: () async {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "로그 아웃",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 40,
                              child: Text(
                                "정말 로그아웃 하시겠습니까?",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black87),
                              ),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await authService.signOut();
                                      Navigator.of(context)
                                          .pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              const LoginPage()),
                                              (route) => false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Theme.of(context).primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 18),
                                    ),
                                    child: Text("로그아웃"),
                                  ),
                                ),
                                SizedBox(
                                  width: 110,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        side: BorderSide(
                                          width: 0.5,
                                          color: Color.fromARGB(
                                              255, 65, 232, 201),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 18),
                                        backgroundColor: Colors.white),
                                    child: Text("닫기",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    });
              },
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text(
                "로그아웃",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ));
  }
}
