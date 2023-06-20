import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
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
  final gkeytemp = GlobalKey();

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
                        Text(p.eraseMode ? "on" : "off", style: TextStyle( color: p.eraseMode ? Colors.black : Colors.grey, fontWeight: FontWeight.w600, fontSize: 18),)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          RepaintBoundary(
            key: gkeytemp,
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
        ],
      ),
    );
  }

  imageChange() async {
    final PathProviderWindows provider = PathProviderWindows();
    final path = join(
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
                      var p = Provider.of<DrawingProvider>(context, listen: false);
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
