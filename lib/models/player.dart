class Player {
  final String id;
  final String name;
  bool isImposter;
  bool isUndercover;
  bool isEliminated;
  String? assignedWord;
  int score;

  Player({
    required this.id,
    required this.name,
    this.isImposter = false,
    this.isUndercover = false,
    this.isEliminated = false,
    this.assignedWord,
    this.score = 0,
  });

  Player copyWith({
    String? name,
    bool? isImposter,
    bool? isUndercover,
    bool? isEliminated,
    String? assignedWord,
    int? score,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      isImposter: isImposter ?? this.isImposter,
      isUndercover: isUndercover ?? this.isUndercover,
      isEliminated: isEliminated ?? this.isEliminated,
      assignedWord: assignedWord ?? this.assignedWord,
      score: score ?? this.score,
    );
  }
}
