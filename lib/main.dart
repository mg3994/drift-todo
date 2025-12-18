import 'package:flutter/material.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:go_router/go_router.dart';

import 'screens/home.dart';
import 'screens/search.dart';

void main() {
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is Trace) return stack.vmTrace;
    if (stack is Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'search',
            builder: (context, state) => const SearchPage(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Drift Todos',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        typography: Typography.material2018(),
      ),
      routerConfig: _router,
    );
  }
}
