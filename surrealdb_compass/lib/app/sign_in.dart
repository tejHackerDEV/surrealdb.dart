import 'package:flutter/material.dart' hide Colors;

import 'res/colors.dart';
import 'res/strings.dart';
import 'widgets/my_rounded_elevated_button.dart';
import 'widgets/my_text_form_field.dart';
import 'widgets/surreal_db_text.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
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
                  const MyTextFormField(
                    hintText: Strings.connectionUriHint,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: const [
                      Expanded(
                        child: MyTextFormField(
                          hintText: Strings.userHint,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: MyTextFormField(
                          hintText: Strings.passwordHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: const [
                      Expanded(
                        child: MyTextFormField(
                          hintText: Strings.namespaceHint,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: MyTextFormField(
                          hintText: Strings.databaseHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      MyRoundedElevatedButton(),
                    ],
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
