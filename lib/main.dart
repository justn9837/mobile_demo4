// Full single-file Flutter app (fixed).
// Replace your project's main.dart with this file.
// Fixes: Timer import/management, replaced some _route(...) calls that caused "method not found"
// errors by using MaterialPageRoute; removed unused top-level _route; preserved animations & UI.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MoodTrackerApp());

/* ===========================
   Models & In-memory storage
   =========================== */

class User {
  final String username;
  final String name;
  final int age;
  final String major;
  final String email;
  final String password;

  User({
    required this.username,
    required this.name,
    required this.age,
    required this.major,
    required this.email,
    required this.password,
  });
}

class JournalEntry {
  final String username;
  final String mood;
  final int stressLevel;
  final String note;
  final DateTime timestamp;

  JournalEntry({
    required this.username,
    required this.mood,
    required this.stressLevel,
    required this.note,
    required this.timestamp,
  });
}

class InMemoryService {
  static final List<User> _users = [
    User(username: 'Rofika', name: 'Rofika (Dosen)', age: 40, major: 'Psikologi', email: 'rofika@univ.edu', password: 'rofika12'),
    User(username: 'lira', name: 'Lira Aurora', age: 22, major: 'Teknik Informatika', email: 'lira@example.com', password: 'liralira'),
  ];

  static final Map<String, List<JournalEntry>> _entries = {};

  static User? login(String username, String password) {
    try {
      return _users.firstWhere((u) => u.username == username && u.password == password);
    } catch (_) {
      return null;
    }
  }

  static bool register(User u) {
    if (_users.any((x) => x.username == u.username)) return false;
    _users.add(u);
    return true;
  }

  static User? getByUsername(String username) {
    try {
      return _users.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  static List<User> allUsers() => List.unmodifiable(_users);

  static List<JournalEntry> entriesFor(String username) => List.unmodifiable(_entries[username] ?? []);

  static void saveEntry(JournalEntry e) {
    final list = _entries.putIfAbsent(e.username, () => []);
    list.add(e);
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}

/* ===========================
   App bootstrap
   =========================== */

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodTracker & Stress Level',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

/* ===========================
   Login & Register
   =========================== */

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  late AnimationController _bgController;
  late Animation<Alignment> _beginAnim;
  late Animation<Alignment> _endAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _beginAnim = AlignmentTween(begin: Alignment.topLeft, end: const Alignment(-0.3, -1)).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _endAnim = AlignmentTween(begin: Alignment.bottomRight, end: const Alignment(0.8, 1)).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final u = _usernameCtrl.text.trim();
    final p = _passwordCtrl.text;
    final user = InMemoryService.login(u, p);
    if (user == null) {
      showDialog(context: context, builder: (c) => AlertDialog(title: const Text('Login gagal'), content: const Text('Username/Password salah atau belum terdaftar.'), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Tutup'))]));
      return;
    }

    final route = PageRouteBuilder(
      pageBuilder: (_, anim, __) => user.username == 'Rofika' ? DosenHomePage(username: user.username) : UserHomePage(user: user),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 450),
    );

    Navigator.pushReplacement(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final titleSize = w > 420 ? 34.0 : 24.0;

    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _beginAnim.value,
                end: _endAnim.value,
                colors: [
                  Colors.indigo.shade600,
                  Colors.deepPurple.shade400,
                  Colors.teal.shade200,
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(tag: 'app-logo', child: _buildLogoBig()),
                      const SizedBox(height: 12),
                      Text('MoodTracker & Stress', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 18),
                      _buildAuthCard(context),
                      const SizedBox(height: 12),
                      Text('Dosen: Rofika / rofika12 • Contoh user: lira / liralira',
                          style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoBig() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 10)],
      ),
      child: Icon(Icons.mood, size: 56, color: Colors.white),
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(children: [
          TextField(controller: _usernameCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'Username')),
          const SizedBox(height: 12),
          TextField(controller: _passwordCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Password'), obscureText: true),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Login', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              width: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, PageRouteBuilder(pageBuilder: (_, anim, __) => ScaleTransition(scale: anim, child: const RegisterPage()), transitionDuration: const Duration(milliseconds: 420))),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent, shape: const CircleBorder(), elevation: 6),
                child: const Icon(Icons.arrow_forward, color: Colors.white),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('Belum punya akun?'),
            TextButton(onPressed: () => Navigator.push(context, PageRouteBuilder(pageBuilder: (_, anim, __) => ScaleTransition(scale: anim, child: const RegisterPage()), transitionDuration: const Duration(milliseconds: 420))), child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold))),
          ]),
        ]),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _u = TextEditingController();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _major = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  late AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _u.dispose();
    _name.dispose();
    _age.dispose();
    _major.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_form.currentState!.validate()) return;
    final u = User(
      username: _u.text.trim(),
      name: _name.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? 0,
      major: _major.text.trim(),
      email: _email.text.trim(),
      password: _pass.text,
    );
    final ok = InMemoryService.register(u);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username sudah ada')));
      return;
    }
    Navigator.pushAndRemoveUntil(context, PageRouteBuilder(pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: UserHomePage(user: u)), transitionDuration: const Duration(milliseconds: 420)), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _entrance, curve: Curves.easeOutBack),
      child: Scaffold(
        appBar: AppBar(title: const Text('Daftar Akun'), backgroundColor: Colors.indigo),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _form,
                  child: Column(children: [
                    TextFormField(controller: _u, decoration: const InputDecoration(labelText: 'Username'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Masukkan username' : null),
                    const SizedBox(height: 10),
                    TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nama lengkap'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Masukkan nama' : null),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(child: TextFormField(controller: _age, decoration: const InputDecoration(labelText: 'Usia'), keyboardType: TextInputType.number, validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Masukkan usia';
                        if (int.tryParse(v) == null) return 'Usia tidak valid';
                        return null;
                      })),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _major, decoration: const InputDecoration(labelText: 'Jurusan'))),
                    ]),
                    const SizedBox(height: 10),
                    TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Masukkan email';
                      if (!v.contains('@')) return 'Email tidak valid';
                      return null;
                    }),
                    const SizedBox(height: 10),
                    TextFormField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password'), validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: _onRegister, style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), child: const Text('Daftar & Lanjutkan')),
                    )
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================
   User Home (colorful + animated)
   =========================== */

