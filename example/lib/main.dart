import 'package:flutter/material.dart';
import 'package:slideshow/slideshow.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SlideshowController ctrl;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Slideshow Example'),
          ),
          body: _buildSlideshow()),
    );
  }

  Widget _buildSlideshow() {
    List<SlideshowItem> list = [];
    for (int i = 0; i < 21; i++) {
      list.add(SlideshowItem(
        Container(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              color: i % 2 == 0 ? Colors.red : Colors.blue,
              child: Center(child: Text("${i}", style: TextStyle(fontSize: 32.0))),
            )),
      ));
    }

    ctrl = SlideshowController(slideshowItems: list);

    return new Slideshow(
        maxDotsIndicator: 10,
        dotSize: 6.0,
        activeDotColor: Colors.amber,
        dotColor: Colors.black,
        useDot: true,
        animationCurve: Curves.ease,
        autoPlay: false,
        dotPosition: Position(bottom: -10.0),
        slideshowController: ctrl);
  }
}
