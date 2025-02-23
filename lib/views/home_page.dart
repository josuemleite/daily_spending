import 'package:daily_spending/controllers/expense_controller.dart';
import 'package:daily_spending/models/expense.dart';
import 'package:daily_spending/utils/app_styles.dart';
import 'package:daily_spending/views/add_expense_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final ExpenseController controller;

  const HomePage({Key? key, required this.controller}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedPeriod = 'daily';
  List<String> _selectedCategories = [];
  List<Expense> _expenses = [];
  List<String> _availableCategories = [];
  double _totalAmount = 0;
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadExpenses();
  }

  Future<void> _loadCategories() async {
    final categories = await widget.controller.getCategories();
    setState(() {
      _availableCategories = categories;
    });
  }

  Future<void> _loadExpenses() async {
    final expenses =
        await widget.controller.getFilteredExpenses(_selectedPeriod);

    final filteredExpenses = _selectedCategories.isEmpty
        ? expenses
        : expenses
            .where((e) => _selectedCategories.contains(e.category))
            .toList();

    double total =
        filteredExpenses.fold(0, (sum, expense) => sum + expense.value);

    setState(() {
      _expenses = filteredExpenses;
      _totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title:
            Text('Controle de Gastos', style: TextStyle(color: Colors.white)),
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildCategoryFilter(),
          _buildTotalSection(),
          Expanded(child: _buildExpensesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddExpensePage(controller: widget.controller),
            ),
          );
          _loadExpenses();
        },
        backgroundColor: AppStyles.primaryColor,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: AppStyles.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por período:',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('Diário', 'daily'),
                _filterChip('Semanal', 'weekly'),
                _filterChip('Mensal', 'monthly'),
                _filterChip('Semestral', 'semiannual'),
                _filterChip('Anual', 'yearly'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Padding(
      padding: EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPeriod = value;
              _loadExpenses();
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppStyles.accentColor : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppStyles.accentColor : Colors.white,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por categorias:',
            style: AppStyles.labelStyle,
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDropdownOpen = !_isDropdownOpen;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppStyles.textSecondaryColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.category_outlined,
                            color: AppStyles.textSecondaryColor),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedCategories.isEmpty
                                ? 'Selecione as categorias'
                                : _selectedCategories.join(', '),
                            style: AppStyles.bodyStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          _isDropdownOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppStyles.textSecondaryColor,
                        ),
                      ],
                    ),
                  ),
                  if (_isDropdownOpen)
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: AppStyles.textSecondaryColor
                                  .withOpacity(0.3)),
                        ),
                      ),
                      child: Column(
                        children: _availableCategories.map((category) {
                          bool isSelected =
                              _selectedCategories.contains(category);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedCategories.remove(category);
                                } else {
                                  _selectedCategories.add(category);
                                }
                                _loadExpenses();
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: isSelected
                                        ? AppStyles.primaryColor
                                        : AppStyles.textSecondaryColor,
                                  ),
                                  SizedBox(width: 12),
                                  Text(category, style: AppStyles.bodyStyle),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total do período:',
            style: AppStyles.subheadingStyle,
          ),
          Text(
            'R\$ ${_totalAmount.toStringAsFixed(2)}',
            style: AppStyles.amountStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return Dismissible(
          key: Key(expense.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppStyles.errorColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (direction) async {
            await widget.controller.removeExpense(expense.id);
            setState(() {
              _expenses.removeAt(index);
              _totalAmount -= expense.value;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Gasto removido'),
                backgroundColor: AppStyles.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppStyles.cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppStyles.softShadow],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              title: Text(
                expense.description,
                style: AppStyles.cardTitleStyle,
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppStyles.accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        expense.category,
                        style: AppStyles.cardSubtitleStyle.copyWith(
                          color: AppStyles.accentColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy').format(expense.date),
                      style: AppStyles.cardSubtitleStyle,
                    ),
                  ],
                ),
              ),
              trailing: Text(
                'R\$ ${expense.value.toStringAsFixed(2)}',
                style: AppStyles.amountStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}
