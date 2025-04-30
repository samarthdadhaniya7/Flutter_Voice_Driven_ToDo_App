import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice-Driven To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TaskListScreen(),
    );
  }
}

class Task {
  String name;
  String description;

  Task({required this.name, required this.description});
}

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  void addTask(Task task) {
    state = [...state, task];
  }

  void deleteTask(Task task) {
    state = state.where((t) => t != task).toList();
  }

  void editTask(Task oldTask, Task updatedTask) {
    state = state.map((task) {
      if (task == oldTask) {
        return updatedTask;
      } else {
        return task;
      }
    }).toList();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) => TaskNotifier());

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTTS();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Speech status: $status"),
      onError: (error) => print("Speech error: $error"),
    );
    if (available) {
      print("Speech recognition is available");
    } else {
      print("Speech recognition is not available");
    }
  }

  void _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  void _startListening() async {
    if (!_isListening) {
      _isListening = true;
      _lastWords = '';
      setState(() {});
      try {
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _lastWords = result.recognizedWords;
            });
            print("Recognized words: ${_lastWords}");
          },
          listenFor: const Duration(seconds: 5),
          pauseFor: const Duration(seconds: 3),
          localeId: 'en_US',
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      } catch (e) {
        print("Error during speech recognition: $e");
        await _speak("An error occurred during speech recognition.");
      } finally {
        setState(() {
          _isListening = false;
          _processCommand(_lastWords);
        });
      }
    }
  }

  Future<void> _processCommand(String command) async {
    final taskData = ref.read(taskProvider.notifier);

    if (command.toLowerCase().startsWith('add')) {
      String taskName = command.substring(3).trim();
      if (taskName.isNotEmpty) {
        taskData.addTask(Task(name: taskName, description: 'No description'));
        await _speak('Added task: $taskName');
      } else {
        await _speak('Please specify the task to add.');
      }
    } else {
      await _speak('Command not recognized.');
    }
  }

  void _showAddTaskDialog() {
    final taskData = ref.read(taskProvider.notifier);

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Task Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Task Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                taskData.addTask(Task(
                  name: nameController.text,
                  description: descriptionController.text,
                ));
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(Task task) {
    final taskData = ref.read(taskProvider.notifier);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                taskData.deleteTask(task);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Task task) {
    final taskData = ref.read(taskProvider.notifier);

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController(text: task.name);
        TextEditingController descriptionController = TextEditingController(text: task.description);

        return AlertDialog(
          title: const Text('Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Task Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Task Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                taskData.editTask(task, Task(
                  name: nameController.text,
                  description: descriptionController.text,
                ));
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice-Driven To-Do List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _isListening
                  ? 'Listening... Say "add [task]"'
                  : 'Tap the mic and speak!',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recognized Words: $_lastWords',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.name),
                  subtitle: Text(task.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _showDeleteDialog(task),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        tooltip: 'Listen',
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Task List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Task',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            _showAddTaskDialog();
          }
        },
      ),
    );
  }
}
