import 'package:flutter/material.dart';

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
      // Подставьте любой экран вручную при разработке.
      home: const HabitHomeScreen(),
    );
  }
}

class HabitHomeScreen extends StatelessWidget {
  const HabitHomeScreen({super.key});

  static const List<Map<String, String>> mockHabits = [
    {'title': 'Чтение', 'note': '20 минут перед сном'},
    {'title': 'Спорт', 'note': 'Три подхода планки'},
    {'title': 'Вода', 'note': '8 стаканов в день'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои привычки'),
        actions: [
          IconButton(
            onPressed: null, // Навигация появится в следующей ЛР
            icon: const Icon(Icons.add),
            tooltip: 'Добавить привычку',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DaySelector(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final habit = mockHabits[index];
                return HabitCard(
                  title: habit['title']!,
                  note: habit['note']!,
                  completedToday: index.isEven,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: mockHabits.length,
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
    required this.title,
    required this.note,
    this.completedToday = false,
  });

  final String title;
  final String note;
  final bool completedToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: completedToday
          ? colorScheme.secondaryContainer
          : colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              completedToday ? Icons.check_circle : Icons.circle_outlined,
              color: completedToday
                  ? colorScheme.secondary
                  : colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: colorScheme.outline),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: null, // Перейти в детали/редактирование позже
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
  const HabitDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали привычки'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Спорт', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Цель: 3 раза в неделю',
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
                  done: index.isEven,
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
  const HabitEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая привычка'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Например, Чтение',
              ),
              enabled: true,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Частота',
                hintText: 'Каждый день / 3 раза в неделю',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(value: 'blue', child: Text('Синий')),
                DropdownMenuItem(value: 'green', child: Text('Зелёный')),
                DropdownMenuItem(value: 'pink', child: Text('Розовый')),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(
                labelText: 'Цвет/иконка',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null, // Сохранение будет в ЛР5
                child: const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
