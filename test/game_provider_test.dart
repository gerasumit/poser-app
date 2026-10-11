import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poser/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('GameProvider Tests', () {
    test('Initial state has empty players and setup phase', () async {
      final provider = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.players.length, 0);
      expect(provider.currentPhase, GamePhase.setup);
      expect(provider.imposterCount, 1);
    });

    test('Add and remove players', () async {
      final provider = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      provider.addPlayer('Player 1');
      provider.addPlayer('Player 2');
      provider.addPlayer('Player 3');
      provider.addPlayer('Player 4');
      expect(provider.players.length, 4);
      expect(provider.players.last.name, 'Player 4');

      // Remove one player (4 -> 3)
      provider.removePlayer(provider.players[0].id);
      expect(provider.players.length, 3);

      // Attempting to remove when 3 players should keep 3 (minimum 3)
      provider.removePlayer(provider.players[0].id);
      expect(provider.players.length, 3);
    });

    test('Start game assigns roles and transitions phase', () async {
      final provider = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      provider.addPlayer('Alice');
      provider.addPlayer('Bob');
      provider.addPlayer('Charlie');
      provider.startGame();

      expect(provider.currentPhase, GamePhase.passReveal);
      expect(provider.currentWordPair, isNotNull);

      final imposters = provider.players.where((p) => p.isImposter).toList();
      expect(imposters.length, provider.imposterCount);

      for (var player in provider.players) {
        expect(player.assignedWord, isNotEmpty);
      }
    });

    test('Reveal progression transitions to discussion', () async {
      final provider = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      provider.addPlayer('Alice');
      provider.addPlayer('Bob');
      provider.addPlayer('Charlie');
      provider.startGame();

      final totalPlayers = provider.players.length;
      for (int i = 0; i < totalPlayers - 1; i++) {
        expect(provider.currentPhase, GamePhase.passReveal);
        provider.nextReveal();
      }

      // Last reveal transitions to discussion
      provider.nextReveal();
      expect(provider.currentPhase, GamePhase.discussion);
    });

    test('Eliminate civilian and check win condition', () async {
      final provider = GameProvider();
      await Future.delayed(const Duration(milliseconds: 100));
      provider.addPlayer('Alice');
      provider.addPlayer('Bob');
      provider.addPlayer('Charlie');
      provider.startGame();

      // Find a civilian
      final civilian = provider.players.firstWhere((p) => !p.isImposter);
      provider.eliminatePlayer(civilian.id);

      expect(civilian.isEliminated, isTrue);
      expect(provider.eliminatedPlayerId, civilian.id);
    });
  });
}
