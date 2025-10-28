import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shooka_flutter/components/splash_screen.dart';
import 'package:shooka_flutter/services/auth_service.dart';
import 'package:shooka_flutter/utils/buttons/container_button.dart';
import 'package:shooka_flutter/utils/consts/error_codes.dart';
import 'package:shooka_flutter/utils/loadings/loading.dart';
import 'package:shooka_flutter/utils/textfields/outline_textfield_with_label.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _loading = false;
  String _error = "";

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        //
        // Body
        //
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Center(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 45,
                    children: [
                      //
                      // Logo
                      //
                      Image.asset(
                        "assets/icons/romak-logo-blue.png",
                        width: 150,
                      ),

                      //
                      // Login TextFields And Button
                      //
                      Column(
                        spacing: 10,
                        children: [
                          Row(
                            children: [
                              Text(
                                "ورود به حساب کاربری",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),

                          // UserName
                          Outlinetextfieldwithlabel(
                            controller: usernameController,
                            placeHolder: "نام کاربری",
                            label: "نام کاربری:",
                          ),

                          //Password
                          Outlinetextfieldwithlabel(
                            isPassword: true,
                            controller: passwordController,
                            placeHolder: "رمزعبور",
                            label: "رمزعبور:",
                          ),

                          // Error Message
                          if (_error != "")
                            Row(
                              children: [
                                Text(
                                  _error.toString(),
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.apply(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                ),
                              ],
                            ),

                          SizedBox(height: 10),

                          // Login Button
                          ContainerButton(
                            fillWidth: true,
                            borderRadius: 10,
                            padding: EdgeInsets.all(15),
                            onPressed: _loading
                                ? null
                                : () async {
                                    setState(() {
                                      _loading = true;
                                      _error = "";
                                    });

                                    try {
                                      final ok = await auth.login(
                                        usernameController.text.trim(),
                                        passwordController.text,
                                      );
                                      if (ok) {
                                        await getHomePageData(context);
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/home',
                                        );
                                      } else {
                                        if (kDebugMode) {
                                          print(ok);
                                        }
                                        setState(() {
                                          _error =
                                              "نام کاربری یا رمز عبور اشتباه است.";
                                        });
                                      }
                                    } on DioException catch (e) {
                                      if (kDebugMode) print(e);

                                      // Checks Status Code
                                      setState(
                                        () => _error = errorCodeMessage(
                                          e.response?.statusCode,
                                        ),
                                      );
                                    } catch (e) {
                                      if (kDebugMode) print(e);
                                      setState(() {
                                        _error = "مشکلی پیش آمده.";
                                      });
                                    } finally {
                                      setState(() => _loading = false);
                                    }
                                  },

                            color: Theme.of(context).primaryColor,
                            child: _loading
                                ? Loading()
                                : Text(
                                    "ورود",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.apply(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
