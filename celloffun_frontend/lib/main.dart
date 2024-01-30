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
                      'Играть',
                      style: Theme.of(context).textTheme.headlineMedium,
                    )))),
          ),
        ),
        // SizedBox(
        //   height: 100,
        //   child: Material(
        //     color: Theme.of(context).cardColor,
        //     child: InkWell(
        //       onTap: () {},
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           const SizedBox(
        //             width: 300,
        //             child: TextField(
        //                 decoration: InputDecoration(
        //                     labelText: 'Подключиться', hintText: '123456')),
        //           ),
        //           IconButton(
        //             onPressed: () {},
        //             icon: const Icon(Icons.rocket_launch_rounded),
        //           )
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
