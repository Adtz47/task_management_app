// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../models/task.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/strings.dart';
import '../home/widgets/extensions.dart';

class TaskView extends StatefulWidget {
  final Task? task;

  const TaskView({Key? key, this.task}) : super(key: key);

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late TextEditingController taskControllerForTitle;
  late TextEditingController taskControllerForSubtitle;
  DateTime? time;
  DateTime? date;
  Priority? priority;

  @override
  void initState() {
    super.initState();
    taskControllerForTitle = TextEditingController(text: widget.task?.title ?? '');
    taskControllerForSubtitle = TextEditingController(text: widget.task?.subtitle ?? '');
    time = widget.task?.createdAtTime;
    date = widget.task?.createdAtDate;
    priority = widget.task?.priority ?? Priority.medium;
    print('TaskView initialized: Existing task? ${widget.task != null}');
  }

  @override
  void dispose() {
    taskControllerForTitle.dispose();
    taskControllerForSubtitle.dispose();
    super.dispose();
  }

  String showTime(DateTime? time) {
    if (time == null) return DateFormat('hh:mm a').format(DateTime.now());
    return DateFormat('hh:mm a').format(time);
  }

  DateTime showTimeAsDateTime(DateTime? time) {
    return time ?? DateTime.now();
  }

  String showDate(DateTime? date) {
    if (date == null) return DateFormat.yMMMEd().format(DateTime.now());
    return DateFormat.yMMMEd().format(date);
  }

  DateTime showDateAsDateTime(DateTime? date) {
    return date ?? DateTime.now();
  }

  bool isTaskAlreadyExistBool() {
    return widget.task != null;
  }

  void isTaskAlreadyExistUpdateTask(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    print('Add/Update button clicked');
    print('Controller values - Title: ${taskControllerForTitle.text}, Subtitle: ${taskControllerForSubtitle.text}, Priority: $priority');
    if (isTaskAlreadyExistBool()) {
      if (taskControllerForTitle.text.isNotEmpty && taskControllerForSubtitle.text.isNotEmpty) {
        widget.task!.title = taskControllerForTitle.text;
        widget.task!.subtitle = taskControllerForSubtitle.text;
        widget.task!.createdAtTime = time ?? widget.task!.createdAtTime;
        widget.task!.createdAtDate = date ?? widget.task!.createdAtDate;
        widget.task!.priority = priority ?? widget.task!.priority;
        print('Dispatching UpdateTask - ID: ${widget.task!.id}, Title: ${widget.task!.title}, Subtitle: ${widget.task!.subtitle}, Priority: ${widget.task!.priority}');
        context.read<TaskBloc>().add(UpdateTask(widget.task!));
        Navigator.pop(context);
      } else {
        print('Update failed: Title or subtitle empty');
        nothingEnterOnUpdateTaskMode(context);
      }
    } else {
      if (taskControllerForTitle.text.isNotEmpty && taskControllerForSubtitle.text.isNotEmpty) {
        print('Dispatching AddTask - Title: ${taskControllerForTitle.text}, Subtitle: ${taskControllerForSubtitle.text}, Priority: $priority, UserID: $userId');
        context.read<TaskBloc>().add(AddTask(
          taskControllerForTitle.text,
          taskControllerForSubtitle.text,
          time ?? DateTime.now(),
          date ?? DateTime.now(),
          userId,
          priority: priority,
        ));
        Navigator.pop(context);
      } else {
        print('Add failed: Title or subtitle empty');
        emptyFieldsWarning(context);
      }
    }
  }

  void deleteTask(BuildContext context) {
    if (widget.task != null) {
      print('Delete button clicked for task: ${widget.task!.id}');
      context.read<TaskBloc>().add(DeleteTask(widget.task!.id));
      Navigator.pop(context);
    } else {
      print('Delete failed: No task provided');
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const MyAppBar(),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTopText(textTheme),
                  _buildMiddleTextFieldsANDTimeAndDateSelection(context, textTheme),
                  _buildBottomButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isTaskAlreadyExistBool() ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
        children: [
          if (isTaskAlreadyExistBool())
            Container(
              width: 150,
              height: 55,
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.primaryColor, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: MaterialButton(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                minWidth: 150,
                height: 55,
                onPressed: () => deleteTask(context),
                color: Colors.white,
                child: Row(
                  children: const [
                    Icon(Icons.close, color: MyColors.primaryColor),
                    SizedBox(width: 5),
                    Text(MyString.deleteTask, style: TextStyle(color: MyColors.primaryColor)),
                  ],
                ),
              ),
            ),
          MaterialButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            minWidth: 150,
            height: 55,
            onPressed: () => isTaskAlreadyExistUpdateTask(context),
            color: MyColors.primaryColor,
            child: Text(
              isTaskAlreadyExistBool() ? MyString.updateTaskString : MyString.addTaskString,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _buildMiddleTextFieldsANDTimeAndDateSelection(BuildContext context, TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: 585,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(MyString.titleOfTitleTextField, style: textTheme.titleMedium),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: TextFormField(
                controller: taskControllerForTitle,
                maxLines: 6,
                cursorHeight: 60,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                onFieldSubmitted: (value) => FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: TextFormField(
                controller: taskControllerForSubtitle,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.bookmark_border, color: Colors.grey),
                  border: InputBorder.none,
                  counter: SizedBox(),
                  hintText: MyString.addNote,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              DatePicker.showTimePicker(
                context,
                showTitleActions: true,
                showSecondsColumn: false,
                onConfirm: (selectedTime) {
                  setState(() => time = selectedTime);
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                currentTime: showTimeAsDateTime(time),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(MyString.timeString, style: textTheme.titleSmall),
                  ),
                  Expanded(child: Container()),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 80,
                    height: 35,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade100),
                    child: Center(child: Text(showTime(time), style: textTheme.bodySmall)),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime.now(),
                maxTime: DateTime(2030, 3, 5),
                onConfirm: (selectedDate) {
                  setState(() => date = selectedDate);
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                currentTime: showDateAsDateTime(date),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(MyString.dateString, style: textTheme.titleSmall),
                  ),
                  Expanded(child: Container()),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 140,
                    height: 35,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.shade100),
                    child: Center(child: Text(showDate(date), style: textTheme.bodySmall)),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text('Priority', style: textTheme.titleSmall),
                ),
                Expanded(child: Container()),
                DropdownButton<Priority>(
                  value: priority,
                  items: Priority.values
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.toString().split('.').last.capitalize()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => priority = value);
                  },
                  underline: Container(),
                  padding: const EdgeInsets.only(right: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SizedBox _buildTopText(TextTheme textTheme) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 70, child: Divider(thickness: 2)),
          RichText(
            text: TextSpan(
              text: isTaskAlreadyExistBool() ? MyString.updateTaskString : MyString.addTaskString,
              style: textTheme.headlineMedium,
              children: const [TextSpan(text: MyString.taskStrnig, style: TextStyle(fontWeight: FontWeight.w400))],
            ),
          ),
          const SizedBox(width: 70, child: Divider(thickness: 2)),
        ],
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 30, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text("Task Details", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}