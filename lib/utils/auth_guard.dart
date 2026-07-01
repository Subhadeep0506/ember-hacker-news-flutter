import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/view_models/auth_view_model.dart';
import '../presentation/widgets/login_dialog.dart';

Future<bool> ensureLoggedIn(BuildContext context, WidgetRef ref) async {
  final auth = ref.read(authViewModelProvider);
  if (auth.isLoggedIn) return true;

  final result = await showLoginDialog(context, ref);
  return result ?? false;
}
