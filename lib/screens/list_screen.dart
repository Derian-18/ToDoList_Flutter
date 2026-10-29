import 'package:flutter/material.dart';
import '../widgets/task.dart';

class _Task {
  String title;

  _Task(this.title);
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  final List<_Task> _tasks = [];

  void _addTask() {
    final text = _taskController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _tasks.add(_Task(text));
    });

    _taskController.clear();
  }

  Future<void> _editTask(_Task task) async {
    String editedText = task.title;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextFormField(
            initialValue: task.title,
            autofocus: true,
            maxLength: 100,
            decoration: const InputDecoration(
              labelText: 'Nombre de la tarea',
            ),
            onChanged: (value) {
              editedText = value;
            },
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                Navigator.pop(dialogContext, value.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (editedText.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, editedText.trim());
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null || !_tasks.contains(task)) return;

    setState(() {
      task.title = result;
    });
  }

  void _deleteTask(_Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('To Do List'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: Colors.black26,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        hintText: 'Ingresa una tarea:',
                        counterText: '',
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addTask(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 44,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _addTask,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFF82AAF5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'Agrega una tarea a la lista',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      buildDefaultDragHandles: false,
                      itemCount: _tasks.length,
                      onReorderItem: _reorderTasks,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];

                        return TaskTile(
                          key: ObjectKey(task),
                          title: task.title,
                          index: index,
                          onEdit: () => _editTask(task),
                          onDelete: () => _deleteTask(task),
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