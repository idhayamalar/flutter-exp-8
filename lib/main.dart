import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const EmployeeInfoApp());
}

class EmployeeInfoApp extends StatelessWidget {
  const EmployeeInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Information Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const EmployeeHomePage(),
    );
  }
}

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  String _message = '';
  bool _isError = false;

  Future<void> _saveEmployeeDetails() async {
    final name = _nameController.text.trim();
    final empIdText = _empIdController.text.trim();
    final salaryText = _salaryController.text.trim();

    if (name.isEmpty || empIdText.isEmpty || salaryText.isEmpty) {
      setState(() {
        _message = 'Please fill in all fields.';
        _isError = true;
      });
      return;
    }

    final empId = int.tryParse(empIdText);
    final salary = int.tryParse(salaryText);

    if (empId == null || salary == null) {
      setState(() {
        _message = 'Employee ID and Salary must be valid numbers.';
        _isError = true;
      });
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('employees').add({
        'name': name,
        'empid': empId,
        'salary': salary,
      });

      if (!mounted) return;

      setState(() {
        _message = 'Data Saved Successfully';
        _isError = false;
      });

      _nameController.clear();
      _empIdController.clear();
      _salaryController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data Saved Successfully')),
      );
    } catch (e) {
      setState(() {
        _message = 'Failed to save employee details: $e';
        _isError = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _empIdController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeStream = Firebase.apps.isNotEmpty
        ? FirebaseFirestore.instance
            .collection('employees')
            .orderBy('name')
            .snapshots()
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Information Management'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Employee Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _empIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Employee ID',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _salaryController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Employee Salary',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _saveEmployeeDetails,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Employee Details'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                        if (_message.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            _message,
                            style: TextStyle(
                              color: _isError ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Saved Employees',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (employeeStream == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Complete Firebase setup to load employee records.'),
                    ),
                  )
                else
                  StreamBuilder<QuerySnapshot>(
                    stream: employeeStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading employees: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final employees = snapshot.data?.docs ?? [];

                      if (employees.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text('No Employees Found'),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final employee = employees[index].data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text(employee['name']?.toString() ?? 'No Name'),
                              subtitle: Text(
                                'Employee ID: ${employee['empid']}\nSalary: ${employee['salary']}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
