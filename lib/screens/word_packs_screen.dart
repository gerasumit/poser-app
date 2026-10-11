import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/word_pair.dart';

class WordPacksScreen extends StatefulWidget {
  const WordPacksScreen({super.key});

  @override
  State<WordPacksScreen> createState() => _WordPacksScreenState();
}

class _WordPacksScreenState extends State<WordPacksScreen> {
  void _showCreatePackDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final civilianController = TextEditingController();
    final imposterController = TextEditingController();
    final List<WordPair> pairs = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text('Create Custom Pack', style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Pack Name',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.white60),
                        ),
                      ),
                      const Divider(height: 30, color: Colors.white24),
                      const Text('Add Word Pairs', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: civilianController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(hintText: 'Civilian Word', hintStyle: TextStyle(color: Colors.white38)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: imposterController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(hintText: 'Imposter Word', hintStyle: TextStyle(color: Colors.white38)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Color(0xFF8B5CF6)),
                            onPressed: () {
                              if (civilianController.text.isNotEmpty && imposterController.text.isNotEmpty) {
                                setDialogState(() {
                                  pairs.add(WordPair(
                                    civilianWord: civilianController.text.trim(),
                                    imposterWord: imposterController.text.trim(),
                                  ));
                                  civilianController.clear();
                                  imposterController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          itemCount: pairs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              title: Text(
                                '${pairs[index].civilianWord} / ${pairs[index].imposterWord}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                                onPressed: () {
                                  setDialogState(() {
                                    pairs.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && pairs.isNotEmpty) {
                      Provider.of<GameProvider>(context, listen: false)
                          .saveCustomPack(nameController.text, descController.text, pairs);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6)),
                  child: const Text('Save Pack', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Word Packs', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreatePackDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: gameProvider.wordPacks.length,
        itemBuilder: (context, index) {
          final pack = gameProvider.wordPacks[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                Text(pack.icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(pack.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          if (pack.isCustom) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Custom', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(pack.description, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('${pack.pairs.length} word pairs', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: pack.isEnabled,
                  activeColor: const Color(0xFF8B5CF6),
                  onChanged: (val) {
                    gameProvider.toggleWordPack(pack.id);
                  },
                ),
                if (pack.isCustom)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => gameProvider.deleteCustomPack(pack.id),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
