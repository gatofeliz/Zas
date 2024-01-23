import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  Future<void> loginUser() async {
    final dio = Dio();
    const url = 'https://zasok.com/api/login';

    // Validaciones
    if (emailController.text.isEmpty) {
      _showToast('Por favor, ingrese su correo electrónico.');
      return;
    }

    if (passwordController.text.length < 6) {
      _showToast('La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    if (passwordController.text.length > 50) {
      _showToast('La contraseña debe tener menos de 50 caracteres.');
      return;
    }

    if (!isValidEmail(emailController.text)) {
      _showToast('Por favor, ingrese un correo electrónico válido.');
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
          'email': emailController.text,
          'password': passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = response.data;
        print(userData);

        if (userData['status'] == true) {
          Map<String, dynamic> datosUsuario = userData['data'];
          print(datosUsuario);
          // ignore: use_build_context_synchronously
          Provider.of<UserProvider>(context, listen: false)
              .setUserData(userData);

          // ignore: use_build_context_synchronously
          context.go('/principal');
        } else {
          _showToast(response.data['message']);
        }
      } else {
        _showToast('Error al Iniciar Sesion');
      }
    } catch (e) {
      _showToast('Error intentando iniciar sesión');
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

  Widget _entryField(String title, {bool isPassword = false}) {
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
            controller: isPassword ? passwordController : emailController,
            obscureText: isPassword && _obscureText,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: const Color(0xfff3f3f4),
              filled: true,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
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
        onPressed: loginUser,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(236, 164, 140, 222)),
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        child: const Text(
          'Iniciar sesion',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: const Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('o'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _createAccountLabel() {
    return InkWell(
      onTap: () {
        context.go('/register');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'No tienes una cuenta ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Registrate',
              style: TextStyle(
                  color: Color.fromARGB(236, 164, 140, 222),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField("Correo"),
        _entryField("Contraseña", isPassword: true),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
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
                    const SizedBox(height: 100),
                    ClipOval(
                      child: Image.asset(
                        'assets/logo.jpeg',
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _emailPasswordWidget(),
                    const SizedBox(height: 20),
                    _submitButton(),
                    _divider(),
                    SizedBox(height: height * .01),
                    _createAccountLabel(),
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
