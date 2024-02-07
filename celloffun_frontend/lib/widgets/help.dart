import 'package:celloffun_frontend/cell.dart';
import 'package:celloffun_frontend/widgets/cell_widget.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Справка'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: SelectionArea(
            child: Text.rich(TextSpan(
                text: 'Целлофан – игра о взаимодействии клеточных автоматов.\n',
                style: Theme.of(context).textTheme.bodyLarge,
                children: [
                  const TextSpan(
                      text:
                          'Для того, чтобы выиграть, нужно продумать свою стратегию, предугадать действия оппонента и остаться с большим числом клеток в конце.\n'),
                  TextSpan(
                      text: 'Всего существует четыре типа клеток:\n',
                      children: [
                        WidgetSpan(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 60,
                            child: Material(
                              color: Theme.of(context).highlightColor,
                              elevation: 1,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  CellWidget(
                                    onTap: () {},
                                    clientId: '',
                                    cell: const Cell(
                                      CellTypes.alive,
                                      owner: '',
                                    ),
                                  ),
                                  CellWidget(
                                    onTap: () {},
                                    clientId: '',
                                    cell: const Cell(
                                      CellTypes.alive,
                                    ),
                                  ),
                                  CellWidget(
                                    onTap: () {},
                                    clientId: '',
                                    cell: const Cell(
                                      CellTypes.dead,
                                    ),
                                  ),
                                  CellWidget(
                                    onTap: () {},
                                    clientId: '',
                                    cell: const Cell(
                                      CellTypes.void_,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ))
                      ]),
                  const TextSpan(text: '• Синие клетки – ваши клетки.\n'),
                  const TextSpan(
                      text: '• Красные клетки – клетки противника.\n'),
                  const TextSpan(
                      text:
                          '• Черные и белые клетки – нейтральные, из них состоит игровое поле.\n'),
                  const TextSpan(
                      text:
                          'Синие и красные клетки живут один ход, а затем автоматически превращаются в белые.\n\n'),
                  const TextSpan(
                      text:
                          '''Во время игры к каждой из клеток поля будут применяться созданные вами правила.
Если некоторый участок поля (3 на 3) в точности совпадет с шаблоном, то центральная клетка этого участка изменит состояние на указанное:'''),
                  WidgetSpan(
                    child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.secondary)),
                          width: 100,
                          height: 100,
                          child: GridView.count(
                            crossAxisCount: 3,
                            children: List.generate(
                                9,
                                (cellIdx) => CellWidget(
                                    onTap: () {},
                                    clientId: '',
                                    cell: switch (cellIdx == 7) {
                                      true =>
                                        const Cell(CellTypes.alive, owner: ''),
                                      _ => const Cell(CellTypes.dead)
                                    })),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_right_alt_rounded,
                        size: 48,
                      ),
                      Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      Theme.of(context).colorScheme.secondary)),
                          child: CellWidget(
                              onTap: () {},
                              clientId: '',
                              cell: const Cell(CellTypes.alive, owner: '')))
                    ]),
                  ),
                  const TextSpan(
                      text:
                          '''Согласно этому правилу, белая клетка станет синей, если снизу от нее уже есть синяя клетка. Это приведет к перемещению клетки вверх (подумайте, почему).\n'''),
                  const TextSpan(text: 'Важные факты о правилах:\n'),
                  const TextSpan(
                      text:
                          '• В шаблоне должна быть как минимум одна синяя клетка.\n'),
                  const TextSpan(
                      text:
                          '• Можно создавать любые клетки – даже клетки противника.\n'),
                  const TextSpan(
                      text: '• Можно создать произвольное количество правил.'),
                ])),
          ),
        ),
      ),
    );
  }
}
