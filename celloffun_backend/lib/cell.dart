sealed class Cell {
  const Cell();

  factory Cell.fromJson(json) {
    return switch (json['type']) {
      'dead' => const DeadCell(),
      'alive' => AliveCell(owner: json['owner']),
      _ => const Void()
    };
  }

  Map toJson();
}

class DeadCell extends Cell {
  const DeadCell();
  @override
  Map toJson() => {'type': 'dead'};
}

class AliveCell extends Cell {
  final String owner;
  final int age;

  const AliveCell({required this.owner, this.age = 0});

  @override
  Map toJson() => {'type': 'alive', 'owner': owner};

  @override
  int get hashCode => owner.hashCode;

  @override
  bool operator ==(Object other) {
    return other is AliveCell && other.owner == owner;
  }

  Cell olden() {
    if (age == 0) {
      return AliveCell(owner: owner, age: age + 1);
    } else {
      return const DeadCell();
    }
  }
}

class Void extends Cell {
  const Void();

  @override
  Map toJson() => {'type': 'void'};
}
