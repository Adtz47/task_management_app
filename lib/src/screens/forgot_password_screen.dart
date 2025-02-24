import "package:flutter/material.dart";
import "package:task_management_app/src/constants/image_strings.dart";
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child:Container(
         // alignment: Alignment(0, 0),
          padding: EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 105),
              Center(child: Image(image: AssetImage(lock), height: size.height * 0.3,)),
              Center(child: Text("Hey,",style: Theme.of(context).textTheme.headlineLarge,)),
              Center(child: Text("Its gonna be okay",style: Theme.of(context).textTheme.bodyLarge,)),


              Form(child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person_outline_outlined),
                        labelText: "E-Mail",
                        hintText: "E-mail",
                        border: OutlineInputBorder()
                      ),
                    ),
                     
                    const SizedBox(height: 50),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: (){},
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Change button background color
                      foregroundColor: Colors.white, // Change text color
                        ),
                       child: Text("Send Link")),
                    ),
                    
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}