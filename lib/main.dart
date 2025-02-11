import 'package:daily_spending/controllers/expense_controller.dart';
import 'package:daily_spending/utils/app_styles.dart';
import 'package:daily_spending/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final expenseController = ExpenseController(prefs);

  runApp(MyApp(expenseController: expenseController));
}

class MyApp extends StatelessWidget {
  final ExpenseController expenseController;

  const MyApp({Key? key, required this.expenseController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Gastos',
      theme: ThemeData(
        primaryColor: AppStyles.primaryColor,
        scaffoldBackgroundColor: AppStyles.backgroundColor,
      ),
      home: HomePage(controller: expenseController),
    );
  }
}
