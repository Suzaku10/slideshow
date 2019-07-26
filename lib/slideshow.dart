import 'dart:async';

import 'package:flutter/material.dart';

class Position {
  final double top;
  final double bottom;
  final double left;
  final double right;

  const Position({double top = 8.0, double bottom = 8.0, double left = 8.0, double right = 8.0})
      : this.top = top,
        this.bottom = bottom,
        this.left = left,
        this.right = right;
}

class SlideshowItem {
  Widget widget;
  Widget button;

  SlideshowItem(this.widget, {this.button});
}

class Slideshow extends StatefulWidget {
  final SlideshowController slideshowController;
  final List<Widget> children;

  final double height;
  final EdgeInsetsGeometry margin;

  ///Returns [children]`s [lenght].
  int get childrenCount => children.length;

  ///The transition animation timing curve. Default is [Curves.ease]
  final Curve animationCurve;

  ///The transition animation duration. Default is 250ms.
  final Duration animationDuration;

  ///The amount of time each frame is displayed. Default is 2s.
  final Duration displayDuration;

  final bool autoPlay;
  final bool repeat;
  final bool useDot;

  final Alignment dotAlignment;
  final Alignment buttonAlignment;
  final Position dotPosition;
  final Position buttonPosition;
  final Widget placeholder;
  final Function(double index) callback;
  final int maxDotsIndicator;
  final double dotSize;
  final Color activeDotColor;
  final Color dotColor;
  final Key key;

  Slideshow(
      {Key key,
        double height,
        EdgeInsetsGeometry margin,
        SlideshowController slideshowController,
        this.children,
        this.animationCurve = Curves.bounceOut,
        this.animationDuration = const Duration(milliseconds: 2000),
        this.displayDuration = const Duration(seconds: 5),
        bool autoPlay = true,
        bool repeat = true,
        bool useDot = true,
        this.dotAlignment = Alignment.bottomCenter,
        this.dotPosition = const Position(),
        Widget placeholder,
        this.buttonAlignment = Alignment.bottomCenter,
        this.buttonPosition = const Position(),
        this.callback,
        int maxDotsIndicator,
        double dotSize,
        Color dotColor,
        Color activeDotColor})
      : assert(height == null || height > 0),
        assert(children == null || slideshowController == null),
        assert(animationCurve != null),
        assert(animationDuration != null),
        assert(displayDuration != null),
        this.slideshowController = slideshowController ??
            new SlideshowController(
                slideshowItems: children.map((widget) => SlideshowItem(widget)).toList() /*widgets: children*/),
        this.height = height ?? 210.0,
        this.margin = margin ?? new EdgeInsets.all(0.0),
        this.useDot = useDot ?? true,
        this.autoPlay = autoPlay ?? true,
        this.repeat = repeat ?? true,
        this.maxDotsIndicator = maxDotsIndicator ?? 3,
        this.dotSize = dotSize ?? 8.0,
        this.key = key,
        this.activeDotColor = activeDotColor ?? Colors.white,
        this.dotColor = dotColor ?? Colors.white,
        this.placeholder = placeholder ?? Container();

  @override
  State createState() => new _SlideshowState();
}

class _SlideshowState extends State<Slideshow> with SingleTickerProviderStateMixin {
  PageController _pageController = new PageController();
  ScrollController _scrollController = new ScrollController();

  Timer _timer;

  double dotIncreaseSize = 1.4;
  int position = 0;
  int old = 0;
  bool isEnd = false, isStart = true;
  double currentPage = 0.0;

  double get dotSpacing => widget.dotSize * (dotIncreaseSize + 1);

  ///Actual index of the displaying Widget
  int get actualIndex => !_pageController.hasClients ? 0 : _pageController.page.round();

  ///Returns the calculated value of the next index.
  int get nextIndex {
    var nextIndexValue = actualIndex;

    if (widget.slideshowController.slideshowItems != null &&
        nextIndexValue < widget.slideshowController.slideshowItems.length - 1)
      nextIndexValue++;
    else
      nextIndexValue = 0;

    return nextIndexValue;
  }

  @override
  void initState() {
    super.initState();
    widget.slideshowController.addListener(_updateFromWidget);
  }

