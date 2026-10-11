import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/player.dart';
import '../models/word_pair.dart';
import '../models/word_pack.dart';
import '../data/default_word_packs.dart';

enum GamePhase {
  setup,
  passReveal,
  discussion,
  voting,
  imposterGuess,
  gameOver,
}

class GameProvider extends ChangeNotifier {
  List<Player> players = [];

  int imposterCount = 1;
  int discussionTimeSeconds = 90;
  bool useUndercover = false;

  List<WordPack> wordPacks = DefaultWordPacks.getPacks();
  
  GamePhase currentPhase = GamePhase.setup;
  
  // Current Round State
  WordPair? currentWordPair;
  int currentRevealIndex = 0;
  String? eliminatedPlayerId;
  String? winningTeam; // 'civilians', 'imposters'
  String? imposterSecretGuess;

  GameProvider() {
    loadCustomPacks();
  }

  int _playerCounter = 0;

  void addPlayer(String name) {
    if (name.trim().isEmpty) return;
    _playerCounter++;
    final newPlayer = Player(
      id: '${DateTime.now().millisecondsSinceEpoch}_$_playerCounter',
      name: name.trim(),
    );
    players.add(newPlayer);
    notifyListeners();
  }

  void removePlayer(String id) {
    if (players.length <= 3) return; // Minimum 3 players required
    players.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void updatePlayerName(String id, String name) {
    final player = players.firstWhere((p) => p.id == id);
    player.score; // just access
    final index = players.indexWhere((p) => p.id == id);
    if (index != -1) {
      players[index] = players[index].copyWith(name: name);
      notifyListeners();
    }
  }

  void setImposterCount(int count) {
    imposterCount = count;
    notifyListeners();
  }

  void setDiscussionTime(int seconds) {
    discussionTimeSeconds = seconds;
    notifyListeners();
  }

  void toggleUndercover(bool value) {
    useUndercover = value;
    notifyListeners();
  }

  void toggleWordPack(String packId) {
    final pack = wordPacks.firstWhere((p) => p.id == packId);
    pack.isEnabled = !pack.isEnabled;
    notifyListeners();
  }

  Future<void> loadCustomPacks() async {
    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getString('custom_word_packs');
    if (customJson != null) {
      try {
        final List decoded = jsonDecode(customJson);
        for (var item in decoded) {
          final pack = WordPack.fromJson(item);
          if (!wordPacks.any((p) => p.id == pack.id)) {
            wordPacks.add(pack);
          }
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading custom packs: $e');
      }
    }
  }

  Future<void> saveCustomPack(String name, String description, List<WordPair> pairs) async {
    final newPack = WordPack(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      icon: '⭐',
      pairs: pairs,
      isCustom: true,
      isEnabled: true,
    );
    wordPacks.add(newPack);
    await _persistCustomPacks();
    notifyListeners();
  }

  Future<void> deleteCustomPack(String id) async {
    wordPacks.removeWhere((p) => p.id == id && p.isCustom);
    await _persistCustomPacks();
    notifyListeners();
  }

  Future<void> _persistCustomPacks() async {
    final prefs = await SharedPreferences.getInstance();
    final customPacks = wordPacks.where((p) => p.isCustom).map((p) => p.toJson()).toList();
    await prefs.setString('custom_word_packs', jsonEncode(customPacks));
  }

  void startGame() {
    // Select enabled word packs
    final enabledPacks = wordPacks.where((p) => p.isEnabled && p.pairs.isNotEmpty).toList();
    if (enabledPacks.isEmpty) return;

    // Pick random pack and random word pair
    final randomPack = enabledPacks[Random().nextInt(enabledPacks.length)];
    currentWordPair = randomPack.pairs[Random().nextInt(randomPack.pairs.length)];

    // Reset player roles
    for (var p in players) {
      p.isImposter = false;
      p.isUndercover = false;
      p.isEliminated = false;
      p.assignedWord = currentWordPair!.civilianWord;
    }

    // Assign imposters randomly
    final shuffledIndices = List.generate(players.length, (i) => i)..shuffle();
    int assignedImposters = 0;
    
    for (int i = 0; i < min(imposterCount, players.length); i++) {
      players[shuffledIndices[i]].isImposter = true;
      players[shuffledIndices[i]].assignedWord = currentWordPair!.imposterWord;
      assignedImposters++;
    }

    // Optional Undercover assignment if enabled and enough players
    if (useUndercover && players.length - assignedImposters >= 2) {
      for (int i = assignedImposters; i < shuffledIndices.length; i++) {
        if (!players[shuffledIndices[i]].isImposter) {
          players[shuffledIndices[i]].isUndercover = true;
          // Undercover gets a slight variation or imposter word depending on preference
          break;
        }
      }
    }

    currentRevealIndex = 0;
    eliminatedPlayerId = null;
    winningTeam = null;
    imposterSecretGuess = null;
    currentPhase = GamePhase.passReveal;
    notifyListeners();
  }

  void nextReveal() {
    if (currentRevealIndex < players.length - 1) {
      currentRevealIndex++;
      notifyListeners();
    } else {
      currentPhase = GamePhase.discussion;
      notifyListeners();
    }
  }

  void eliminatePlayer(String playerId) {
    final player = players.firstWhere((p) => p.id == playerId);
    player.isEliminated = true;
    eliminatedPlayerId = playerId;

    if (player.isImposter) {
      // Imposter caught! Check if they can guess the secret word
      currentPhase = GamePhase.imposterGuess;
    } else {
      // Civilian eliminated! Check if imposters win
      checkWinCondition();
    }
    notifyListeners();
  }

  void submitImposterGuess(String guess) {
    imposterSecretGuess = guess;
    if (currentWordPair != null &&
        guess.trim().toLowerCase() == currentWordPair!.civilianWord.toLowerCase()) {
      // Imposter stole the win by guessing the secret word!
      winningTeam = 'imposters';
      for (var p in players) {
        if (p.isImposter) p.score += 3;
      }
    } else {
      // Incorrect guess, Civilians win!
      winningTeam = 'civilians';
      for (var p in players) {
        if (!p.isImposter) p.score += 2;
      }
    }
    currentPhase = GamePhase.gameOver;
    notifyListeners();
  }

  void skipImposterGuess() {
    winningTeam = 'civilians';
    for (var p in players) {
      if (!p.isImposter) p.score += 2;
    }
    currentPhase = GamePhase.gameOver;
    notifyListeners();
  }

  void checkWinCondition() {
    final activeImposters = players.where((p) => p.isImposter && !p.isEliminated).length;
    final activeCivilians = players.where((p) => !p.isImposter && !p.isEliminated).length;

    if (activeImposters == 0) {
      winningTeam = 'civilians';
      for (var p in players) {
        if (!p.isImposter) p.score += 2;
      }
      currentPhase = GamePhase.gameOver;
    } else if (activeImposters >= activeCivilians) {
      winningTeam = 'imposters';
      for (var p in players) {
        if (p.isImposter) p.score += 3;
      }
      currentPhase = GamePhase.gameOver;
    } else {
      // Continue discussion/voting round
      currentPhase = GamePhase.discussion;
    }
    notifyListeners();
  }

  void returnToSetup() {
    currentPhase = GamePhase.setup;
    notifyListeners();
  }
}