class UserHomePage extends StatefulWidget {
  final User user;
  const UserHomePage({super.key, required this.user});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> with TickerProviderStateMixin {
  int selectedMoodIndex = -1;
  int stressValue = 5;
  final _journalCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();

  late AnimationController _mistController;
  late AnimationController _entranceController;

  final List<Map<String, dynamic>> moods = [
    {'name': 'Happy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.orange},
    {'name': 'Calm', 'icon': Icons.self_improvement, 'color': Colors.teal},
    {'name': 'Focused', 'icon': Icons.psychology, 'color': Colors.indigo},
    {'name': 'Sad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.blueGrey},
    {'name': 'Tired', 'icon': Icons.bedtime, 'color': Colors.amber},
    {'name': 'Anxious', 'icon': Icons.sentiment_neutral, 'color': Colors.pinkAccent},
    {'name': 'Excited', 'icon': Icons.flash_on, 'color': Colors.deepOrangeAccent},
    {'name': 'Playful', 'icon': Icons.emoji_emotions, 'color': Colors.deepPurpleAccent},
    {'name': 'Grateful', 'icon': Icons.favorite, 'color': Colors.redAccent},
    {'name': 'Relaxed', 'icon': Icons.beach_access, 'color': Colors.lightBlueAccent},
    {'name': 'Motivated', 'icon': Icons.trending_up, 'color': Colors.green},
    {'name': 'Bored', 'icon': Icons.hourglass_empty, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _mistController = AnimationController(vsync: this, duration: const Duration(seconds: 9))..repeat(reverse: true);
    _entranceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
  }

  @override
  void dispose() {
    _mistController.dispose();
    _entranceController.dispose();
    _journalCtrl.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final p = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (p != null) setState(() => selectedDate = p);
  }

  void _saveEntry() {
    final mood = selectedMoodIndex >= 0 ? moods[selectedMoodIndex]['name'] as String : 'Unspecified';
    final entry = JournalEntry(
      username: widget.user.username,
      mood: mood,
      stressLevel: stressValue,
      note: _journalCtrl.text.trim(),
      timestamp: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, DateTime.now().hour, DateTime.now().minute),
    );
    InMemoryService.saveEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entri tersimpan ke kalender')));
    setState(() {});
  }

  Future<void> _openMoodGallery({int initialIndex = 0}) async {
    final idx = await Navigator.push<int>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, sec) => FadeTransition(opacity: anim, child: MoodGalleryPage(moods: moods, initialIndex: initialIndex)),
        transitionDuration: const Duration(milliseconds: 420),
      ),
    );
    if (idx != null) {
      setState(() => selectedMoodIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = InMemoryService.entriesFor(widget.user.username);
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 740;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home - ${widget.user.name}'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            onPressed: () {
              // fixed: use MaterialPageRoute to push UserProfilePage (avoid method resolution issues)
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfilePage(user: widget.user)));
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Stack(
        children: [
          // animated blobs background
          AnimatedBuilder(
            animation: _mistController,
            builder: (context, _) {
              final move = sin(_mistController.value * 2 * pi) * 40;
              return Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF7FAFF), Color(0xFFFFFBF6)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                  child: Stack(children: [
                    Positioned(top: 40 + move, left: 20 - move, child: _blob(170, Colors.purple.withOpacity(0.12))),
                    Positioned(bottom: 80 - move, right: 30 + move, child: _blob(220, Colors.teal.withOpacity(0.12))),
                  ]),
                ),
              );
            },
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(children: [
                ScaleTransition(
                  scale: CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Row(children: [
                          const Icon(Icons.emoji_people, color: Colors.indigo),
                          const SizedBox(width: 8),
                          const Text('Catat Mood & Stress', style: TextStyle(fontWeight: FontWeight.w800)),
                          const Spacer(),
                          ElevatedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_today, size: 16), label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'), style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10))),
                        ]),
                        const SizedBox(height: 12),

                        // mood preview grid (tap to open gallery)
                        LayoutBuilder(builder: (context, constraints) {
                          final cross = isWide ? 3 : 2;
                          return SizedBox(
                            height: isWide ? 220 : 240,
                            child: GridView.builder(
                              itemCount: min(6, moods.length),
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cross, childAspectRatio: 3.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
                              itemBuilder: (c, i) {
                                final m = moods[i];
                                final active = selectedMoodIndex == i;
                                return GestureDetector(
                                  onTap: () => _openMoodGallery(initialIndex: i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 360),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(active ? 18 : 12),
                                      gradient: active ? LinearGradient(colors: [m['color'] as Color, (m['color'] as Color).withOpacity(0.9)]) : LinearGradient(colors: [(m['color'] as Color).withOpacity(0.12), Colors.white]),
                                      boxShadow: [if (active) BoxShadow(color: (m['color'] as Color).withOpacity(0.22), blurRadius: 12, offset: const Offset(0, 8))],
                                      border: Border.all(color: Colors.white.withOpacity(0.6)),
                                    ),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Icon(m['icon'] as IconData, color: active ? Colors.white : (m['color'] as Color), size: active ? 30 : 24),
                                      const SizedBox(width: 10),
                                      Text(m['name'] as String, style: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w700)),
                                    ]),
                                  ),
                                );
                              },
                            ),
                          );
                        }),

                        const SizedBox(height: 8),
                        Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => _openMoodGallery(initialIndex: 0), icon: const Icon(Icons.grid_view), label: const Text('Lihat Semua Mood'))),

                        const SizedBox(height: 6),
                        Text('Stress level: $stressValue', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Slider(value: stressValue.toDouble(), min: 0, max: 10, divisions: 10, label: stressValue.toString(), onChanged: (v) => setState(() => stressValue = v.round())),
                        const SizedBox(height: 8),
                        TextField(controller: _journalCtrl, maxLines: 4, decoration: InputDecoration(hintText: 'Tulis catatan harian singkat...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                        const SizedBox(height: 12),

                        Row(children: [
                          Expanded(
                            child: ElevatedButton.icon(onPressed: _saveEntry, icon: const Icon(Icons.save), label: const Text('Simpan ke Kalender'), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => DailyJournalPage(initialText: _journalCtrl.text, username: widget.user.username)));
                              },
                              icon: const Icon(Icons.note),
                              label: const Text('Buka Jurnal'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserCalendarPage(username: widget.user.username))), child: const Text('Lihat Kalender Riwayat'))),
                      ]),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Ringkasan Terbaru', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (entries.isEmpty)
                        Padding(padding: const EdgeInsets.symmetric(vertical: 18.0), child: Text('Kosong - belum ada entri', style: TextStyle(color: Colors.grey.shade700)))
                      else ...[
                        Text('${entries.last.mood} • Stress ${entries.last.stressLevel}/10', style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(entries.last.note.isEmpty ? '(tidak ada catatan)' : entries.last.note),
                        const SizedBox(height: 8),
                        const Divider(),
                        const Text('Riwayat singkat (terakhir 5 entri):', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: min(5, entries.length),
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (c, i) {
                              final e = entries.reversed.toList()[i];
                              return ListTile(
                                leading: CircleAvatar(child: Text(e.mood.isNotEmpty ? e.mood[0] : 'M')),
                                title: Text('${e.mood} • Stress ${e.stressLevel}/10'),
                                subtitle: Text(e.note.isEmpty ? '(tidak ada catatan)' : e.note, maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: Text('${e.timestamp.day}/${e.timestamp.month}'),
                                onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: Text('${e.mood}'), content: Text('${e.note}\n\n${e.timestamp}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))])),
                              );
                            },
                          ),
                        )
                      ],
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginPage(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)), (r) => false);
  }

  static Widget _blob(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent])));

}

