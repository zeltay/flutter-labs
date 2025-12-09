import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models/habit.dart';
import 'data/repositories/habit_repository.dart';
import 'data/services/advice_service.dart';

void main() {
  runApp(const MainApp());
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
  final HabitRepository _repository = HabitRepository();
  int _currentIndex = 0;
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });
    final habits = await _repository.loadHabits();
    setState(() {
      _habits = habits;
      _isLoading = false;
    });
  }

  Future<void> _toggleHabit(Habit habit) async {
    final updatedHabit = habit.copyWith(
      completedToday: !habit.completedToday,
    );
    setState(() {
      final idx = _habits.indexWhere((h) => h.id == habit.id);
      if (idx != -1) {
        _habits[idx] = updatedHabit;
      }
    });
    await _repository.updateHabit(updatedHabit);
  }

  Future<void> _createHabit(BuildContext context) async {
    final result = await Navigator.push<Habit>(
      context,
      MaterialPageRoute(
        builder: (_) => const HabitEditScreen(),
      ),
    );
    if (result != null) {
      await _repository.addHabit(result);
      await _loadHabits();
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
      await _repository.updateHabit(result);
      await _loadHabits();
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
        isLoading: _isLoading,
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
    required this.isLoading,
    required this.onAdd,
    required this.onToggle,
    required this.onOpenDetails,
    required this.onEdit,
  });

  final List<Habit> habits;
  final bool isLoading;
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _DaySelector(),
                Expanded(
                  child: habits.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Нет привычек',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Нажмите + чтобы добавить',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
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
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
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
            onSelected: null,
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemCount: days.length,
      ),
    );
  }
}

class HabitDetailsScreen extends StatefulWidget {
  const HabitDetailsScreen({
    super.key,
    required this.habit,
    required this.onEdit,
  });

  final Habit habit;
  final VoidCallback onEdit;

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  final AdviceService _adviceService = AdviceService();
  String? _advice;
  bool _isLoadingAdvice = false;
  String? _error;

  Future<void> _fetchAdvice() async {
    setState(() {
      _isLoadingAdvice = true;
      _error = null;
    });

    try {
      final advice = await _adviceService.getAdvice();
      setState(() {
        _advice = advice;
        _isLoadingAdvice = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить цитату. Проверьте подключение к интернету.';
        _isLoadingAdvice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали привычки'),
        actions: [
          IconButton(
            onPressed: widget.onEdit,
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
            Text(
              widget.habit.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.habit.note,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Text(
              'Прогресс за 7 дней',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                7,
                (index) => _DayChip(
                  label: 'День ${index + 1}',
                  done: index <= 3
                      ? widget.habit.completedToday
                      : !widget.habit.completedToday,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Мотивация',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoadingAdvice
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Text(
                          _error!,
                          style: TextStyle(color: colorScheme.error),
                        )
                      : _advice != null
                          ? Text(_advice!)
                          : const Text(
                              'Нажмите кнопку ниже, чтобы получить мотивационную цитату.',
                            ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingAdvice ? null : _fetchAdvice,
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
                        id: initialHabit?.id ?? const Uuid().v4(),
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
