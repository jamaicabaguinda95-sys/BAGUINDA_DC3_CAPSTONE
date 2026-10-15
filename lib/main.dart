import 'package:flutter/material.dart';

void main() {
  runApp(const TaskManagerApp());
}

const Color backgroundColor = Color(0xFF101522);
const Color panelColor = Color(0xFF191F30);
const Color accentColor = Color(0xFF438BFF);
const Color mutedColor = Color(0xFF9AA6BD);

class Task {
  Task({
    required this.title,
    this.completed = false,
    this.later = false,
  });

  String title;
  bool completed;
  bool later;
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Tasks',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: panelColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const TaskHomePage(),
    );
  }
}

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({super.key});

  @override
  State<TaskHomePage> createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  int selectedIndex = 0;
  bool notificationsEnabled = true;

  final List<Task> tasks = [
    Task(title: 'Buy groceries'),
    Task(title: 'Pay electricity bill', completed: true),
    Task(title: 'Finish Flutter layout'),
    Task(title: 'Call the dentist'),
    Task(title: 'Plan weekend', later: true),
  ];

  int get completedCount =>
      tasks.where((task) => task.completed).length;

  int get openCount => tasks.length - completedCount;

  Future<void> addTask() async {
    final controller = TextEditingController();
    bool addForLater = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: panelColor,
              title: const Text('Add a new task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Type a new item',
                    ),
                    onSubmitted: (_) {
                      Navigator.pop(dialogContext, {
                        'title': controller.text,
                        'later': addForLater,
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Schedule for later'),
                    value: addForLater,
                    onChanged: (value) {
                      setDialogState(() {
                        addForLater = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, {
                      'title': controller.text,
                      'later': addForLater,
                    });
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    final title = result?['title'] as String?;
    if (title != null && title.trim().isNotEmpty && mounted) {
      setState(() {
        tasks.add(
          Task(
            title: title.trim(),
            later: result?['later'] as bool? ?? false,
          ),
        );
      });
    }

    controller.dispose();
  }

  void toggleTask(Task task, bool? value) {
    setState(() {
      task.completed = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHomePage(),
      buildListPage(),
      buildProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MY TASKS',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add task',
            onPressed: addTask,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: panelColor,
        selectedIndex: selectedIndex,
        indicatorColor: accentColor.withOpacity(0.22),
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'List',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    final todayTasks = tasks.where((task) => !task.later).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Good day!',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        const Text(
          'Let’s get things done.',
          style: TextStyle(color: mutedColor),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Open items',
                style: TextStyle(color: mutedColor, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                '$openCount',
                style: const TextStyle(
                  color: accentColor,
                  fontSize: 46,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text('$completedCount done · ${tasks.length} total'),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: tasks.isEmpty
                      ? 0
                      : completedCount / tasks.length,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Today',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (todayTasks.isEmpty)
          const Text(
            'No tasks for today. Add one when you are ready!',
            style: TextStyle(color: mutedColor),
          ),
        ...todayTasks.map(
          (task) => taskTile(task),
        ),
        const SizedBox(height: 18),
        TextButton.icon(
          onPressed: () => setState(() => selectedIndex = 1),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('View all tasks'),
        ),
      ],
    );
  }

  Widget buildListPage() {
    final todayTasks = tasks.where((task) => !task.later).toList();
    final laterTasks = tasks.where((task) => task.later).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'My list',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${tasks.length} items · $completedCount completed',
          style: const TextStyle(color: mutedColor),
        ),
        const SizedBox(height: 24),
        const Text(
          'Today',
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (todayTasks.isEmpty)
          const Text('No tasks for today.',
              style: TextStyle(color: mutedColor)),
        ...todayTasks.map((task) => taskTile(task)),
        const SizedBox(height: 24),
        const Text(
          'Later',
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (laterTasks.isEmpty)
          const Text('Nothing planned for later.',
              style: TextStyle(color: mutedColor)),
        ...laterTasks.map((task) => taskTile(task)),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: addTask,
          icon: const Icon(Icons.add),
          label: const Text('Add a new item'),
        ),
      ],
    );
  }

  Widget taskTile(Task task) {
    return Card(
      color: panelColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: task.completed,
        onChanged: (value) => toggleTask(task, value),
        activeColor: accentColor,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
                task.completed ? TextDecoration.lineThrough : null,
            color: task.completed ? mutedColor : Colors.white,
          ),
        ),
        secondary: PopupMenuButton<String>(
          onSelected: (action) {
            setState(() {
              if (action == 'later') {
                task.later = !task.later;
              } else if (action == 'delete') {
                tasks.remove(task);
              }
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'later',
              child: Text(task.later ? 'Move to today' : 'Move to later'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfilePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: accentColor,
              child: Text(
                'AB',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your name',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'you@email.com',
                    style: TextStyle(color: mutedColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        profileRow('Items created', '${tasks.length}'),
        profileRow('Completed', '$completedCount'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Notifications'),
          value: notificationsEnabled,
          activeThumbColor: accentColor,
          onChanged: (value) {
            setState(() => notificationsEnabled = value);
          },
        ),
        const Divider(color: Colors.white12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Edit profile'),
          trailing: const Icon(Icons.chevron_right),
          onTap: editProfile,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.redAccent),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connect authentication to enable logout.'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget profileRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editProfile() async {
    final nameController = TextEditingController(text: 'Your name');
    final emailController =
        TextEditingController(text: 'you@email.com');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panelColor,
        title: const Text('Edit profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Profile editing UI is ready; save your details '
                    'to persistent storage in the next step.',
                  ),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameController.dispose();
    emailController.dispose();
  }
}