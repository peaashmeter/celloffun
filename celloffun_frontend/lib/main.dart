import 'package:celloffun_frontend/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final TextEditingController nameController;

  @override
  void initState() {
    nameController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text('Целлофан', style: Theme.of(context).textTheme.displayLarge),
              const Text(
                'Битва клеточных автоматов',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
              width: 300,
              child: TextField(
                  controller: nameController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                      labelText: 'Имя', hintText: 'Например, Олег'))),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            height: 100,
            child: Material(
                color: Theme.of(context).cardColor,
                child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SessionScreen(
                          name: nameController.text,
                        ),
                      ));
                    },
                    child: Center(
                        child: Text(
                      'Создать игру',
                      style: Theme.of(context).textTheme.headlineMedium,
                    )))),
          ),
        ),
        const Center(
          child: Text('или'),
        ),
        Builder(builder: (context) {
          final controller = TextEditingController();

          return SizedBox(
            height: 100,
            width: 300,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Подключиться', hintText: '123456')),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SessionScreen(
                        name: nameController.text,
                        sessionId: controller.text,
                      ),
                    ));
                  },
                  icon: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.red,
                  ),
                )
              ],
            ),
          );
        }),
      ],
    );
  }
}
