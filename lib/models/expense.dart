class Expense {
  final String id;
  final String description;
  final double value;
  final String category;
  final DateTime date;

  Expense({
    required this.id,
    required this.description,
    required this.value,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'value': value,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      value: json['value'],
      category: json['category'],
      date: DateTime.parse(json['date']),
    );
  }
}
