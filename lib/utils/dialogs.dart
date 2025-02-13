// ignore_for_file: use_build_context_synchronously

import 'dart:typed_data';

import 'package:ecampus_ncfu/cubit/api_cubit.dart';
import 'package:ecampus_ncfu/ecampus_master/ecampus.dart';
import 'package:ecampus_ncfu/ecampus_master/responses.dart';
import 'package:ecampus_ncfu/utils/analytics.dart';
import 'package:ecampus_ncfu/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_store/open_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../ecampus_icons.dart';

void showConfirmDialog(BuildContext context, String title, String msg,
    void Function() confirmAction) {
  showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: false,
          onPressed: confirmAction,
          child: const Text("Подтверить"),
        ),
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            // To send to the server about the button response
            context.read<ApiCubit>().state.api.sendStat(
                "Pushed_cancel_btn_cupertino_dialog",
                extra: "Главная страница");

            Navigator.pop(context);
          },
          child: const Text("Отменить"),
        )
      ],
    ),
  );
}

void showUpdateDialog(BuildContext context, String version) {
  showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text(
        "Обновление",
      ),
      content: Text(
        "Доступно новая версия $version. Обновите приложение!",
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: false,
          onPressed: () {
            // To send to the server about the button response
            context.read<ApiCubit>().state.api.sendStat(
                  "Pushed_updated_btn_cup_dialog",
                  extra: "undefined",
                );

            OpenStore.instance.open(
              appStoreId: '1644613830',
              androidAppBundleId: 'uz.mqsoft.ecampusncfu',
            );
          },
          child: const Text(
            "Обновить",
          ),
        ),
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            // To send to the server about the button response
            context.read<ApiCubit>().state.api.sendStat(
                  "Pushed_later_btn",
                  extra: "undefined",
                );

            Navigator.pop(context);
          },
          child: const Text(
            "Позже",
          ),
        )
      ],
    ),
  );
}

void showOfflineDialog(BuildContext context) {
  showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text("Нет подключение"),
      content: const Text(
          "Не удалось подключится к серверу. Проверьте подключение  интернету и попробуйте снова."),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: false,
          onPressed: () {
            // To send to the server about the button response
            context.read<ApiCubit>().state.api.sendStat(
                  "Pushed_ok_btn",
                  extra: "undefined",
                );

            Navigator.pop(context);
          },
          child: const Text("Окей"),
        ),
      ],
    ),
  );
}

void showCapchaDialog(BuildContext context, Uint8List captchaImage,
    eCampus ecampus, Function successCallBack) {
  TextEditingController captcha = TextEditingController();
  showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) => CupertinoAlertDialog(
      title: const Text("eCampus"),
      content: Center(
        child: Column(children: [
          Text(
            "Введите результат выражения:",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(
            height: 3,
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Image.memory(
                      captchaImage,
                      height: 42,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              CupertinoTextField(
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.black87),
                placeholderStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.black87.withAlpha(100)),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                placeholder: "Результат капчи",
                controller: captcha,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    EcampusIcons.icons8_captcha,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(dialogContext);
            showLoadingDialog(context);
            // ignore: avoid_print
            print(captcha.text);
            SharedPreferences sPref = await SharedPreferences.getInstance();
            AuthenticateResponse response = await ecampus.authenticate(
                sPref.getString("login") ?? "",
                sPref.getString("password") ?? "",
                captcha.text);
            if (response.isSuccess) {
              Analytics.updateUserData(sPref.getString("login") ?? "default",
                  sPref.getString("password") ?? "default", response.userName);
              sPref.setString("token", response.cookie).then((value) => {
                    Navigator.pop(context),
                    successCallBack(),
                  });
            } else {
              if (await isOnline()) {
                ecampus.getCaptcha().then((value) => {
                      Navigator.pop(context),
                      showCapchaDialog(
                          context, value, ecampus, successCallBack),
                    });
              } else {
                showOfflineDialog(context);
              }
            }
          },
          child: const Text("Подтверить"),
        ),
        CupertinoDialogAction(
          /// This parameter indicates the action would perform
          /// a destructive action such as deletion, and turns
          /// the action's text color to red.
          isDestructiveAction: true,
          onPressed: () {
            // To send to the server about the button response
            context.read<ApiCubit>().state.api.sendStat(
                  "Pushed_cancel_btn",
                  extra: "undefined",
                );

            Navigator.pop(context);
          },
          child: const Text("Отменить"),
        )
      ],
    ),
  );
}

void showLoadingDialog(BuildContext context) {
  showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Shimmer.fromColors(
        period: const Duration(milliseconds: 1000),
        baseColor: Theme.of(context).secondaryHeaderColor,
        highlightColor: Colors.grey[400]!,
        child: Text(
          "Загрузка...",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      content: const Center(
        child: Column(
          children: [
            SizedBox(
              height: 12,
            ),
            CupertinoActivityIndicator(
              radius: 12,
            )
          ],
        ),
      ),
    ),
  );
}

void showAlertDialog(BuildContext context, String title, String message) {
  showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: false,
          onPressed: () {
            // To send to the server about the button response
            context.read<ApiCubit>().state.api.sendStat(
                  "Pushed_ok_btn",
                  extra: "undefined",
                );

            Navigator.pop(context);
          },
          child: const Text("Окей"),
        ),
      ],
    ),
  );
}
