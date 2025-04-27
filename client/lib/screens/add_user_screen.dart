import 'package:flutter/material.dart';
import 'package:events/models/user_model.dart';
import 'package:events/services/user_service.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final userRequest = UserRequestCreate(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );

        await _userService.createUser(userRequest);
        
        if (mounted) {
          Navigator.pop(context, true); // Возвращаемся с флагом успеха
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New User'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildFirstNameField(),
                const SizedBox(height: 16),
                _buildLastNameField(),
                const SizedBox(height: 16),
                _buildPhoneField(),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 24),
                _isLoading 
                    ? const CircularProgressIndicator()
                    : _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFirstNameField() => TextFormField(
    controller: _firstNameController,
    decoration: const InputDecoration(
      labelText: 'Имя',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.person)),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Введите имя';
      }
    return null;
    },
  );

  Widget _buildLastNameField() => TextFormField(
    controller: _lastNameController,
    decoration: const InputDecoration(
      labelText: 'Фамилия',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.person_outline)),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Введите фамилию';
      }
      return null;
    },
  );

  Widget _buildPhoneField() => TextFormField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    decoration: const InputDecoration(
      labelText: 'Телефон',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.phone)),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Введите телефон';
      }
      if (!RegExp(r'^\+?[0-9]{10,}$').hasMatch(value)) {
        return 'Enter valid phone number';
      }
      return null;
    },
  );

  Widget _buildPasswordField() => TextFormField(
    controller: _passwordController,
    obscureText: true,
    decoration: const InputDecoration(
      labelText: 'Пароль',
      border: OutlineInputBorder(),
      prefixIcon: Icon(Icons.lock)),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Введите пароль';
      }
      if (value.length < 6) {
        return 'Минимум 6 символов';
      }
      return null;
    },
  );

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: _submitForm,
      child: const Text('Создать', 
        style: TextStyle(fontSize: 16)),
    ),
  );
}