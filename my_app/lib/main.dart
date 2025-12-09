import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class Habit {
  const Habit({
    required this.title,
    required this.note,
    this.completedToday = false,
  });

  final String title;
  final String note;
  final bool completedToday;

  Habit copyWith({
    String? title,
    String? note,
    bool? completedToday,
  }) {
    return Habit(
      title: title ?? this.title,
      note: note ?? this.note,
      completedToday: completedToday ?? this.completedToday,
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitTrack Mini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HabitAppShell(),
    );
  }
}

class HabitAppShell extends StatefulWidget {
  const HabitAppShell({super.key});

  @override
  State<HabitAppShell> createState() => _HabitAppShellState();
}

class _HabitAppShellState extends State<HabitAppShell> {
  int _currentIndex = 0;
  final List<Habit> _habits = [
    Habit(title: 'Чтение', note: '20 минут перед сном'),
    Habit(title: 'Спорт', note: 'Три подхода планки', completedToday: true),
    Habit(title: 'Вода', note: '8 стаканов в день'),
  ];

  void _toggleHabit(Habit habit) {
    setState(() {
      final idx = _habits.indexOf(habit);
      if (idx != -1) {
        _habits[idx] =
            habit.copyWith(completedToday: !habit.completedToday);
      }
    });
  }

  Future<void> _createHabit(BuildContext context) async {
    final result = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (_) => const HabitEditScreen(),
      ),
    );
    if (result != null) {
      setState(() {
        _habits.add(result);
      });
    }
  }

  Future<void> _editHabit(BuildContext context, Habit habit) async {
    final result = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (_) => HabitEditScreen(initialHabit: habit),
      ),
    );
    if (result != null) {
      setState(() {
        final idx = _habits.indexOf(habit);
        if (idx != -1) {
          _habits[idx] = result;
        }
      });
    }
  }

  void _openDetails(BuildContext context, Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HabitDetailsScreen(
          habit: habit,
          onEdit: () => _editHabit(context, habit),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HabitHomeScreen(
        habits: _habits,
        onAdd: () => _createHabit(context),
        onToggle: _toggleHabit,
        onOpenDetails: (habit) => _openDetails(context, habit),
        onEdit: (habit) => _editHabit(context, habit),
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Привычки',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Профиль',
          ),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HabitHomeScreen extends StatelessWidget {
  const HabitHomeScreen({
    super.key,
    required this.habits,
    required this.onAdd,
    required this.onToggle,
    required this.onOpenDetails,
    required this.onEdit,
  });

  final List<Habit> habits;
  final VoidCallback onAdd;
  final void Function(Habit) onToggle;
  final void Function(Habit) onOpenDetails;
  final void Function(Habit) onEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои привычки'),
        actions: [
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            tooltip: 'Добавить привычку',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('Новая привычка'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DaySelector(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final habit = habits[index];
                return HabitCard(
                  habit: habit,
                  onToggle: () => onToggle(habit),
                  onTap: () => onOpenDetails(habit),
                  onEdit: () => onEdit(habit),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: habits.length,
            ),
          ),
        ],
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onTap,
    required this.onEdit,
  });

  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: habit.completedToday
          ? colorScheme.secondaryContainer
          : colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              onPressed: onToggle,
              icon: Icon(
                habit.completedToday
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: habit.completedToday
                    ? colorScheme.secondary
                    : colorScheme.outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.note,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.outline),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  const _DaySelector();

  @override
  Widget build(BuildContext context) {
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return SizedBox(
      height: 72,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final isToday = index == DateTime.now().weekday - 1;
          return ChoiceChip(
            label: Text(days[index]),
            selected: isToday,
            onSelected: null, // Логика выбора будет позже
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: days.length,
      ),
    );
  }
}

class HabitDetailsScreen extends StatelessWidget {
  const HabitDetailsScreen({
    super.key,
    required this.habit,
    required this.onEdit,
  });

  final Habit habit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали привычки'),
        actions: [
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Редактировать',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(habit.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              habit.note,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Text('Прогресс за 7 дней',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                7,
                (index) => _DayChip(
                  label: 'День ${index + 1}',
                  done: index <= 3 ? habit.completedToday : !habit.completedToday,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text('Мотивация',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Здесь будет цитата с публичного API.\n'
                'Пока статический текст.',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: null, // Будет реализовано в ЛР6
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Получить цитату'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(
        done ? Icons.check_circle : Icons.circle_outlined,
        color: done ? colorScheme.secondary : colorScheme.outline,
      ),
      label: Text(label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      backgroundColor:
          done ? colorScheme.secondaryContainer : colorScheme.surface,
    );
  }
}

class HabitEditScreen extends StatelessWidget {
  const HabitEditScreen({super.key, this.initialHabit});

  final Habit? initialHabit;

  @override
  Widget build(BuildContext context) {
    final titleController =
        TextEditingController(text: initialHabit?.title ?? '');
    final noteController =
        TextEditingController(text: initialHabit?.note ?? '');
    bool completed = initialHabit?.completedToday ?? false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              initialHabit == null ? 'Новая привычка' : 'Редактировать',
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название',
                    hintText: 'Например, Чтение',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Цель/комментарий',
                    hintText: 'Например, 20 минут перед сном',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Выполнено сегодня'),
                  value: completed,
                  onChanged: (value) {
                    setState(() {
                      completed = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Введите название привычки'),
                          ),
                        );
                        return;
                      }
                      final habit = Habit(
                        title: title,
                        note: noteController.text.trim(),
                        completedToday: completed,
                      );
                      Navigator.pop(context, habit);
                    },
                    child: Text(initialHabit == null ? 'Создать' : 'Сохранить'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Профиль / настройки (заглушка)'),
      ),
    );
  }
}
