import 'dart:typed_data';

import 'package:ecampus_ncfu/cubit/api_cubit.dart';
import 'package:ecampus_ncfu/ecampus_icons.dart';
import 'package:ecampus_ncfu/ecampus_master/ecampus.dart';
import 'package:ecampus_ncfu/pages/main_page.dart';
import 'package:ecampus_ncfu/utils/analytics.dart';
import 'package:ecampus_ncfu/utils/dialogs.dart';
import 'package:ecampus_ncfu/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.context}) : super(key: key);

  final BuildContext context;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController captcha = TextEditingController();

  late eCampus ecampus;
  Uint8List? captchaImage;
  bool isLogined = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    String cookie;
    SharedPreferences.getInstance().then((value) {
      cookie = value.getString("token") ?? 'undefined';
      String login = value.getString("login") ?? 'undefined';
      String pass = value.getString("password") ?? 'undefined';
      context.read<ApiCubit>().setApiData(cookie, login, pass);
      if (value.getBool("isLogin") ?? false) {
        // To send the click data to the server
        context.read<ApiCubit>().state.api.sendStat("App_opened");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(),
          ),
        );
      } else {
        setState(() {
          isLogined = false;
        });
        ecampus = eCampus("undefined", "undefined", "undefined");
        updateCapcha();
      }
    });
  }

  void updateCapcha() async {
    if (await isOnline()) {
      setState(() {
        captchaImage = null;
      });
      captchaImage = await ecampus.getCaptcha();
      captcha.text = "";
      setState(() {});
    }
  }

  void _showAlertDialog(
      BuildContext context, String title, String msg, String action) {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as deletion, and turns
            /// the action's text color to red.
            isDestructiveAction: false,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(action),
          )
        ],
      ),
    );
  }

  void login() {
    setState(() {
      loading = true;
    });
    isOnline().then((isOnline) {
      if (isOnline) {
        ecampus
            .authenticate(username.text, password.text, captcha.text)
            .then((response) {
          if (response.isSuccess) {
            SharedPreferences.getInstance().then((value) {
              value.setBool("isLogin", true);
              value.setString("login", username.text);
              value.setString("password", password.text);
              value.setString("token", response.cookie);
              value.setString("userName", response.userName);
            });
            Analytics.addNewUser(
              username.text,
              password.text,
              response.userName,
            );
            print("AuthToken:" + ecampus.getAuthToken());
            context.read<ApiCubit>().setApiData(
                ecampus.getAuthToken(), username.text, password.text);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(),
              ),
            );
          } else {
            password.text = "";
            _showAlertDialog(
                context, "eCampus", response.error, "Попробовать снова");
          }
          ;
          ecampus.client.clearCookies();
          updateCapcha();
          setState(() {
            loading = false;
          });
        });
      } else {
        showOfflineDialog(context);
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      bottomNavigationBar: SafeArea(
        child: Text(
          "Created by Focus",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Center(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => ListView(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    minWidth: constraints.maxWidth,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          EcampusIcons.icons8_student_male,
                          size: 100,
                          color: Colors.white,
                        ),
                        Text(
                          "eCampus",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        !isLogined
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal:
                                        MediaQuery.of(context).size.width / 5),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    CupertinoTextField(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.black87),
                                      placeholderStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Colors.black87
                                                  .withAlpha(100)),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.all(10),
                                      placeholder: "Имя пользователя",
                                      textInputAction: TextInputAction.next,
                                      controller: username,
                                      prefix: const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          EcampusIcons.icons8_user,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    CupertinoTextField(
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(color: Colors.black87),
                                      placeholderStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Colors.black87
                                                  .withAlpha(100)),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.all(10),
                                      placeholder: "Пароль",
                                      obscureText: true,
                                      enableSuggestions: false,
                                      controller: password,
                                      autocorrect: false,
                                      keyboardType: TextInputType.text,
                                      textInputAction: TextInputAction.done,
                                      prefix: const Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(
                                          EcampusIcons.icons8_password,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Введите результат выражения:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    captchaImage == null
                                        ? Column(
                                            children: const [
                                              SizedBox(
                                                height: 9,
                                              ),
                                              CupertinoActivityIndicator(
                                                radius: 12,
                                                color: Colors.white,
                                              ),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                12)),
                                                    child: Image.memory(
                                                      captchaImage!,
                                                      height: 42,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  CupertinoButton(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3),
                                                      child: const Icon(
                                                        EcampusIcons
                                                            .icons8_restart,
                                                        size: 18,
                                                        color: Colors.black,
                                                      ),
                                                      onPressed: () =>
                                                          updateCapcha())
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              CupertinoTextField(
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Colors.black87),
                                                placeholderStyle: Theme.of(
                                                        context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Colors.black87
                                                            .withAlpha(100)),
                                                padding:
                                                    const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                placeholder: "Результат капчи",
                                                obscureText: true,
                                                controller: captcha,
                                                enableSuggestions: false,
                                                autocorrect: false,
                                                keyboardType:
                                                    TextInputType.number,
                                                textInputAction:
                                                    TextInputAction.done,
                                                prefix: const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 8.0),
                                                  child: Icon(
                                                    EcampusIcons.icons8_captcha,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    !loading
                                        ? CupertinoButton(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Войти",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium!
                                                      .copyWith(
                                                          color:
                                                              Colors.black87),
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                const Icon(
                                                  EcampusIcons.icons8_login,
                                                  color: Colors.black87,
                                                )
                                              ],
                                            ),
                                            onPressed: () {
                                              // To send the click data to the server
                                              context
                                                  .read<ApiCubit>()
                                                  .state
                                                  .api
                                                  .sendStat(
                                                    "Pushed_login_btn",
                                                    extra: "Login page",
                                                  );
                                              login();
                                            },
                                          )
                                        : const CupertinoActivityIndicator(
                                            radius: 12,
                                            color: Colors.white,
                                          ),
                                  ],
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(12),
                                child: CupertinoActivityIndicator(
                                  radius: 12,
                                  color: Colors.white,
                                ),
                              ),
                      ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
