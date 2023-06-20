import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_chatapp/service/auth_service.dart';
import 'package:my_chatapp/widgets/group_draw.dart';
import 'package:path/path.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:provider/provider.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class DrawingPage extends StatefulWidget {
  static Uint8List? bytes;

  const DrawingPage({Key? key}) : super(key: key);

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

WidgetsToImageController controller = WidgetsToImageController();

class _DrawingPageState extends State<DrawingPage> {
  // 초기 값 세팅
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);



  //요소 세팅
  String userName = "";
  String email = "";
  AuthService authService = AuthService();
  Stream? groups;
  String groupName = "";

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  String getName(String res) {
    return res.substring(res.indexOf("_") + 1);
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    var p = Provider.of<DrawingProvider>(context);
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Colors.grey.shade300),
                ),
                color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      p._eraseMode = false;
                      colorDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        backgroundColor: Theme.of(context).primaryColor),
                    child: Text(
                      "ColorPicker",
                      style: TextStyle(color: Colors.white),
                    )),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 5),
                    child: Slider(
                      activeColor: Theme.of(context).primaryColor,
                      inactiveColor: Colors.grey[300],
                      value: p.size,
                      onChanged: (size) {
                        p.changeSize = size;
                      },
                      min: 3,
                      max: 15,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    p.changeEraseMode();
                  },
                  child: SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: p.eraseMode ? Colors.black : Colors.grey,
                          size: 40,
                        ),
                        Text(
                          p.eraseMode ? "on" : "off",
                          style: TextStyle(
                              color: p.eraseMode ? Colors.black : Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 18),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          WidgetsToImage(
            controller: controller,
            child: Container(
              decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey.shade300),
                  ),
                  color: Colors.white),
              child: SizedBox(
                  height: 500,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: CustomPaint(
                        painter: DrawingPainter(p.lines),
                      )),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (s) {
                          if (p.eraseMode) {
                            p.erase(s.localPosition);
                          } else {
                            p.drawStart(s.localPosition);
                          }
                        },
                        onPanUpdate: (s) {
                          if (p.eraseMode) {
                            p.erase(s.localPosition);
                          } else {
                            p.drawing(s.localPosition);
                          }
                        },
                        child: Container(),
                      ),
                    ],
                  )),
            ),
          ),
          if (DrawingPage.bytes != null) buildImage(DrawingPage.bytes!),
        ],
      ),
    );
  }

// colorpicker 모달창
  colorDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('ColorPicker'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: changeColor,
                  ),
                  ElevatedButton(
                    child: Text('확인',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          width: 0.5,
                          color: Color.fromARGB(255, 65, 232, 201),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 18),
                        backgroundColor: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                      var p =
                          Provider.of<DrawingProvider>(context, listen: false);
                      setState(() {
                        p.changeColor = pickerColor;
                        currentColor = pickerColor;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}

// 그림 그리기
class DrawingPainter extends CustomPainter {
  DrawingPainter(this.lines);

  final List<List<DotInfo>> lines;

  @override
  void paint(Canvas canvas, Size size) {
    for (var oneLine in lines) {
      Color? color;
      double? size;
      var l = <Offset>[];
      var p = Path();
      for (var oneDot in oneLine) {
        color ??= oneDot.color;
        size ??= oneDot.size;
        l.add(oneDot.offset);
      }
      p.addPolygon(l, false);
      canvas.drawPath(
          p,
          Paint()
            ..color = color as Color
            ..strokeWidth = size as double
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

// 점 정보 타입(클래스) 만들기
class DotInfo {
  DotInfo(this.offset, this.size, this.color);

  final Offset offset;
  final double size;
  final Color color;
}

// 처음 세팅과 그릴때 쓰이는 함수들
class DrawingProvider extends ChangeNotifier {
  final lines = <List<DotInfo>>[];

  double _size = 3;

  double get size => _size;

  set changeSize(double size) {
    _size = size;
    notifyListeners();
  }

  Color _color = Colors.black;

  Color get color => _color;

  set changeColor(Color color) {
    _color = color;
    notifyListeners();
  }

  bool _eraseMode = false;

  bool get eraseMode => _eraseMode;

  // 지우개 on/off 바꾸기
  void changeEraseMode() {
    _eraseMode = !_eraseMode;
    notifyListeners();
  }

  // 그림 그리기
  void drawStart(Offset offset) {
    var oneLine = <DotInfo>[];
    oneLine.add(DotInfo(offset, size, color));
    lines.add(oneLine);
    notifyListeners();
  }

  // 그림 그릴때 / 공간 설정
  void drawing(Offset offset) {
    if (Offset(0, 0) < offset && offset < Offset(500, 500)) {
      lines.last.add(DotInfo(offset, size, color));
      notifyListeners();
    }
  }

  // 지우개
  void erase(Offset offset) {
    final eraseGap = 15;
    for (var oneLine in List<List<DotInfo>>.from(lines)) {
      for (var oneDot in oneLine) {
        if (sqrt(pow((offset.dx - oneDot.offset.dx), 2) +
                pow((offset.dy - oneDot.offset.dy), 2)) <
            eraseGap) {
          lines.remove(oneLine);
          break;
        }
      }
    }
    notifyListeners();
  }
}

Widget buildImage(Uint8List bytes) => Image.memory(bytes);