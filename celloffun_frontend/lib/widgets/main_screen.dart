import 'package:celloffun_frontend/main.dart';
import 'package:celloffun_frontend/session.dart';
import 'package:celloffun_frontend/widgets/help.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
        const Spacer(),
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
                  controller: nameController
                    ..text = InheritedName.of(context).name ?? '',
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
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpScreen(),
                        ));
                  },
                  child: const Text('Как играть')),
              TextButton(
                  onPressed: () {
                    launchUrlString('https://github.com/peaashmeter/celloffun');
                  },
                  child: const Text('Исходный код'))
            ],
          ),
        )
      ],
    );
  }
}
