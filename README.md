Task Management App

A Flutter-based mobile application for managing tasks with user authentication, priority sorting, and a clean UI.

Features:

User Authentication:- Login, signup functionality using Firebase Authentication.
Task Management:- Add, update, delete, and toggle task completion with Hive for local storage.
Priority Sorting:- Tasks sorted by due date (earliest to latest) with customizable priority levels (Low, Medium, High).
Responsive UI:- Clean design with animations and a sliding drawer.
Persistent Sessions:- Automatic login using Firebase session persistence.


Tech Stack:

Frontend:- Flutter (Dart)
State Management:- Bloc 
Backend:- Firebase Authentication
Local Storage:- Hive

Usage:

Login/Signup:- Use email and password to authenticate.
Add Tasks:- Click the FAB in HomeView, enter details, and set priority.
Manage Tasks:- Swipe to delete, tap to edit, or toggle completion.
Logout:- Use the logout button in the app bar.
