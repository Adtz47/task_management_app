import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_management_app/src/bloc/task/task_event.dart';
import 'src/bloc/auth_bloc.dart';
import 'src/bloc/task/task_bloc.dart';
import 'src/data/hive_data_store.dart';
import 'src/repository/auth_repository.dart';
import 'src/models/task.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/signup_screen.dart';
import 'src/view/home/home_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter<Task>(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>("tasksBox");

  final box = Hive.box<Task>("tasksBox");
  final hiveDataStore = HiveDataStore();
  await hiveDataStore.initHive();

  runApp(BaseWidget(dataStore: hiveDataStore, child: MyApp()));
}

class BaseWidget extends InheritedWidget {
  final HiveDataStore dataStore;

  BaseWidget({Key? key, required this.dataStore, required Widget child})
      : super(key: key, child: child);

  static BaseWidget of(BuildContext context, {bool listen = true}) {
    return listen
        ? context.dependOnInheritedWidgetOfExactType<BaseWidget>()!
        : context.getElementForInheritedWidgetOfExactType<BaseWidget>()!.widget as BaseWidget;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authRepository: AuthRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Hive Todo App',
        theme: ThemeData(
          textTheme: const TextTheme(
            headlineLarge: TextStyle(color: Colors.black, fontSize: 45, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w300),
            titleLarge: TextStyle(color: Colors.white, fontSize: 21),
            bodyMedium: TextStyle(color: Color.fromARGB(255, 234, 234, 234), fontSize: 14, fontWeight: FontWeight.w400),
            titleMedium: TextStyle(color: Colors.grey, fontSize: 17),
            titleSmall: TextStyle(color: Colors.grey, fontSize: 16),
            bodySmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            headlineMedium: TextStyle(fontSize: 40, color: Colors.black, fontWeight: FontWeight.w300),
          ),
          primarySwatch: Colors.blue,
        ),
        initialRoute: "/splash",
        routes: {
          "/splash": (context) => SplashScreen(),
          "/login": (context) => LoginScreen(),
          "/signup": (context) => SignupScreen(),
          "/home": (context) => BlocProvider(
            create: (context) => TaskBloc(
              BaseWidget.of(context, listen: false).dataStore, // Use listen: false
              FirebaseAuth.instance.currentUser!.uid,
            )..add(LoadTasks()),
            child: HomeView(),
          ),
        },
      ),
    );
  }
}