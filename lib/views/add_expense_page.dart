import 'package:daily_spending/controllers/expense_controller.dart';
import 'package:daily_spending/models/expense.dart';
import 'package:daily_spending/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AddExpensePage extends StatefulWidget {
  final ExpenseController controller;

  const AddExpensePage({Key? key, required this.controller}) : super(key: key);

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await widget.controller.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }

    value = value.trim().replaceAll(',', '.');

    if (!RegExp(r'^\d*\.?\d+$').hasMatch(value)) {
      return 'Digite apenas números (use ponto ou vírgula para decimais)';
    }

    double? price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'O valor deve ser maior que zero';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Gasto', style: TextStyle(color: Colors.white)),
        backgroundColor: AppStyles.primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: AppStyles.textFieldDecoration.copyWith(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description_outlined,
                      color: AppStyles.textSecondaryColor),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: AppStyles.textFieldDecoration.copyWith(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  prefixIcon: Icon(Icons.attach_money,
                      color: AppStyles.textSecondaryColor),
                ),
                validator: _validatePrice,
              ),
              SizedBox(height: 16),
              _buildCategorySection(),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitExpense,
                style: AppStyles.primaryButtonStyle,
                child: Text('SALVAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: AppStyles.textFieldDecoration.copyWith(
            labelText: 'Categoria',
            prefixIcon: Icon(Icons.category_outlined,
                color: AppStyles.textSecondaryColor),
          ),
          selectedItemBuilder: (BuildContext context) {
            return [
              ..._categories.map(
                  (category) => Text(category, style: AppStyles.bodyStyle)),
              Text('Nova categoria',
                  style: TextStyle(color: AppStyles.primaryColor)),
            ];
          },
          items: [
            ..._categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category, style: AppStyles.bodyStyle),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppStyles.textSecondaryColor,
                          size: 20,
                        ),
                        onPressed: () async {
                          Navigator.pop(context); // Fecha o dropdown
                          bool removed =
                              await widget.controller.removeCategory(category);
                          if (removed) {
                            final categories =
                                await widget.controller.getCategories();
                            setState(() {
                              _categories = categories;
                              if (_selectedCategory == category) {
                                _selectedCategory = null;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Categoria removida com sucesso'),
                                backgroundColor: AppStyles.successColor,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Não é possível remover uma categoria que possui gastos'),
                                backgroundColor: AppStyles.errorColor,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                )),
            DropdownMenuItem(
              value: 'new',
              child: Row(
                children: [
                  Icon(Icons.add_circle_outline, color: AppStyles.primaryColor),
                  SizedBox(width: 8),
                  Text('Nova categoria',
                      style: TextStyle(color: AppStyles.primaryColor)),
                ],
              ),
            ),
          ],
          onChanged: (value) {
            if (value == 'new') {
              _showAddCategoryDialog();
            } else {
              setState(() {
                _selectedCategory = value;
              });
            }
          },
          validator: (value) =>
              value == null ? 'Selecione uma categoria' : null,
        ),
      ],
    );
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nova Categoria', style: AppStyles.subheadingStyle),
        content: TextField(
          controller: controller,
          decoration: AppStyles.textFieldDecoration.copyWith(
            labelText: 'Nome da categoria',
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: AppStyles.secondaryButtonStyle,
            child: Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            style: AppStyles.primaryButtonStyle,
            child: Text('ADICIONAR'),
          ),
        ],
      ),
    );

    if (result != null) {
      await widget.controller.addCategory(result);
      await _loadCategories();
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: Uuid().v4(),
        description: _descriptionController.text,
        value: double.parse(_valueController.text.replaceAll(',', '.')),
        category: _selectedCategory!,
        date: DateTime.now(),
      );

      widget.controller.addExpense(expense).then((_) {
        Navigator.pop(context);
      });
    }
  }
}
