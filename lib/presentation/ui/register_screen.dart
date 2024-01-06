import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> registerUser() async {
    final dio = Dio();
    const url = 'https://zas.onta.com.mx/public/api/register';
    if (nameController.text.isEmpty) {
      _showToast('Por favor, ingrese su nombre.');
      return;
    }

    if (lastNameController.text.isEmpty) {
      _showToast('Por favor, ingrese su apellido.');
      return;
    }

    if (emailController.text.isEmpty) {
      _showToast('Por favor, ingrese su correo electrónico.');
      return;
    }

    if (passwordController.text.isEmpty) {
      _showToast('Por favor, ingrese su contraseña.');
      return;
    }

    try {
      final response = await dio.post(
        url,
        data: {
          "name": nameController.text,
          "lastname": lastNameController.text,
          "email": emailController.text,
          "password": passwordController.text,
          "password_confirmation": confirmPasswordController.text,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = response.data;
        print(userData);
        if (userData['status'] == true) {
          _showToast('Usuario registrado exitosamente');
          // ignore: use_build_context_synchronously
          context.go('/');
        } else {
          _showToast(userData['message']);
        }
      } else {
        
        _showToast('Error al registrar usuario');
      }
    } catch (e) {
      print(e);
      _showToast('Error intentando registrar usuario');
    }
  }

  bool isValidEmail(String email) {
    return email.contains('@');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: const InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: TextButton(
        onPressed: registerUser,
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color.fromARGB(236, 164, 140, 222)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        child: const Text(
          'Registrar',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _registerFormWidget() {
    return Column(
      children: <Widget>[
        _entryField("Nombre", nameController),
        _entryField("Apellido", lastNameController),
        _entryField("Correo", emailController),
        _entryField("Contraseña", passwordController, isPassword: true),
        _entryField("Confirmar contraseña", confirmPasswordController, isPassword: true)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () { 
            context.go('/');
           },
          icon: const Icon(Icons.arrow_back),
          ),
      ),
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Text(
                        'Registro',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _registerFormWidget(),
                    const SizedBox(height: 20),
                    _submitButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}