/* ===========================
   Mood Gallery (full-screen)
   =========================== */

class MoodGalleryPage extends StatefulWidget {
  final List<Map<String, dynamic>> moods;
  final int initialIndex;
  const MoodGalleryPage({super.key, required this.moods, this.initialIndex = 0});

  @override
  State<MoodGalleryPage> createState() => _MoodGalleryPageState();
}

class _MoodGalleryPageState extends State<MoodGalleryPage> with TickerProviderStateMixin {
  late int selected;
  late AnimationController _floatController;
  late AnimationController _stagger;

  @override
  void initState() {
    super.initState();
    selected = widget.initialIndex;
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _stagger = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _stagger.dispose();
    super.dispose();
  }

  void _select(int idx) => Navigator.pop(context, idx);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cross = width < 600 ? 2 : width < 900 ? 3 : 4;

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Mood'), backgroundColor: Colors.indigo, actions: [IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))]),
      body: AnimatedBuilder(
        animation: _floatController,
        builder: (context, _) {
          final lift = sin(_floatController.value * 2 * pi) * 6;
          return Container(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFF3F8FF), Color(0xFFFFF8F4)])),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: widget.moods.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cross, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6),
                itemBuilder: (c, i) {
                  final m = widget.moods[i];
                  final active = selected == i;
                  final anim = CurvedAnimation(parent: _stagger, curve: Interval((i / widget.moods.length).clamp(0.0, 1.0), 1.0, curve: Curves.easeOut));
                  return FadeTransition(
                    opacity: anim,
                    child: Transform.translate(
                      offset: Offset(0, active ? lift : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => selected = i);
                          Future.delayed(const Duration(milliseconds: 140), () => _select(i));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(active ? 18 : 12),
                            gradient: active ? LinearGradient(colors: [m['color'] as Color, (m['color'] as Color).withOpacity(0.9)]) : LinearGradient(colors: [(m['color'] as Color).withOpacity(0.1), Colors.white]),
                            boxShadow: [BoxShadow(color: (m['color'] as Color).withOpacity(active ? 0.2 : 0.06), blurRadius: active ? 14 : 6, offset: const Offset(0, 6))],
                            border: Border.all(color: Colors.white.withOpacity(0.6)),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(m['icon'] as IconData, size: active ? 34 : 28, color: active ? Colors.white : (m['color'] as Color)),
                            const SizedBox(width: 12),
                            Text(m['name'] as String, style: TextStyle(fontSize: active ? 16 : 14, fontWeight: FontWeight.w800, color: active ? Colors.white : Colors.black87)),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ===========================
   User profile, calendar, journal
   =========================== */

class UserProfilePage extends StatelessWidget {
  final User user;
  const UserProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Pengguna'), backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Hero(tag: 'app-logo', child: CircleAvatar(radius: 46, child: Text(user.name.isNotEmpty ? user.name[0] : 'U', style: const TextStyle(fontSize: 36)))),
          const SizedBox(height: 12),
          Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Column(children: [
            _infoRow('Username', user.username),
            _infoRow('Nama', user.name),
            _infoRow('Usia', '${user.age}'),
            _infoRow('Jurusan', user.major),
            _infoRow('Email', user.email),
          ]))),
        ]),
      ),
    );
  }
}

