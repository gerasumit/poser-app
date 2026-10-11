import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';

class GameFlowScreen extends StatelessWidget {
  const GameFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        switch (provider.currentPhase) {
          case GamePhase.passReveal:
            return const PassRevealWidget();
          case GamePhase.discussion:
            return const DiscussionWidget();
          case GamePhase.voting:
            return const VotingWidget();
          case GamePhase.imposterGuess:
            return const PoserGuessWidget();
          case GamePhase.gameOver:
            return const GameOverWidget();
          default:
            return const HomeScreen();
        }
      },
    );
  }
}

class PassRevealWidget extends StatefulWidget {
  const PassRevealWidget({super.key});

  @override
  State<PassRevealWidget> createState() => _PassRevealWidgetState();
}

class _PassRevealWidgetState extends State<PassRevealWidget> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final player = provider.players[provider.currentRevealIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Player ${provider.currentRevealIndex + 1} of ${provider.players.length}',
                style: TextStyle(color: Colors.white.withOpacity(0.5), letterSpacing: 1.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Pass phone to',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                player.name,
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 40),
              // Hold to reveal card
              GestureDetector(
                onTapDown: (_) => setState(() => _isRevealed = true),
                onTapUp: (_) => setState(() => _isRevealed = false),
                onTapCancel: () => setState(() => _isRevealed = false),
                child: Container(
                  width: double.infinity,
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isRevealed
                          ? [const Color(0xFF8B5CF6), const Color(0xFFEC4899)]
                          : [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.04)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: Center(
                    child: _isRevealed
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('YOUR SECRET WORD', style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1.5)),
                              const SizedBox(height: 12),
                              Text(
                                player.assignedWord ?? '',
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              if (player.isImposter) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                  child: const Text('🕵️‍♂️ You are the Poser!', style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fingerprint_rounded, size: 64, color: Colors.white.withOpacity(0.7)),
                              const SizedBox(height: 16),
                              const Text('Press & Hold to Reveal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Make sure nobody else is looking!', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                            ],
                          ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isRevealed = false);
                    provider.nextReveal();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('NEXT PLAYER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscussionWidget extends StatelessWidget {
  const DiscussionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Color(0xFF38BDF8)),
              const SizedBox(height: 24),
              const Text('Discussion Phase', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Give one clue in turn order. Discuss and figure out who has a different word!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    const Text('Active Players', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.players.where((p) => !p.isEliminated).map((p) {
                        return Chip(
                          backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                          label: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Switch to voting phase
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VotingWidget()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('PROCEED TO VOTE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VotingWidget extends StatelessWidget {
  const VotingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Accusation Vote', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who do you suspect is the Poser?', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.players.where((p) => !p.isEliminated).length,
                itemBuilder: (context, index) {
                  final activePlayers = provider.players.where((p) => !p.isEliminated).toList();
                  final player = activePlayers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: ListTile(
                      title: Text(player.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VotingSuspenseScreen(
                                playerId: player.id,
                                playerName: player.name,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
                        child: const Text('ACCUSE'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VotingSuspenseScreen extends StatefulWidget {
  final String playerId;
  final String playerName;

  const VotingSuspenseScreen({super.key, required this.playerId, required this.playerName});

  @override
  State<VotingSuspenseScreen> createState() => _VotingSuspenseScreenState();
}

class _VotingSuspenseScreenState extends State<VotingSuspenseScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Sequence suspense messages
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _step = 1);
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _step = 2);
    });
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final provider = Provider.of<GameProvider>(context, listen: false);
      provider.eliminatePlayer(widget.playerId);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameFlowScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = [
      'Gathering ballots...',
      'Analyzing suspicion against ${widget.playerName}...',
      'Revealing verdict...',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _controller,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B5CF6).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.how_to_vote_rounded, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Tallying Votes',
                style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  messages[_step],
                  key: ValueKey<int>(_step),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
                ),
              ),
              const SizedBox(height: 32),
              const LinearProgressIndicator(
                backgroundColor: Color(0x22FFFFFF),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PoserGuessWidget extends StatelessWidget {
  const PoserGuessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final TextEditingController guessController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.yellowAccent),
              const SizedBox(height: 24),
              const Text('Poser Caught!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('The accused player was indeed a Poser! However, they get one final chance to steal victory by guessing the secret civilian word.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 32),
              TextField(
                controller: guessController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter secret word guess...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    provider.submitImposterGuess(guessController.text);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                  child: const Text('SUBMIT GUESS', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => provider.skipImposterGuess(),
                child: const Text('Skip / Give Up', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameOverWidget extends StatelessWidget {
  const GameOverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GameProvider>(context);
    final isCiviliansWin = provider.winningTeam == 'civilians';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCiviliansWin ? Icons.verified_rounded : Icons.local_police_rounded,
                size: 80,
                color: isCiviliansWin ? const Color(0xFF34D399) : const Color(0xFFEC4899),
              ),
              const SizedBox(height: 20),
              Text(
                isCiviliansWin ? 'CIVILIANS WIN!' : 'POSERS WIN!',
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Column(
                  children: [
                    const Text('Secret Words Reveal', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Civilian Word: ${provider.currentWordPair?.civilianWord}', style: const TextStyle(color: Color(0xFF34D399), fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Poser Word: ${provider.currentWordPair?.imposterWord}', style: const TextStyle(color: Color(0xFFEC4899), fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.players.length,
                  itemBuilder: (context, index) {
                    final p = provider.players[index];
                    return ListTile(
                      title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(p.isImposter ? 'Poser' : 'Civilian', style: TextStyle(color: p.isImposter ? const Color(0xFFEC4899) : const Color(0xFF34D399))),
                      trailing: Text('${p.score} pts', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    provider.returnToSetup();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
                  child: const Text('PLAY AGAIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
