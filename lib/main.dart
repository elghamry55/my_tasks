// 1 main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tasks/features/home/splash_page/screens/splash.dart';
import 'core/themes.dart';
import 'cubit/task_cubit.dart';
import 'core/notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskCubit()..loadTasks(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyTasks',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const Splash(),
      ),
    );
  }
}
