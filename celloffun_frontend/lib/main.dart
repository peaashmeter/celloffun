import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'widgets/main_screen.dart';

void main() {
  usePathUrlStrategy();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    const double maxWidth = 500;

    return MaterialApp(
        title: 'Целлофан',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        )),
        home: Scaffold(
          body: size.width < maxWidth
              ? const MainScreen()
              : Center(
                  child: SizedBox(
                    width: maxWidth,
                    child: Navigator(
                      onGenerateRoute: (route) => MaterialPageRoute(
                          builder: (context) => const MainScreen()),
                    ),
                  ),
                ),
        ));
  }
}
