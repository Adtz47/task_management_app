import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';

// Events
abstract class AuthEvent {}

class SignUpEvent extends AuthEvent {
  final String email, password;
  SignUpEvent({required this.email, required this.password});
}

class LoginEvent extends AuthEvent {
  final String email, password;
  LoginEvent({required this.email, required this.password});
}

class LogoutEvent extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  AuthSuccess(this.user);
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Handle Signup
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.signUp(event.email, event.password);
        emit(AuthSuccess(user!));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    // Handle Login
    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authRepository.login(event.email, event.password);
        emit(AuthSuccess(user!));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    // Handle Logout
    on<LogoutEvent>((event, emit) async {
    await authRepository.logout(); // Correct usage
    emit(AuthInitial());
    });

  }
}
