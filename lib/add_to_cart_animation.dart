import 'drag_to_cart_animation_options.dart';

import 'add_to_cart_icon.dart';
import 'globalkeyext.dart';
import 'package:flutter/material.dart';

export 'add_to_cart_icon.dart';
export 'drag_to_cart_animation_options.dart';

class _PositionedAnimationModel {
  bool showAnimation = false;
  bool animationActive = false;
  Offset imageSourcePoint = Offset.zero;
  Offset imageDestPoint = Offset.zero;
  Size imageSourceSize = Size.zero;
  double opacity = 0.85;
  late Container container;
  Duration duration = Duration.zero;
  Curve curve = Curves.easeInOut;
  double destScale = 0.5;
  double offsetX = 0.0;
  double offsetY = 0.0;
}

/// An add to cart animation which provide you an animation by sliding the product to cart in the Flutter app
class AddToCartAnimation extends StatefulWidget {
  final Widget child;

  /// The Global Key of the [AddToCartIcon] element. We need it because we need to know where is the cart icon is located in the screen. Based on the location, we are dragging given widget to the cart.
  final GlobalKey<CartIconKey> cartKey;

  /// you can receive [runAddToCartAnimation] animation method on [createAddToCartAnimation].
  /// [runAddToCartAnimation] animation method runs the add to cart animation based on the given parameters.
  /// Add to cart animation drags the given widget to the cart based on their location via global keys
  final Function(Future<void> Function(GlobalKey)) createAddToCartAnimation;

  /// What Should the given widget's opacity while dragging to the cart
  final double opacity;

  final double destScale;

  final double offsetX;
  final double offsetY;

  /// The animation options while given widget sliding to cart
  final DragToCartAnimationOptions dragAnimation;

  const AddToCartAnimation({
    Key? key,
    required this.child,
    required this.cartKey,
    required this.createAddToCartAnimation,
    this.opacity = 0.85,
    this.destScale = 0.5,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.dragAnimation = const DragToCartAnimationOptions(),
  }) : super(key: key);

  @override
  _AddToCartAnimationState createState() => _AddToCartAnimationState();
}

class _AddToCartAnimationState extends State<AddToCartAnimation> {
  List<_PositionedAnimationModel> animationModels = [];

  @override
  void initState() {
    this.widget.createAddToCartAnimation(runAddToCartAnimation);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Stack(
            children: animationModels
                .map<Widget>((model) => model.showAnimation
                    ? AnimatedPositioned(
                        top: model.animationActive
                            ? model.imageDestPoint.dy + model.offsetY
                            : model.imageSourcePoint.dy,
                        left: model.animationActive ? (model.imageDestPoint.dx - model.imageSourceSize.width / 2 * model.destScale + model.offsetX) : model.imageSourcePoint.dx,
                        height: model.imageSourceSize.height,
                        width: model.imageSourceSize.width,
                        duration: model.duration,
                        curve: model.curve,
                        child: AnimatedScale(
                          scale: model.animationActive ? model.destScale : 1.0,
                          duration: model.duration,
                          child: Opacity(
                                  opacity: model.opacity,
                                  child: model.container,
                                ),
                        ),
                      )
                    : Container())
                .toList(),
          ),
        ),
      ],
    );
  }

  Future<void> runAddToCartAnimation(GlobalKey widgetKey) async {
    _PositionedAnimationModel animationModel = _PositionedAnimationModel()
      .. destScale = widget.destScale
      ..opacity = widget.opacity
      ..offsetX = widget.offsetX
      ..offsetY = widget.offsetY
    ;

    animationModel.imageSourcePoint = Offset(
      widgetKey.globalPaintBounds!.left,
      widgetKey.globalPaintBounds!.top,
    );

    animationModel.imageDestPoint = Offset(
      this.widget.cartKey.globalPaintBounds!.left,
      this.widget.cartKey.globalPaintBounds!.top,
    );

    animationModel.imageSourceSize = Size(
        widgetKey.currentContext!.size!.width,
        widgetKey.currentContext!.size!.height
    );

    animationModels.add(animationModel);
    // Improvement/Suggestion 2: Changing the animationModel.child from Image to gkImageContainer
    animationModel.container = Container(
      child: (widgetKey.currentWidget! as Container).child,
    );

    animationModel.showAnimation = true;

    setState(() {});

    await Future.delayed(Duration(milliseconds: 75));

    animationModel.animationActive = true; // That's start the animation.
    setState(() {});

    await Future.delayed(animationModel.duration);
    // Drag to cart animation
    animationModel.curve = widget.dragAnimation.curve;
    animationModel.duration =
        widget.dragAnimation.duration; // this is for add to button mode

    animationModel.imageDestPoint = Offset(
        this.widget.cartKey.globalPaintBounds!.left,
        this.widget.cartKey.globalPaintBounds!.top,
      );

    setState(() {});

    await Future.delayed(animationModel.duration);
    animationModel.showAnimation = false;
    animationModel.animationActive = false;

    setState(() {});

    // Improvement/Suggestion 4.3: runCartAnimation is running independently, using gkCart.currentState(main.dart)
    // await this.widget.gkCart.currentState!.runCartAnimation();

    return;
  }
}
