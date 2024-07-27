import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart'; // Import the login screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    Timer(Duration(seconds: 4), () {
      // Navigate to login screen with custom transition
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.3)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FadeTransition(
                  opacity: _animation,
                  child: Image.asset(
                    'assets/images/icon.png',
                    width: 250, // Increased width
                    height: 250, // Increased height
                  ),
                ),
                SizedBox(height: 20),
                FadeTransition(
                  opacity: _animation,
                  child: Text(
                    'Village Connect',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                AnimatedTagline(
                  text: 'A platform serving essential services',
                  animation: _animation,
                ),
                SizedBox(height: 30),
                CustomDotsIndicator(controller: _dotsController),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedTagline extends StatefulWidget {
  final String text;
  final Animation<double> animation;

  AnimatedTagline({required this.text, required this.animation});

  @override
  _AnimatedTaglineState createState() => _AnimatedTaglineState();
}

class _AnimatedTaglineState extends State<AnimatedTagline> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        // Calculate the number of letters to show based on the animation value
        int lettersToShow =
            (widget.text.length * widget.animation.value).round();
        String displayedText = widget.text.substring(0, lettersToShow);

        return Text(
          displayedText,
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

class CustomDotsIndicator extends StatefulWidget {
  final AnimationController controller;

  CustomDotsIndicator({required this.controller});

  @override
  _CustomDotsIndicatorState createState() => _CustomDotsIndicatorState();
}

class _CustomDotsIndicatorState extends State<CustomDotsIndicator> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (index) {
            double opacity =
                (widget.controller.value * 3 - index).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
