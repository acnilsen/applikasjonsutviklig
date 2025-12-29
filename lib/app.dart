import 'package:flutter/material.dart';
import 'routes.dart';
import 'providers/app_state.dart';
import 'package:provider/provider.dart';


/// This is the root widget of the app.
/// It sets up the theme and routes.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return MaterialApp(
      title: 'Shopping App',
      debugShowCheckedModeBanner: false,
      themeMode: appState.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: Routes.home,
      routes: Routes.getRoutes(),
    );
  }
}
