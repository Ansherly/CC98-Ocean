import 'dart:io';
import 'package:cc98_ocean/controls/app_shell.dart';
import 'package:cc98_ocean/core/kernel.dart';
import 'package:cc98_ocean/core/themes/app_themes.dart';
import 'package:cc98_ocean/core/themes/setting_controller.dart';
import 'package:cc98_ocean/pages/home.dart';
import 'package:cc98_ocean/pages/login.dart';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';

 void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb){
    if(Platform.isWindows||Platform.isMacOS||Platform.isLinux){
    await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden, // 隐藏默认标题栏
    size: Size(800, 600),
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  }
  }

  MediaKit.ensureInitialized();
  await AuthService().init();
  final bool isLoggedIn = await AuthService().isLoggedIn();
  runApp(CC98(isLoggedIn: isLoggedIn));
}

class CC98 extends StatelessWidget {
  final bool isLoggedIn;

  const CC98({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appStateProvider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CC98 Ocean',
          navigatorKey: AppShell.navigatorKey,
          builder: (context, child) => AppShell(
            // 壳挂在 Navigator 之外：push 二级页面时标题栏与侧栏始终可见
            child: child!,
            initiallyLoggedIn: isLoggedIn,
          ),
          theme: AppThemes.light.copyWith(
            colorScheme: AppThemes.light.colorScheme.copyWith(
              primary: appStateProvider.primaryColor,
            ),
          ),
          darkTheme: AppThemes.dark.copyWith(
            colorScheme: AppThemes.dark.colorScheme.copyWith(
              primary: appStateProvider.primaryColor,
            ),
          ),
          themeMode: appStateProvider.themeModeEnum,
          home: buildAppBody(isLoggedIn),
        ),
      ),
    );
  }
}


Widget buildAppBody(bool isLoggedIn){
  if(kIsWeb)return isLoggedIn?Home():Login();
  if(Platform.isAndroid||Platform.isIOS)return isLoggedIn?Home():Login();
  // 桌面端：标题栏与侧栏由 AppShell 提供，这里只决定根页面
  return  isLoggedIn?Home():Login();
}
