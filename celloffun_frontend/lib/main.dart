import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'widgets/main_screen.dart';

void main() {
  usePathUrlStrategy();
  runApp(const App());
}

class App extends StatelessWidget {
  final String? name;
  const App({super.key, this.name});

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
        home: InheritedName(
          name,
          child: Scaffold(
            body: size.width < maxWidth
                ? const MainScreen()
                : const Center(
                    child: SizedBox(
                      width: maxWidth,
                      child: WideScreenNavigator(),
                    ),
                  ),
          ),
        ));
  }
}

class WideScreenNavigator extends StatelessWidget {
  const WideScreenNavigator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (route) =>
          MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }
}

class InheritedName extends InheritedWidget {
  final String? name;

  const InheritedName(this.name, {super.key, required super.child});

  @override
  bool updateShouldNotify(InheritedName oldWidget) => name != oldWidget.name;

  static InheritedName of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedName>()!;
}
