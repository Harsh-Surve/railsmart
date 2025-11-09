import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();

  void _continue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your name')));
      return;
    }
    // Store name in app state
    context.read<AppState>().setUser(name);
    Navigator.pushReplacementNamed(context, '/search'); // ensure this route exists in your MaterialApp
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RailSmart - Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text('Welcome to RailSmart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Your name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _continue, child: const Text('Continue')),
            const SizedBox(height: 20),
            const Text('Demo mode: This app is a simulation for project demonstration.'),
          ],
        ),
      ),
    );
  }
}

const List<Map<String, String>> trainData = [
  {
    "id": "101",
    "name": "Mumbai–Pune Intercity",
    "source": "Mumbai",
    "destination": "Pune",
    "departure": "07:30",
    "arrival": "10:00"
  }
];