class UserCalendarPage extends StatelessWidget {
  final String username;
  const UserCalendarPage({super.key, required this.username});

  List<DateTime> _daysInMonth(DateTime date) {
    final first = DateTime(date.year, date.month, 1);
    final next = DateTime(date.year, date.month + 1, 1);
    return List.generate(next.difference(first).inDays, (i) => DateTime(date.year, date.month, i + 1));
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = _daysInMonth(now);
    final Map<String, List<JournalEntry>> map = {};
    final list = InMemoryService.entriesFor(username);
    for (var e in list) {
      final key = '${e.timestamp.year}-${e.timestamp.month.toString().padLeft(2, '0')}-${e.timestamp.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(e);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Riwayat'), backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Text('Bulan: ${now.month}/${now.year}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, crossAxisSpacing: 6, mainAxisSpacing: 6),
              itemBuilder: (c, i) {
                final d = days[i];
                final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                final has = map.containsKey(key);
                final entries = map[key] ?? [];
                return GestureDetector(
                  onTap: has
                      ? () {
                          showModalBottomSheet(context: context, builder: (_) {
                            return ListView(padding: const EdgeInsets.all(12), children: entries.map((e) => ListTile(leading: CircleAvatar(child: Text(e.mood.isNotEmpty ? e.mood[0] : 'M')), title: Text('${e.mood} • Stress ${e.stressLevel}/10'), subtitle: Text(e.note.isEmpty ? '(tidak ada catatan)' : e.note))).toList());
                          });
                        }
                      : null,
                  child: Container(
                    decoration: BoxDecoration(color: has ? Colors.teal.withOpacity(0.9) : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('${d.day}', style: TextStyle(color: has ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)), if (has) const SizedBox(height: 6), if (has) const Icon(Icons.circle, size: 8, color: Colors.white)])),
                  ),
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}

/* ===========================
   Colorful Daily Journal (fixed Timer usage)
   =========================== */

class DailyJournalPage extends StatefulWidget {
  final String initialText;
  final String? username; // optional -> if provided will save to InMemoryService
  final int initialStress;
  final int? initialMoodIndex;

  const DailyJournalPage({
    super.key,
    this.initialText = '',
    this.username,
    this.initialStress = 5,
    this.initialMoodIndex,
  });

  @override
  State<DailyJournalPage> createState() => _DailyJournalPageState();
}

class _DailyJournalPageState extends State<DailyJournalPage> with TickerProviderStateMixin {
  late TextEditingController _ctrl;
  late AnimationController _bgController;
  late AnimationController _floatController;
  late AnimationController _saveAnimController;

  int _stress = 5;
  int? _selectedMood;
  Color _paperColor = Colors.white;
  bool _saving = false;
  Timer? _autoSaveTimer;

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Happy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.orange},
    {'name': 'Calm', 'icon': Icons.self_improvement, 'color': Colors.teal},
    {'name': 'Focused', 'icon': Icons.psychology, 'color': Colors.indigo},
    {'name': 'Sad', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.blueGrey},
    {'name': 'Tired', 'icon': Icons.bedtime, 'color': Colors.amber},
    {'name': 'Anxious', 'icon': Icons.sentiment_neutral, 'color': Colors.pinkAccent},
    {'name': 'Excited', 'icon': Icons.flash_on, 'color': Colors.deepOrangeAccent},
    {'name': 'Playful', 'icon': Icons.emoji_emotions, 'color': Colors.deepPurpleAccent},
    {'name': 'Grateful', 'icon': Icons.favorite, 'color': Colors.redAccent},
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
    _stress = widget.initialStress;
    _selectedMood = widget.initialMoodIndex;

    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _saveAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    // autosave draft every 20 seconds if username provided
    if (widget.username != null) {
      _autoSaveTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
        // Guard: if mounted, perform autosave
        if (!mounted) return;
        _autoSaveDraft();
      });
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _ctrl.dispose();
    _bgController.dispose();
    _floatController.dispose();
    _saveAnimController.dispose();
    super.dispose();
  }

  Future<void> _autoSaveDraft() async {
    if (widget.username == null) return;
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    try {
      InMemoryService.saveEntry(
        JournalEntry(
          username: widget.username!,
          mood: _selectedMood != null ? _moods[_selectedMood!]['name'] as String : 'Draft',
          stressLevel: _stress,
          note: text + ' (draft)',
          timestamp: DateTime.now(),
        ),
      );
    } catch (_) {
      // ignore if InMemoryService not available
    }
  }

  Future<void> _onSave() async {
    setState(() => _saving = true);
    _saveAnimController.forward(from: 0);
    final text = _ctrl.text.trim();

    try {
      if (widget.username != null) {
        InMemoryService.saveEntry(
          JournalEntry(
            username: widget.username!,
            mood: _selectedMood != null ? _moods[_selectedMood!]['name'] as String : 'Journal',
            stressLevel: _stress,
            note: text,
            timestamp: DateTime.now(),
          ),
        );
      }
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _saving = false);

    if (mounted) {
      Navigator.pop(context, {
        'text': text,
        'moodIndex': _selectedMood,
        'stress': _stress,
        'saved': true,
      });
    }
  }

  void _insertEmoji() {
    const emojis = ['😊', '✨', '🙏', '😌', '💪', '🌈', '😂', '😴'];
    final e = emojis[DateTime.now().millisecondsSinceEpoch % emojis.length];
    final pos = _ctrl.selection.base.offset;
    final content = _ctrl.text;
    if (pos >= 0 && pos <= content.length) {
      final updated = content.replaceRange(pos, pos, e);
      _ctrl.text = updated;
      _ctrl.selection = TextSelection.collapsed(offset: pos + e.length);
    } else {
      _ctrl.text = '$content $e';
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    }
  }

  void _pickPaperColor() {
    final colors = [Colors.white, Colors.yellow.shade50, Colors.blue.shade50, Colors.pink.shade50];
    final idx = colors.indexOf(_paperColor);
    final next = (idx + 1) % colors.length;
    setState(() => _paperColor = colors[next]);
  }

  LinearGradient _animatedBackground(double t) {
    final a = Color.lerp(Colors.purple.shade100, Colors.indigo.shade50, (sin(t * 2 * pi) + 1) / 2)!;
    final b = Color.lerp(Colors.orange.shade50, Colors.teal.shade50, (cos(t * 2 * pi) + 1) / 2)!;
    return LinearGradient(
      begin: Alignment(-0.8 + 0.6 * sin(t * 2 * pi), -1),
      end: Alignment(1, 0.6 * cos(t * 2 * pi)),
      colors: [a, b],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 720;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Journal'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgController, _floatController, _saveAnimController]),
        builder: (context, _) {
          final t = _bgController.value;
          final float = sin(_floatController.value * 2 * pi) * 8;
          final saveAnim = Curves.easeOut.transform(_saveAnimController.value);
          return Container(
            decoration: BoxDecoration(gradient: _animatedBackground(t)),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: Offset(0, -float),
                          child: Hero(
                            tag: 'daily_journal_card',
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.96),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 6))],
                                border: Border.all(color: Colors.white.withOpacity(0.6)),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.menu_book_rounded, color: Colors.indigo)),
                                      const SizedBox(width: 12),
                                      const Expanded(child: Text('Tuliskan harimu', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
                                      if (_selectedMood != null) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(color: (_moods[_selectedMood!]['color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                                          child: Row(children: [
                                            Icon(_moods[_selectedMood!]['icon'] as IconData, color: _moods[_selectedMood!]['color'] as Color, size: 18),
                                            const SizedBox(width: 8),
                                            Text(_moods[_selectedMood!]['name'] as String, style: TextStyle(color: _moods[_selectedMood!]['color'] as Color, fontWeight: FontWeight.w700)),
                                          ]),
                                        ),
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 44,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _moods.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                                      itemBuilder: (c, i) {
                                        final m = _moods[i];
                                        final active = _selectedMood == i;
                                        return ChoiceChip(
                                          selected: active,
                                          onSelected: (_) => setState(() => _selectedMood = active ? null : i),
                                          label: Row(children: [Icon(m['icon'] as IconData, size: 18, color: active ? Colors.white : m['color'] as Color), const SizedBox(width: 8), Text(m['name'] as String)]),
                                          selectedColor: (m['color'] as Color).withOpacity(0.95),
                                          backgroundColor: Colors.grey.shade100,
                                          labelStyle: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 360),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _paperColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(onPressed: _insertEmoji, icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.deepOrange)),
                                    IconButton(onPressed: _pickPaperColor, icon: const Icon(Icons.format_color_fill, color: Colors.teal)),
                                    IconButton(onPressed: () => _ctrl.clear(), icon: const Icon(Icons.clear, color: Colors.grey)),
                                    const Spacer(),
                                    AnimatedScale(scale: 1.0 + 0.05 * saveAnim, duration: const Duration(milliseconds: 200), child: Text('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w600))),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: TextField(
                                      controller: _ctrl,
                                      expands: true,
                                      maxLines: null,
                                      style: const TextStyle(fontSize: 16, height: 1.4),
                                      decoration: const InputDecoration.collapsed(hintText: 'Tulis jurnal... (ceritakan perasaanmu, tiga hal yang disyukuri, rencana besok)'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    const Icon(Icons.thermostat, color: Colors.deepOrange),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text('Tingkat stres: $_stress / 10', style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Slider(value: _stress.toDouble(), min: 0, max: 10, divisions: 10, activeColor: Colors.deepOrange, onChanged: (v) => setState(() => _stress = v.round())),
                                      ]),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('${_ctrl.text.length} chars', style: TextStyle(color: Colors.grey.shade700)),
                                  ],
                                ),

                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _saving ? null : _onSave,
                                        icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                                        label: Text(_saving ? 'Menyimpan...' : 'Simpan & Tutup'),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _saving ? null : () => Navigator.pop(context),
                                        icon: const Icon(Icons.cancel_outlined),
                                        label: const Text('Batal'),
                                        style: OutlinedButton.styleFrom(foregroundColor: Colors.indigo, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ===========================
   Dosen Home
   =========================== */

class DosenHomePage extends StatelessWidget {
  final String username;
  const DosenHomePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final users = InMemoryService.allUsers();
    return Scaffold(
      appBar: AppBar(title: Text('Home Dosen - $username'), backgroundColor: Colors.deepPurple, actions: [
        IconButton(onPressed: () => Navigator.pushAndRemoveUntil(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginPage(), transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)), (r) => false), icon: const Icon(Icons.logout))
      ]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            Card(
              color: Colors.deepPurple.shade50,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(leading: CircleAvatar(backgroundColor: Colors.deepPurple.shade100, child: const Icon(Icons.monitor_heart, color: Colors.deepPurple)), title: const Text('Monitoring Mahasiswa'), subtitle: Text('Jumlah terdaftar: ${users.length}')),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: users.isEmpty
                  ? Center(child: Text('Belum ada mahasiswa terdaftar', style: TextStyle(color: Colors.grey.shade600)))
                  : ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (c, i) {
                        final u = users[i];
                        final count = InMemoryService.entriesFor(u.username).length;
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U')),
                            title: Text(u.name),
                            subtitle: Text('${u.major} • ${u.age} tahun • entri: $count'),
                            trailing: IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => Navigator.push(context, PageRouteBuilder(pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: DosenViewUserProfileWithHistory(user: u)), transitionDuration: const Duration(milliseconds: 380))),
                            ),
                          ),
                        );
                      }),
            ),
          ]),
        ),
      ),
    );
  }
}

