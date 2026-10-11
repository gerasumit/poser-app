class WordPair {
  final String civilianWord;
  final String imposterWord;

  WordPair({
    required this.civilianWord,
    required this.imposterWord,
  });

  Map<String, dynamic> toJson() => {
        'civilianWord': civilianWord,
        'imposterWord': imposterWord,
      };

  factory WordPair.fromJson(Map<String, dynamic> json) => WordPair(
        civilianWord: json['civilianWord'],
        imposterWord: json['imposterWord'],
      );
}
