import 'package:flutter/material.dart';

void main() {
  runApp(const ReverseHabitApp());
}

// Define colors
const Color primaryColor = Color(0xFF5A8D9B);
const Color accentColor = Color(0xFFFFC300);
const Color backgroundColor = Color(0xFFF7F9FA);

class ReverseHabitApp extends StatelessWidget {
  const ReverseHabitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reverse Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Data Model
class Habit {
  String name;
  int streak;
  DateTime lastResetDate;
  String emoji;
  String id;

  Habit({
    required this.name,
    this.streak = 0,
    required this.lastResetDate,
    this.emoji = '🚫',
    required this.id,
  });
}

// Main Navigation
class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // Sample data
  final List<Habit> _habits = [
    Habit(
      id: 'h1',
      name: 'Unnecessary Spending',
      streak: 7,
      lastResetDate: DateTime.now().subtract(const Duration(days: 7)),
      emoji: '💳',
    ),
    Habit(
      id: 'h2',
      name: 'Checking Social Media',
      streak: 3,
      lastResetDate: DateTime.now().subtract(const Duration(days: 3)),
      emoji: '📱',
    ),
  ];

  void _addHabit(String name, String emoji) {
    setState(() {
      _habits.add(Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        lastResetDate: DateTime.now(),
        emoji: emoji,
      ));
    });
  }

  void _updateHabitStreak(String id, int newStreak) {
    setState(() {
      final index = _habits.indexWhere((h) => h.id == id);
      if (index != -1) {
        _habits[index].streak = newStreak;
        _habits[index].lastResetDate = DateTime.now();
      }
    });
  }

  void _deleteHabit(String id) {
    setState(() {
      _habits.removeWhere((h) => h.id == id);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      HabitListScreen(
        habits: _habits,
        addHabit: _addHabit,
        updateHabitStreak: _updateHabitStreak,
        deleteHabit: _deleteHabit,
      ),
      const AboutScreen(),
    ];

    return Scaffold(
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Habit List Screen
class HabitListScreen extends StatelessWidget {
  final List<Habit> habits;
  final Function(String, String) addHabit;
  final Function(String, int) updateHabitStreak;
  final Function(String) deleteHabit;

  const HabitListScreen({
    Key? key,
    required this.habits,
    required this.addHabit,
    required this.updateHabitStreak,
    required this.deleteHabit,
  }) : super(key: key);

  void _showAddHabitDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String selectedEmoji = '🚫';

    const List<String> emojiOptions = [
      '🚫', '🚭', '📱', '🍔', '🍺', '🎮', '💳', '☕', '🍰', '😴'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Add Bad Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    hintText: 'e.g., Binge watching',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Choose Emoji:', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: emojiOptions.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedEmoji = emoji;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selectedEmoji == emoji
                              ? primaryColor.withOpacity(0.15)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selectedEmoji == emoji ? primaryColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 28)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  addHabit(controller.text, selectedEmoji);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Days Clean'),
        centerTitle: true,
      ),
      body: habits.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🐰', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text(
              'Time to break some habits!',
              style: TextStyle(
                fontSize: 22,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Habit" to start your first streak.',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HabitCard(
              habit: habit,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HabitDetailScreen(
                      habit: habit,
                      updateHabitStreak: updateHabitStreak,
                      deleteHabit: deleteHabit,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Add Habit'),
      ),
    );
  }
}

// Habit Card Widget
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitCard({
    Key? key,
    required this.habit,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  habit.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: accentColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.streak}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'days clean',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// Habit Detail Screen
class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  final Function(String, int) updateHabitStreak;
  final Function(String) deleteHabit;

  const HabitDetailScreen({
    Key? key,
    required this.habit,
    required this.updateHabitStreak,
    required this.deleteHabit,
  }) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late int currentStreak;
  late DateTime lastResetDate;

  @override
  void initState() {
    super.initState();
    currentStreak = widget.habit.streak;
    lastResetDate = widget.habit.lastResetDate;
  }

  void _incrementStreak(BuildContext context) {
    setState(() {
      currentStreak = currentStreak + 1;
      lastResetDate = DateTime.now();
    });
    widget.updateHabitStreak(widget.habit.id, currentStreak);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Streak extended to $currentStreak days!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetStreak(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Reset Streak?'),
        content: Text(
          'Did you do "${widget.habit.name}"? This will reset your streak of $currentStreak days back to 0.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentStreak = 0;
                lastResetDate = DateTime.now();
              });
              widget.updateHabitStreak(widget.habit.id, 0);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, I Failed', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteHabitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Habit?'),
        content: Text(
          'Are you sure you want to permanently remove "${widget.habit.name}" from your tracker?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.deleteHabit(widget.habit.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.habit.emoji} ${widget.habit.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.emoji_events, size: 60, color: accentColor),
                    const SizedBox(height: 10),
                    const Text('Current Streak', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                      ),
                    ),
                    const Text(
                      'DAYS CLEAN',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _incrementStreak(context),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Stayed Clean', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _resetStreak(context),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('I Failed', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.calendar_today, color: primaryColor),
                      title: const Text('Started Clean'),
                      trailing: Text(_formatDate(lastResetDate.subtract(Duration(days: currentStreak)))),
                    ),
                    ListTile(
                      leading: const Icon(Icons.update, color: primaryColor),
                      title: const Text('Last Check-in'),
                      trailing: Text(_formatDate(lastResetDate)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () => _deleteHabitConfirmation(context),
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text('Delete Habit', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

// About Screen
class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('🐰', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 10),
            const Text(
              'Reverse Habit Tracker',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 8),
            Text('Version 1.0.0', style: TextStyle(color: Colors.grey[600])),
            const Divider(height: 30),
            const Text(
              'What is a Reverse Habit?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              'This app helps you track the absence of a bad habit. Instead of counting how many days you did something positive, you count how many days you avoided something negative. Every day you avoid the habit, your streak grows! If you fail, the streak resets to zero, giving you clear accountability.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'How to Use:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.add_circle_outline, color: accentColor),
              title: Text('Add your bad habit (e.g., "Smoking")'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('Tap "Stayed Clean" to extend your streak'),
            ),
            const ListTile(
              leading: Icon(Icons.refresh, color: Colors.red),
              title: Text('Tap "I Failed" to reset the streak to 0'),
            ),
            const SizedBox(height: 30),
            const Text(
              'Made with Flutter by Ab.Ah',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}