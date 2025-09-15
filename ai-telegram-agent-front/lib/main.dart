import 'package:ai_telegram_agent_front/pages/chats/ui/chats.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/ui/chat.dart';
import 'package:ai_telegram_agent_front/pages/group_chat/ui/widgets/user_analytics.dart';
import 'package:ai_telegram_agent_front/pages/home/ui/home.dart';
import 'package:ai_telegram_agent_front/pages/settings/ui/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() async {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const Home();
      },
    ),
    GoRoute(
      path: '/chat',
      builder: (BuildContext context, GoRouterState state) {
        return const Chats();
      },
    ),
    GoRoute(
      path: '/group-chat',
      builder: (context, state) {
        final groupName = state.extra as String;
        return Chat(title: groupName);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) {
        return const Settings();
      },
    ),
    GoRoute(
      path: '/analytics',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return UserAnalytics(
          username: extra['username'] ?? '',
          chatName: extra['chatName'] ?? '',
        );
      },
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
    );
  }
}
