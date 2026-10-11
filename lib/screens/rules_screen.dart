import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('How to Play', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _RuleCard(
            step: '1',
            title: 'Pass & Reveal',
            description: 'Pass the device from player to player. Each player presses and holds the card to secretly view their word. Civilians get the same secret word; the Poser gets a closely related word (or nothing).',
          ),
          _RuleCard(
            step: '2',
            title: 'Clue Giving',
            description: 'Going in turn around the circle, each player gives one subtle word or phrase related to their secret word. Be careful not to make it too obvious, or the Poser will guess it!',
          ),
          _RuleCard(
            step: '3',
            title: 'Discussion & Voting',
            description: 'Discuss who gave suspicious clues. Everyone votes on who they suspect is the Poser. The player with the most votes is eliminated.',
          ),
          _RuleCard(
            step: '4',
            title: 'Poser Final Guess',
            description: 'If caught, the Poser gets one final chance to steal victory by guessing the Civilians\' secret word!',
          ),
        ],
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String step;
  final String title;
  final String description;

  const _RuleCard({required this.step, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(description, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
