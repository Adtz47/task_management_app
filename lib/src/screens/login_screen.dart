import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management_app/src/bloc/auth_bloc.dart';
import 'package:task_management_app/src/constants/image_strings.dart';
import 'package:task_management_app/src/screens/forgot_password_screen.dart';
import 'package:task_management_app/src/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false; 

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Center(child: Image(image: AssetImage(splash), height: size.height * 0.2)),
              Center(child: Text("Welcome,", style: Theme.of(context).textTheme.headlineLarge)),
              Center(child: Text("Schedule your tasks", style: Theme.of(context).textTheme.bodyLarge)),

              Form(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_outlined),
                          labelText: "E-Mail",
                          hintText: "E-mail",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !_passwordVisible, 
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
                          hintText: "Password",
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off, 
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible; 
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                            );
                          },
                          child: Text("Forgot Password ?"),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: BlocConsumer<AuthBloc, AuthState>(
                          listener: (context, state) {
                            if (state is AuthSuccess) {
                              Navigator.pushReplacementNamed(context, "/home");
                            } else if (state is AuthFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.error)),
                              );
                            }
                          },
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(LoginEvent(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          ));
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: state is AuthLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text("LOGIN"),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(child: const Text("OR")),
                      const SizedBox(height: 20),
                      Center(
                        child: OutlinedButton.icon(
                          icon: Image(image: AssetImage(google), width: 50),
                          onPressed: () {},
                          label: Text("Sign-In with Google"),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupScreen()),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Don't have an Account?",
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: const [
                                TextSpan(
                                  text: " Signup",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}