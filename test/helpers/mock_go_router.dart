import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockGoRouter extends Mock implements GoRouter {}

class MockGoRouterProvider extends StatelessWidget {
  const MockGoRouterProvider({
    super.key,
    required this.goRouter,
    required this.child,
  });
  final MockGoRouter goRouter;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      InheritedGoRouter(goRouter: goRouter, child: child);
}
