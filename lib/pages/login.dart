import 'dart:developer' as dev;

import 'package:cc98_ocean/controls/fluent_dialog.dart';
import 'package:cc98_ocean/controls/hyperlink_button.dart';
import 'package:cc98_ocean/controls/info_flower.dart';
import 'package:cc98_ocean/core/constants/color_tokens.dart';
import 'package:cc98_ocean/core/kernel.dart';
import 'package:cc98_ocean/pages/home.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    checkState();
  }

  Future<void> checkState() async {
    final loggedIn = await AuthService().isLoggedIn();
    dev.log(loggedIn.toString(), name: "应用状态");
    if (loggedIn) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _idController.text.trim();
    final password = _passwordController.text.trim();
    final result = await AuthService().loginAsync(username, password);

    if (!mounted) return;

    if (result.isError) {
      setState(() => _errorMessage = result.error!.message);
    } else {
      await AuthService().setLoginStatus(true);
      InfoFlower.showContent(context, child: Text("登录成功"));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Home()));
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  // 表单控制器
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 密码可见性
  bool _obscurePassword = true;

  // 登录状态
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildLayout(),
      bottomNavigationBar: buildOperation(),
    );
  }

  Widget buildLayout() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: buildTitle()),
            Expanded(flex: 4, child: buildInputField()),
            Expanded(flex: 1, child: buildButton()),
            Expanded(flex: 2, child: Center(child: buildTip())),
          ],
        ),
      ),
    );
  }

  Widget buildTitle() {
    return Column(
      children: [
        SizedBox(height: 36),
        const Text(
          'CC98 Ocean',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: ColorTokens.primaryLight,
          ),
        ),
        SizedBox(height: 8),
        const Text(
          '欢迎回家',
          style: TextStyle(
            fontSize: 16,
            color: ColorTokens.softGrey,
          ),
        ),
      ],
    );
  }

  Widget buildInputField() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _idController,
            decoration: const InputDecoration(
              labelText: '昵称',
              prefixIcon: Icon(FluentIcons.weather_sunny_20_regular),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入CC98昵称';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '密码',
              prefixIcon: Icon(FluentIcons.lock_open_20_regular),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? FluentIcons.eye_20_regular
                    : FluentIcons.eye_off_20_regular),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget buildButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : login,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              )
            : const Text("登录",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget buildTip() {
    return Card(
      elevation: 0,
      color: ColorTokens.dividerBlue,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(8)),
      child: Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Text(
          "欢迎使用浙江大学校内论坛CC98的跨平台客户端。在登录之前,请阅读并遵守论坛规则。",
          style: TextStyle(color: ColorTokens.softGrey),
        ),
      ),
    );
  }

  Widget buildOperation() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          HyperlinkButton(
            icon: FluentIcons.toolbox_16_regular,
            text: "文档",
            onPressed: () async {
              final bool loggedIn = await AuthService().getLoginStatus();
              showDialog(
                context: context,
                builder: (context) => FluentDialog.text(
                  title: loggedIn ? "已登录" : "未登录",
                  content: Text("调试"),
                  cancelText: "取消",
                  confirmText: "确认",
                ),
              );
            },
          ),
          SizedBox(
              height: 20,
              child: VerticalDivider(
                  width: 16, thickness: 1, color: ColorTokens.dividerBlue)),
          HyperlinkButton(
            icon: FluentIcons.home_16_regular,
            text: "主页",
            onPressed: () => launch("https://www.cc98.org/logon"),
          ),
        ],
      ),
    );
  }
}

Future<void> launch(String url) async {
  await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
    webViewConfiguration: const WebViewConfiguration(
      enableJavaScript: true,
      enableDomStorage: true,
    ),
    webOnlyWindowName: '_blank',
  );
}
