import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DotInfo {
  DotInfo(this.offset, this.size, this.color);

  final Offset offset;
  final double size;
  final Color color;
}

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

  void changeEraseMode() {
    _eraseMode = !_eraseMode;
    notifyListeners();
  }

  void drawStart(Offset offset) {
    var oneLine = <DotInfo>[];
    oneLine.add(DotInfo(offset, size, color));
    lines.add(oneLine);
    notifyListeners();
  }

  void drawing(Offset offset) {
    lines.last.add(DotInfo(offset, size, color));
    notifyListeners();
  }

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

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

// ValueChanged<Color> callback
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
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      colorDialog(context);
                    },
                    child: Text("ColorPicker")),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 5),
                    child: Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.white,
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
                  child: Padding(
                    padding: EdgeInsets.only(right: 25),
                    child: Icon(
                      Icons.delete,
                      color:p.eraseMode ?  Colors.black : Colors.grey ,
                      size: 40,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
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
        ],
      ),
    );
  }

  Widget _colorWidget(Color color) {
    var p = Provider.of<DrawingProvider>(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        p.changeColor = color;
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: p.color == color
                ? Border.all(color: Colors.white, width: 4)
                : null,
            color: color),
      ),
    );
  }

  colorDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('ColorPicker'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  ColorPicker(
                    pickerColor: pickerColor,
                    onColorChanged: changeColor,
                  ),
                  ElevatedButton(
                    child: const Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _colorWidget(pickerColor);
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