  _updateFromWidget() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _timer?.cancel();
  }

  Widget createCarouselPlaceHolder() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(width: constraints.maxWidth, height: widget.height, child: widget.placeholder);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slideshowController.slideshowItems == null || widget.slideshowController.slideshowItems.isEmpty)
      return createCarouselPlaceHolder();

    if (widget.autoPlay) startAnimating();

    _pageController.addListener(() => setState(() {
      currentPage = !_pageController.hasClients ? 0.0 : _pageController.page ?? 0.0;
      if (widget.callback != null) {
        widget.callback((currentPage + 1));
      }
    }));

    return new Container(
        height: widget.height,
        margin: widget.margin,
        child: new Stack(overflow: Overflow.visible, children: [
          new PageView(
              controller: this._pageController,
              physics: new AlwaysScrollableScrollPhysics(),
              children: widget.slideshowController.slideshowItems
                  .map((carouselItem) => new Container(
                child: carouselItem.widget,
              ))
                  .toList(),
              onPageChanged: (current) {
                if (widget.useDot && widget.slideshowController.slideshowItems.length > widget.maxDotsIndicator) {
                  if (current == 0) {
                    isStart = true;
                  }
                  if (current >= (widget.maxDotsIndicator - 1)) {
                    isStart = false;
                  }
                  if (current <= widget.slideshowController.slideshowItems.length - widget.maxDotsIndicator) {
                    isEnd = false;
                  }
                  if (current == widget.slideshowController.slideshowItems.length - 1) {
                    isEnd = true;
                  }

                  if (old < current) {
                    if (position < (widget.maxDotsIndicator - 2)) {
                      position++;
                    }
                  } else if (old > current) {
                    if (position > 1) {
                      position--;
                    }
                  }
                  old = current;
                }
              }),
          new Positioned(
              top: widget.dotPosition.top,
              bottom: widget.dotPosition.bottom,
              left: widget.dotPosition.left,
              right: widget.dotPosition.right,
              child: Container(
                alignment: widget.dotAlignment,
                child: widget.useDot
                    ? widget.slideshowController.slideshowItems.length > widget.maxDotsIndicator
                    ? new Container(
                  width: (dotSpacing * widget.maxDotsIndicator),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: new List<Widget>.generate(
                          widget.slideshowController.slideshowItems.length, _buildDotScrollable),
                    ),
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                  new List<Widget>.generate(widget.slideshowController.slideshowItems.length, _buildDot),
                )
                    : _buildPageNumber(),
              )),
          widget.slideshowController.slideshowItems.length != 0 ? _buildButton() : Container()
        ]));
  }

  Widget _buildButton() {
    double currentPage = !_pageController.hasClients ? 0.0 : _pageController.page ?? 0.0;
    double opacity = (currentPage) - (currentPage).floor();
    return new Positioned(
        bottom: widget.buttonPosition.bottom,
        right: widget.buttonPosition.right,
        left: widget.buttonPosition.left,
        top: widget.buttonPosition.top,
        child: Container(
          alignment: widget.buttonAlignment,
          child: AbsorbPointer(
            absorbing: (opacity < 0.5 ? 1 - opacity * 2 : (opacity - 0.5) * 2) < 0.999999,
            child: Opacity(
              child: widget.slideshowController.slideshowItems[currentPage.round()].button,
              opacity: opacity < 0.5 ? 1 - opacity * 2 : (opacity - 0.5) * 2,
            ),
          ),
        ));
  }

  Widget _buildPageNumber() {
    double opacity = (currentPage) - (currentPage).floor();
    return new Container(
      decoration:
      BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.all(Radius.circular(5.0))),
      padding: EdgeInsets.all(8.0),
      child: new Stack(
        alignment: Alignment.center,
        children: [
          Text.rich(TextSpan(style: TextStyle(fontWeight: FontWeight.w600), children: [
            TextSpan(
                text: '${(currentPage + 1).round()}',
                style:
                TextStyle(color: Colors.black.withOpacity(opacity < 0.5 ? 1 - opacity * 2 : (opacity - 0.5) * 2))),
            TextSpan(text: ' / ${widget.slideshowController.slideshowItems.length}')
          ]))
        ],
      ),
    );
  }

  Widget _buildDotScrollable(int index) {
    int dotRight = 0;
    int dotleft = 0;
    double zoom = (currentPage).floor() == index
        ? ((1.0 - (currentPage - index)) * (dotIncreaseSize - 1)) + 1
        : (currentPage + 1).floor() == index ? ((currentPage + 1.0 - index) * (dotIncreaseSize - 1)) + 1 : 1.0;

    Color dotColors = (currentPage).round() == index ? widget.activeDotColor : widget.dotColor;

    if (position == (widget.maxDotsIndicator - 2)) {
      try {
        _scrollController.animateTo(dotSpacing * (currentPage.round() - (widget.maxDotsIndicator - 2)),
            duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
      } catch (e) {
        print("error :$e");
      }
    } else if (position == 1) {
      try {
        _scrollController.animateTo(dotSpacing * (currentPage.round() - 1),
            duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
      } catch (e) {
        print("error 2 :$e");
      }
    }

    if (isStart && !isEnd) {
      dotleft = (widget.maxDotsIndicator - 1);
      dotRight = (widget.maxDotsIndicator - 1);
    } else if (isEnd && !isStart) {
      dotRight = widget.slideshowController.slideshowItems.length - widget.maxDotsIndicator;
      dotleft = widget.slideshowController.slideshowItems.length - widget.maxDotsIndicator;
    } else {
      if (position == 1) {
        dotRight = currentPage.round() + (widget.maxDotsIndicator - 2);
        dotleft = currentPage.round() - 1;
      } else if (position == (widget.maxDotsIndicator - 2)) {
        dotRight = currentPage.round() + 1;
        dotleft = currentPage.round() - (widget.maxDotsIndicator - 2);
      } else {
        dotRight = currentPage.round() + (widget.maxDotsIndicator - 2) - position + 1;
        dotleft = currentPage.round() - position;
      }
    }

    return new Container(
      width: dotSpacing,
      child: new Stack(
        alignment: Alignment.center,
        children: [
          new Material(
            color: dotColors,
            type: MaterialType.circle,
            child: new Container(
              width: dotleft == index || dotRight == index
                  ? widget.dotSize * (zoom + 0.2) / 1.25
                  : widget.dotSize * (zoom + 0.2),
              height: dotleft == index || dotRight == index
                  ? widget.dotSize * (zoom + 0.2) / 1.25
                  : widget.dotSize * (zoom + 0.2),
            ),
          ),
          new Material(
            color: dotColors,
            type: MaterialType.circle,
            child: new Container(
              width: dotleft == index || dotRight == index ? widget.dotSize * zoom / 2 : widget.dotSize * zoom,
              height: dotleft == index || dotRight == index ? widget.dotSize * zoom / 2 : widget.dotSize * zoom,
              child: new InkWell(
                onTap: () => onPageSelected(index),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    double zoom = (currentPage).floor() == index
        ? ((1.0 - (currentPage - index)) * (dotIncreaseSize - 1)) + 1
        : (currentPage + 1).floor() == index ? ((currentPage + 1.0 - index) * (dotIncreaseSize - 1)) + 1 : 1.0;

    Color dotColors = (currentPage).round() == index ? widget.activeDotColor : widget.dotColor;

    return new Container(
      width: dotSpacing,
      child: new Stack(
        alignment: Alignment.center,
        children: [
          new Material(
            color: dotColors,
            type: MaterialType.circle,
            child: new Container(
              width: widget.dotSize * (zoom + 0.2),
              height: widget.dotSize * (zoom + 0.2),
            ),
          ),
          new Material(
            color: dotColors,
            type: MaterialType.circle,
            child: new Container(
              width: widget.dotSize * zoom,
              height: widget.dotSize * zoom,
              child: new InkWell(
                onTap: () => onPageSelected(index),
              ),
            ),
          )
        ],
      ),
    );
  }

  void startAnimating() {
    _timer?.cancel();

    //Every widget.displayDuration (time) the tabbar controller will animate to the next index.
    _timer = new Timer.periodic(
      widget.displayDuration,
          (_) {
        if (!widget.repeat) {
          if (this.nextIndex == 0) _timer.cancel();

          if (!_timer.isActive) return;
        }

        this
            ._pageController
            .animateToPage(this.nextIndex, curve: widget.animationCurve, duration: widget.animationDuration);
      },
    );
  }

  onPageSelected(int index) {
    _pageController.animateToPage(index, duration: widget.animationDuration, curve: widget.animationCurve);
  }
}

class SlideshowController extends ValueNotifier<SlideshowEditingValue> {
  List<SlideshowItem> get slideshowItems => value.slideshowItems;

  set widgets(List<Widget> newWidgets) {
    value = value.copyWith(widgets: newWidgets);
  }

  SlideshowController({List<SlideshowItem> slideshowItems})
      : super(slideshowItems == null
      ? SlideshowEditingValue.empty
      : new SlideshowEditingValue(slideshowItems: slideshowItems));

  SlideshowController.fromValue(SlideshowEditingValue value) : super(value ?? SlideshowEditingValue.empty);

  void clear() {
    value = SlideshowEditingValue.empty;
  }
}

@immutable
class SlideshowEditingValue {
  const SlideshowEditingValue({this.slideshowItems});

  final List<SlideshowItem> slideshowItems;

  static const SlideshowEditingValue empty = const SlideshowEditingValue();

  SlideshowEditingValue copyWith({List<Widget> widgets}) {
    return new SlideshowEditingValue(slideshowItems: widgets ?? this.slideshowItems);
  }

  SlideshowEditingValue.fromValue(SlideshowEditingValue copy) : this.slideshowItems = copy.slideshowItems;

  @override
  String toString() => '$runtimeType(widgets: \u2524$slideshowItems\u251C)';

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! SlideshowEditingValue) return false;
    final SlideshowEditingValue typedOther = other;
    return typedOther.slideshowItems == slideshowItems;
  }

  @override
  int get hashCode => hashValues(slideshowItems.hashCode, slideshowItems.hashCode);
}