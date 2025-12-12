import "package:flutter/material.dart";

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = _sampleCategories;
    final totalCategories = categories.length;
    final totalSpent = categories.fold<double>(0, (sum, c) => sum + c.spent);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            tooltip: 'Add Category',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showAddCategoryDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    title: 'Total Categories',
                    value: '$totalCategories',
                    icon: Icons.category,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    title: 'Total Spent',
                    value: _formatMoney(totalSpent),
                    icon: Icons.payments_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) =>
                  _buildCategoryCard(context, categories[index]),
            ),
          ],
        ),
      ),
    );
  }

  // SUMMARY CARD
  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final onColor = scheme.onSurface;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: onColor.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CATEGORY CARD
  Widget _buildCategoryCard(BuildContext context, _CategoryData data) {
    final scheme = Theme.of(context).colorScheme;
    final progress = (data.budget <= 0)
        ? 0.0
        : (data.spent / data.budget).clamp(0.0, 1.0);
    final percent = (data.budget <= 0)
        ? 0
        : ((data.spent / data.budget) * 100).clamp(0, 999).toInt();
    final progressColor = progress >= 1.0
        ? Colors.redAccent
        : (progress >= 0.75 ? Colors.orangeAccent : scheme.primary);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditCategoryDialog(context, data),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(data.icon, color: scheme.primary),
                  ),
                  const Spacer(),
                  Text(
                    '$percent%',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${data.transactions} transactions',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: progress,
                        backgroundColor: scheme.surfaceVariant,
                        color: progressColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatMoney(data.spent),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'of ${_formatMoney(data.budget)}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatMoney(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  // Shows the Add Category dialog
  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    int? selectedIconIndex;
    int selectedColorIndex = 0;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Add Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Subscriptions',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: selectedIconIndex,
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    hintText: 'Select icon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    for (int i = 0; i < _iconOptions.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Row(
                          children: [
                            Icon(_iconOptions[i].icon,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(_iconOptions[i].label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => selectedIconIndex = v),
                ),
              ),
              const SizedBox(height: 12),
              Text('Color', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < _colorOptions.length; i++)
                      GestureDetector(
                        onTap: () => setState(() => selectedColorIndex = i),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _colorOptions[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: i == selectedColorIndex
                                  ? theme.colorScheme.onSurface
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monthly Budget',
                  hintText: '0.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final budget = double.tryParse(budgetController.text) ?? 0.0;
              if (name.isEmpty || selectedIconIndex == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter name and select icon'),
                  ),
                );
                return;
              }
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Added "$name" with budget ${_formatMoney(budget)}'),
                ),
              );
            },
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  // Shows the Edit Category dialog
  Future<void> _showEditCategoryDialog(
      BuildContext context, _CategoryData data) async {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: data.name);
    final budgetController =
        TextEditingController(text: data.budget.toStringAsFixed(0));
    int selectedIconIndex = _iconOptions
        .indexWhere((opt) => opt.icon.codePoint == data.icon.codePoint);
    if (selectedIconIndex < 0) selectedIconIndex = 0;
    int selectedColorIndex = 0;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Edit Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<int>(
                  isExpanded: true,
                  value: selectedIconIndex,
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    for (int i = 0; i < _iconOptions.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Row(
                          children: [
                            Icon(_iconOptions[i].icon,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(_iconOptions[i].label),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (v) => setState(() => selectedIconIndex = v ?? 0),
                ),
              ),
              const SizedBox(height: 12),
              Text('Color', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (int i = 0; i < _colorOptions.length; i++)
                      GestureDetector(
                        onTap: () => setState(() => selectedColorIndex = i),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _colorOptions[i],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: i == selectedColorIndex
                                  ? theme.colorScheme.onSurface
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetController,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: false, decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monthly Budget',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final budget = double.tryParse(budgetController.text) ?? 0.0;
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a name')),
                );
                return;
              }
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Updated "$name" with budget ${_formatMoney(budget)}'),
                ),
              );
            },
            child: const Text('Update Category'),
          ),
        ],
      ),
    );
  }

  // Icon + Color options used in dialogs
  static final List<_IconOption> _iconOptions = [
    _IconOption('Food', Icons.restaurant),
    _IconOption('Transport', Icons.directions_car),
    _IconOption('Shopping', Icons.shopping_cart),
    _IconOption('Housing', Icons.home),
    _IconOption('Entertainment', Icons.movie),
    _IconOption('Utilities', Icons.lightbulb),
    _IconOption('Healthcare', Icons.local_hospital),
    _IconOption('Travel', Icons.flight),
    _IconOption('Education', Icons.school),
    _IconOption('Gifts', Icons.card_giftcard),
    _IconOption('Savings', Icons.savings),
  ];

  static final List<Color> _colorOptions = [
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.amber,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.lightBlue,
    Colors.indigo,
    Colors.blue,
    Colors.blueGrey,
  ];

  // Sample data for demonstration
  static final List<_CategoryData> _sampleCategories = [
    _CategoryData(
      name: 'Food & Dining',
      icon: Icons.restaurant,
      transactions: 18,
      spent: 245.80,
      budget: 400.00,
    ),
    _CategoryData(
      name: 'Transportation',
      icon: Icons.directions_car,
      transactions: 9,
      spent: 95.20,
      budget: 150.00,
    ),
    _CategoryData(
      name: 'Shopping',
      icon: Icons.shopping_cart,
      transactions: 12,
      spent: 310.40,
      budget: 500.00,
    ),
    _CategoryData(
      name: 'Housing',
      icon: Icons.home,
      transactions: 2,
      spent: 1200.00,
      budget: 1200.00,
    ),
    _CategoryData(
      name: 'Entertainment',
      icon: Icons.movie,
      transactions: 7,
      spent: 72.50,
      budget: 120.00,
    ),
    _CategoryData(
      name: 'Utilities',
      icon: Icons.lightbulb,
      transactions: 5,
      spent: 160.00,
      budget: 200.00,
    ),
    _CategoryData(
      name: 'Healthcare',
      icon: Icons.local_hospital,
      transactions: 3,
      spent: 60.00,
      budget: 150.00,
    ),
    _CategoryData(
      name: 'Travel',
      icon: Icons.flight,
      transactions: 4,
      spent: 520.00,
      budget: 800.00,
    ),
    _CategoryData(
      name: 'Education',
      icon: Icons.school,
      transactions: 2,
      spent: 200.00,
      budget: 350.00,
    ),
    _CategoryData(
      name: 'Gifts',
      icon: Icons.card_giftcard,
      transactions: 6,
      spent: 85.00,
      budget: 150.00,
    ),
    _CategoryData(
      name: 'Other',
      icon: Icons.category,
      transactions: 8,
      spent: 45.00,
      budget: 100.00,
    ),
  ];
}

class _CategoryData {
  final String name;
  final IconData icon;
  final int transactions;
  final double spent;
  final double budget;

  const _CategoryData({
    required this.name,
    required this.icon,
    required this.transactions,
    required this.spent,
    required this.budget,
  });
}

class _IconOption {
  final String label;
  final IconData icon;
  const _IconOption(this.label, this.icon);
}