class DosenViewUserProfileWithHistory extends StatelessWidget {
  final User user;
  const DosenViewUserProfileWithHistory({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final entries = InMemoryService.entriesFor(user.username);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Mahasiswa'), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          CircleAvatar(radius: 46, child: Text(user.name.isNotEmpty ? user.name[0] : 'U', style: const TextStyle(fontSize: 36))),
          const SizedBox(height: 12),
          Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Column(children: [
            _infoRow('Username', user.username),
            _infoRow('Nama', user.name),
            _infoRow('Usia', '${user.age}'),
            _infoRow('Jurusan', user.major),
            _infoRow('Email', user.email),
            _infoRow('Jumlah Entri', '${entries.length}'),
          ]))),
          const SizedBox(height: 12),
          const Text('Riwayat Entri:', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Expanded(child: entries.isEmpty ? Center(child: Text('Belum ada entri', style: TextStyle(color: Colors.grey.shade600))) : ListView.separated(itemCount: entries.length, separatorBuilder: (_, __) => const Divider(), itemBuilder: (c, i) {
            final e = entries[i];
            return ListTile(leading: CircleAvatar(child: Text(e.mood.isNotEmpty ? e.mood[0] : 'M')), title: Text('${e.mood} • Stress ${e.stressLevel}/10'), subtitle: Text(e.note.isEmpty ? '(tidak ada catatan)' : e.note), trailing: Text('${e.timestamp.day}/${e.timestamp.month}/${e.timestamp.year}'));
          })),
        ]),
      ),
    );
  }
}

/* ===========================
   Utilities
   =========================== */

Widget _infoRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [SizedBox(width: 110, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600))), Expanded(child: Text(value))]));