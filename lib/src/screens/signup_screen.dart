import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management_app/src/bloc/auth_bloc.dart';
import 'package:task_management_app/src/constants/image_strings.dart';
import 'package:task_management_app/src/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
              const SizedBox(height: 65),
              Center(child: Image(image: AssetImage(splash), height: size.height * 0.2)),
              Center(child: Text("Hey,", style: Theme.of(context).textTheme.headlineLarge)),
              Center(child: Text("Let's get started", style: Theme.of(context).textTheme.bodyLarge)),

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
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          labelText: "Password",
                          hintText: "Password",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.remove_red_eye_sharp),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                                      context.read<AuthBloc>().add(SignUpEvent(
                                            email: emailController.text,
                                            password: passwordController.text,
                                          ));
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // Button color
                                foregroundColor: Colors.white, // Text color
                              ),
                              child: state is AuthLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text("SIGNUP"),
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
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                          child: Text.rich(
                            TextSpan(
                              text: "Already have an Account?",
                              style: Theme.of(context).textTheme.bodyLarge,
                              children: const [
                                TextSpan(
                                  text: " Login",
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
