import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/strings.dart';
import 'widgets/task_widget.dart';
import '../../view/tasks/task_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GlobalKey<SliderDrawerState> dKey = GlobalKey<SliderDrawerState>();

  int checkDoneTask(List<Task> tasks) {
    return tasks.where((task) => task.isCompleted).length;
  }

  dynamic valueOfTheIndicator(List<Task> tasks) {
    return tasks.isNotEmpty ? tasks.length : 3;
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        print('BlocBuilder state: $state');
        List<Task> tasks = [];
        if (state is TaskLoaded) {
          tasks = state.tasks;
        } else if (state is TaskLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state is TaskError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }

        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FAB(context: context),
          body: SliderDrawer(
            isDraggable: false,
            key: dKey,
            animationDuration: 1000,
            appBar: MyAppBar(drawerKey: dKey, tasks: tasks),
            slider: MySlider(),
            child: _buildBody(tasks, textTheme, context),
          ),
        );
      },
    );
  }

  SizedBox _buildBody(List<Task> tasks, TextTheme textTheme, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(55, 0, 0, 0),
            width: double.infinity,
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation(MyColors.primaryColor),
                    backgroundColor: Colors.grey,
                    value: checkDoneTask(tasks) / valueOfTheIndicator(tasks),
                  ),
                ),
                const SizedBox(width: 25),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(MyString.mainTitle, style: textTheme.headlineLarge),
                    const SizedBox(height: 3),
                    Text("${checkDoneTask(tasks)} of ${tasks.length} task", style: textTheme.bodyLarge),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Divider(thickness: 2, indent: 100),
          ),
          SizedBox(
            width: double.infinity,
            height: 585,
            child: tasks.isNotEmpty
                ? ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      var task = tasks[index];
                      return Dismissible(
                        direction: DismissDirection.horizontal,
                        background: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.delete_outline, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(MyString.deletedTask, style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        onDismissed: (direction) {
                          context.read<TaskBloc>().add(DeleteTask(task.id));
                        },
                        key: Key(task.id),
                        child: TaskWidget(task: task),
                      );
                    },
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeIn(
                        child: SizedBox(
                          width: 200,
                          height: 200,
                          child: Lottie.asset(lottieURL, animate: true),
                        ),
                      ),
                      FadeInUp(from: 30, child: const Text(MyString.doneAllTask)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class MySlider extends StatelessWidget {
  MySlider({Key? key}) : super(key: key);
  final List<IconData> icons = [CupertinoIcons.home, CupertinoIcons.person_fill, CupertinoIcons.settings, CupertinoIcons.info_circle_fill];
  final List<String> texts = ["Home", "Profile", "Settings", "Details"];

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 90),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: MyColors.primaryGradientColor, begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/img/main.png')),
          const SizedBox(height: 8),
          Text("Aditya Kumar Gour", style: textTheme.titleLarge),
          Text("Flutter developer", style: textTheme.bodyMedium),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            width: double.infinity,
            height: 300,
            child: ListView.builder(
              itemCount: icons.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (ctx, i) => InkWell(
                onTap: () => print("$i Selected"),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  child: ListTile(
                    leading: Icon(icons[i], color: Colors.white, size: 30),
                    title: Text(texts[i], style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey<SliderDrawerState> drawerKey;
  final List<Task> tasks;

  const MyAppBar({Key? key, required this.drawerKey, required this.tasks}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  State<MyAppBar> createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
      if (isDrawerOpen) {
        controller.forward();
        widget.drawerKey.currentState!.openSlider();
      } else {
        controller.reverse();
        widget.drawerKey.currentState!.closeSlider();
      }
    });
  }

  void deleteAllTasks(BuildContext context) {
    if (widget.tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tasks to delete')),
      );
    } else {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete All Tasks'),
          content: const Text('Are you sure you want to delete all tasks?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('Delete button clicked in dialog');
                if (context.read<TaskBloc>() != null) {
                  print('TaskBloc found');
                  context.read<TaskBloc>().add(DeleteAllTasks());
                  Navigator.pop(dialogContext);
                } else {
                  print('TaskBloc not found');
                }
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  }

  void logout(BuildContext context) {
    print('Logout button clicked');
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 132,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: controller, size: 40),
                onPressed: toggle,
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () => deleteAllTasks(context),
                    child: const Icon(CupertinoIcons.trash, size: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () => logout(context),
                    child: const Icon(Icons.logout, size: 40),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FAB extends StatelessWidget {
  final BuildContext context;

  const FAB({Key? key, required this.context}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(this.context).push(
          CupertinoPageRoute(
            builder: (context) => BlocProvider.value(
              value: BlocProvider.of<TaskBloc>(this.context),
              child: TaskView(task: null),
            ),
          ),
        );
      },
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 10,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(color: MyColors.primaryColor, borderRadius: BorderRadius.circular(15)),
          child: const Center(child: Icon(Icons.add, color: Colors.white)),
        ),
      ),
    );
  }
}