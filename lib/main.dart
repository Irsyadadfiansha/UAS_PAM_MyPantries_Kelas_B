import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/services/storage_service.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const EaThinkAppLoader(),
    ),
  );
}


class EaThinkAppLoader extends ConsumerStatefulWidget {
  const EaThinkAppLoader({super.key});

  @override
  ConsumerState<EaThinkAppLoader> createState() => _EaThinkAppLoaderState();
}

class _EaThinkAppLoaderState extends ConsumerState<EaThinkAppLoader> {
  @override
  void initState() {
    super.initState();
  
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const EaThinkApp();
  }
}
