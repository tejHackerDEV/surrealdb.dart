import 'package:flutter/widgets.dart';

import '../../use_cases/sign_in.dart';
import '../view_model.dart';

class SignInPageViewModel extends ViewModel {
  final SignInUseCase _signInUseCase;

  SignInPageViewModel(this._signInUseCase);

  final connectionUriTextEditingController = TextEditingController();
  final userTextEditingController = TextEditingController();
  final passTextEditingController = TextEditingController();
  final nsTextEditingController = TextEditingController();
  final dbTextEditingController = TextEditingController();

  final isSigningIn = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    connectionUriTextEditingController.dispose();
    userTextEditingController.dispose();
    passTextEditingController.dispose();
    nsTextEditingController.dispose();
    dbTextEditingController.dispose();
  }

  Future<void> signIn() {
    isSigningIn.value = true;
    return _signInUseCase
        .call(
          connectionUri: connectionUriTextEditingController.text,
          user: userTextEditingController.text,
          pass: passTextEditingController.text,
          ns: nsTextEditingController.text,
          db: dbTextEditingController.text,
        )
        .whenComplete(() => isSigningIn.value = false);
  }
}
