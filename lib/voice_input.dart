import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_provider.dart';

class VoiceInputScreen extends ConsumerStatefulWidget {
  const VoiceInputScreen({Key? key}) : super(key: key);

  @override
  _VoiceInputScreenState createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends ConsumerState<VoiceInputScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts _flutterTts = FlutterTts();
  String _command = "Press the button to start speaking.";
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
  }

  // Start listening to voice commands
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (result) {
        setState(() {
          _command = result.recognizedWords;
        });
        _processCommand(_command);
      });
    }
  }

  // Stop listening
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Process the command, add task or provide feedback
  void _processCommand(String command) async {
    if (command.contains("add task")) {
      String task = command.replaceAll("add task", "").trim();
      if (task.isNotEmpty) {
        // Add task to Firestore and provide feedback
        ref.read(taskProvider.notifier).addTask(task);
        _flutterTts.speak("Task added: $task");
      } else {
        _flutterTts.speak("Please specify a task.");
      }
    } else if (command.contains("complete task")) {
      String task = command.replaceAll("complete task", "").trim();
      ref.read(taskProvider.notifier).completeTask(task);
      _flutterTts.speak("Task completed: $task");
    } else {
      _flutterTts.speak("Sorry, I didn't understand that.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice-Driven To-Do")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(_command),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? "Stop Listening" : "Start Listening"),
            ),
          ],
        ),
      ),
    );
  }
}
