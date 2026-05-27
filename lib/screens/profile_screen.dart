// =============================================================
// profile_screen.dart - User stats, badges, settings, theme, AI keys
// =============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_progress_service.dart';
import '../services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _urlCtrl.text = p.getString('ai_url') ?? '';
    _keyCtrl.text = p.getString('ai_key') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final up = context.watch<UserProgressService>();
    final ts = context.watch<ThemeService>();
    _nameCtrl.text = up.username;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Text('🌸', style: TextStyle(fontSize: 48)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(up.username,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('Lv ${up.level}  •  ${up.xp} XP  •  🔥 ${up.streakDays}d'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Badges', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: up.badges.isEmpty
                ? [const Text('No badges yet — keep going!')]
                : up.badges.map((b) => Chip(label: Text(b))).toList(),
          ),
          const Divider(height: 32),
          const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: ts.mode == ThemeMode.dark,
            onChanged: (v) => ts.setMode(v ? ThemeMode.dark : ThemeMode.light),
          ),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
                labelText: 'Display name', border: OutlineInputBorder()),
            onSubmitted: (v) => up.setUsername(v),
          ),
          const SizedBox(height: 18),
          const Text('Optional: AI Chat backend',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
              'Leave blank to use the free offline tutor. Or plug in any OpenAI-compatible endpoint (Groq, Ollama, etc).',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _urlCtrl,
            decoration: const InputDecoration(
                labelText: 'API URL', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keyCtrl,
            obscureText: true,
            decoration: const InputDecoration(
                labelText: 'API key', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              await up.setUsername(_nameCtrl.text);
              final p = await SharedPreferences.getInstance();
              await p.setString('ai_url', _urlCtrl.text.trim());
              await p.setString('ai_key', _keyCtrl.text.trim());
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Saved ✅')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
