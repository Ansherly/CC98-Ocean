# CC98 Ocean —— 项目长期笔记

## 项目概况

- Flutter 桌面应用(3.32.8 stable / Dart 3.8.1),是浙江大学校内论坛 CC98 的跨平台客户端。
- 主要原生插件:`media_kit`(+libmpv)、`window_manager`、`audioplayers`、`flutter_secure_storage`、
  `url_launcher`、`shared_preferences`、`screen_retriever`、`volume_controller`。
- 入口 `lib/main.dart`:启动时初始化 `windowManager`(隐藏标题栏,800×600,居中)与 `MediaKit`,
  再按 `AuthService().isLoggedIn()` 决定进登录页还是主页。
- 目录:`lib/core`(kernel/主题/常量)、`lib/pages`、`lib/controls`、`lib/ubb_text_block`。

## 本机工具链约定(重要)

- Flutter SDK:`D:\Flutter\flutter`;Visual Studio Community 2026 18.10,在 `D:\VS\IDE`;
  自带 CMake 4.3.1 在 `D:\VS\IDE\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe`。
- 系统是 Windows Insider 版本,只有 VS 2026,**没有** VS 2019/2022。
- 因此 Flutter 官方 3.32.8 不认识 VS 2026(主版本 18),需要对 SDK 打补丁 —— 见下。

## 对 Flutter SDK 的本地补丁(升级后需重新打)

`D:\Flutter\flutter\packages\flutter_tools\lib\src\windows\visual_studio.dart`

- `cmakeGenerator` 增加 `18 => 'Visual Studio 18 2026',`(否则回退到不存在的 VS 2019 生成器)。
- `_requiredComponents` 增加 `case 18:` / `case 17:` 的 MSVC 文案分支。

补丁后必须删除 `bin/cache/flutter_tools.snapshot` 与 `flutter_tools.stamp` 再跑任意 flutter 命令,
否则工具快照不会重建(compilekey 只看 git revision,不感知源码改动)。

## 本项目的 windows/CMakeLists.txt 本地改动

1. 紧跟 `add_definitions(-DUNICODE -D_UNICODE)` 加了
   `add_definitions(-D_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)`
   —— MSVC 14.51 把 `<experimental/coroutine>` 变成硬错误,`audioplayers_windows` 会踩到。
   位置必须在 `include(flutter/generated_plugins.cmake)` 之前。
2. 安装前缀守卫加了一条 `OR CMAKE_INSTALL_PREFIX STREQUAL "C:/Program Files/${PROJECT_NAME}"`,
   防止 configure 中途失败毒化缓存后,install 步骤一直往 Program Files 写文件而权限被拒。

## 构建/调试注意事项

- 网络受限:GitHub Release 直连会被截断。下载依赖必须 `curl -L --ssl-no-revoke`
  (不加会报 `CRYPT_E_NO_REVOCATION_CHECK`)。
- `media_kit_libs_windows_video` 的 `mpv-dev-*.7z` 和 `ANGLE.7z` 缓存在 `build/windows/x64/` 根目录,
  执行 `flutter clean` 后需要重新下载;MD5 见该插件 `windows/CMakeLists.txt`。
- 遇到 `MSB3073` 这类被刷屏淹没的 MSBuild 错误,直接手动跑
  `cmake -DBUILD_TYPE=Debug -P cmake_install.cmake` 取原始报错。
- `Policy CMP0175 is not set` 之类的 add_custom_command 警告来自 media_kit 插件,是上游问题,可忽略。
- 调试:`flutter run -d windows --debug`,成功标志是打印出
  `A Dart VM Service on Windows is available at: ...`。

## 可复用工具

- `build/shot_cc98.py` —— 按进程名找 Flutter(Win32)窗口并用 `PrintWindow(PW_RENDERFULLCONTENT)`
  非侵入截图,无需抢焦点。必须先 `SetProcessDpiAwarenessContext(PER_MONITOR_AWARE_V2)`,
  否则坐标被虚拟化、截图右侧与下方会被裁掉,误判成"UI 溢出"。
  注意新版 Windows 已移除 `wmic`,取 PID 要用 `OpenProcess` + `QueryFullProcessImageNameW`。
