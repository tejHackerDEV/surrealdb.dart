import 'package:flutter/material.dart' hide Colors;
import 'package:go_router/go_router.dart';

import '../res/colors.dart';
import '../res/strings.dart';
import '../router/route_names.dart';
import '../widgets/my_rounded_elevated_button.dart';
import '../widgets/my_text_form_field.dart';
import '../widgets/surreal_db_text.dart';
import 'view_model.dart';

class SignInPage extends StatelessWidget {
  final SignInPageViewModel _viewModel;
  const SignInPage(
    this._viewModel, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: mediaQueryData.size.width * 0.5,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    Strings.newConnection,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    children: const [
                      Text(Strings.connectTo),
                      SizedBox(width: 4.0),
                      SurrealDBText(),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  const Text(
                    Strings.credentialsSignIn,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  MyTextFormField(
                    controller: _viewModel.connectionUriTextEditingController,
                    hintText: Strings.connectionUriHint,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: _viewModel.userTextEditingController,
                          hintText: Strings.userHint,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: MyTextFormField(
                          controller: _viewModel.passTextEditingController,
                          hintText: Strings.passwordHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: MyTextFormField(
                          controller: _viewModel.nsTextEditingController,
                          hintText: Strings.namespaceHint,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: MyTextFormField(
                          controller: _viewModel.dbTextEditingController,
                          hintText: Strings.databaseHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  ValueListenableBuilder(
                    valueListenable: _viewModel.isSigningIn,
                    builder: (_, value, child) {
                      if (value) return const SizedBox.shrink();
                      return child!;
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyRoundedElevatedButton(
                          Strings.connect,
                          onTap: () => _viewModel.signIn().then(
                                (_) => context.goNamed(
                                  AppRouteNames.dashboard,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
