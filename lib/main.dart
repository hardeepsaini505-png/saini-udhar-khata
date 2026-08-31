import 'package:flutter/material.dart';

void main() {
  runApp(const SainiUdharKhataApp());
}

class SainiUdharKhataApp extends StatelessWidget {
  const SainiUdharKhataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAINI Udhar Khata',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF12305B),
          primary: const Color(0xFF12305B),
          secondary: const Color(0xFF2E6B2D),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: const HomePage(),
    );
  }
}

// ======================= MODELS =======================

enum TransactionType { udhar, payment }

enum EntryCategory { product, service }

class KhataTransaction {
  final String id;
  final DateTime date;
  final TransactionType type;
  final EntryCategory? category;
  final String itemName;
  final double quantity;
  final double rate;
  final double amount;
  final String note;
  final String paymentMode;

  KhataTransaction({
    required this.id,
    required this.date,
    required this.type,
    this.category,
    required this.itemName,
    required this.quantity,
    required this.rate,
    required this.amount,
    this.note = '',
    this.paymentMode = 'Cash',
  });
}

class Customer {
  final String id;
  String name;
  String mobile;
  String address;
  double openingBalance;
  final List<KhataTransaction> transactions;

  Customer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.address,
    this.openingBalance = 0,
    List<KhataTransaction>? transactions,
  }) : transactions = transactions ?? [];

  double get totalUdhar {
    return openingBalance +
        transactions
            .where((e) => e.type == TransactionType.udhar)
            .fold(0, (sum, e) => sum + e.amount);
  }

  double get totalPayment {
    return transactions
        .where((e) => e.type == TransactionType.payment)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get balance => totalUdhar - totalPayment;
}

class MasterItem {
  String name;
  EntryCategory category;
  double rate;

  MasterItem({
    required this.name,
    required this.category,
    required this.rate,
  });
}

// ======================= HOME =======================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Customer> customers = [];
  final List<MasterItem> masterItems = [
    MasterItem(
      name: 'Computer Repair',
      category: EntryCategory.service,
      rate: 500,
    ),
    MasterItem(
      name: 'Printer Repair',
      category: EntryCategory.service,
      rate: 400,
    ),
    MasterItem(
      name: 'Mouse',
      category: EntryCategory.product,
      rate: 300,
    ),
  ];

  int selectedIndex = 0;
  String searchText = '';

  double get totalUdhar =>
      customers.fold(0, (sum, customer) => sum + customer.totalUdhar);

  double get totalReceived =>
      customers.fold(0, (sum, customer) => sum + customer.totalPayment);

  double get totalPending =>
      customers.fold(0, (sum, customer) => sum + customer.balance);

  List<Customer> get filteredCustomers {
    if (searchText.trim().isEmpty) return customers;
    final query = searchText.toLowerCase();
    return customers
        .where(
          (c) =>
              c.name.toLowerCase().contains(query) ||
              c.mobile.toLowerCase().contains(query),
        )
        .toList();
  }

  void addCustomer(Customer customer) {
    setState(() => customers.add(customer));
  }

  void deleteCustomer(Customer customer) {
    setState(() => customers.remove(customer));
  }

  void addMasterItem(MasterItem item) {
    setState(() => masterItems.add(item));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      _buildCustomers(),
      _buildItems(),
      _buildReports(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12305B),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
  'assets/images/app_logo.png',
  width: 45,
  height: 45,
),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAINI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'UDHAR KHATA',
                  style: TextStyle(fontSize: 10, letterSpacing: 1),
                ),
              ],
            ),
          ],
        ),
      ),
      body: pages[selectedIndex],
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () async {
                final customer = await Navigator.push<Customer>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddCustomerPage(),
                  ),
                );
                if (customer != null) addCustomer(customer);
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Customer Add'),
            )
          : selectedIndex == 2
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    final item = await Navigator.push<MasterItem>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddItemPage(),
                      ),
                    );
                    if (item != null) addMasterItem(item);
                  },
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Item Add'),
                )
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() => selectedIndex = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Customers',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Items',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'नमस्ते 👋',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'SAINI Udhar Khata',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'कुल उधार',
                  value: totalUdhar,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'कुल प्राप्त',
                  value: totalReceived,
                  icon: Icons.payments_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            title: 'कुल बकाया',
            value: totalPending,
            icon: Icons.warning_amber_rounded,
            large: true,
          ),
          const SizedBox(height: 24),
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickButton(
                icon: Icons.person_add_alt_1,
                label: 'Customer Add',
                onTap: () async {
                  final customer = await Navigator.push<Customer>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddCustomerPage(),
                    ),
                  );
                  if (customer != null) addCustomer(customer);
                },
              ),
              _QuickButton(
                icon: Icons.receipt_long,
                label: 'Khata Entry',
                onTap: () {
                  if (customers.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('पहले Customer Add करें'),
                      ),
                    );
                    return;
                  }
                  setState(() => selectedIndex = 1);
                },
              ),
              _QuickButton(
                icon: Icons.inventory,
                label: 'Item Master',
                onTap: () => setState(() => selectedIndex = 2),
              ),
              _QuickButton(
                icon: Icons.bar_chart,
                label: 'Reports',
                onTap: () => setState(() => selectedIndex = 3),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'सबसे ज्यादा Pending',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (customers.isEmpty)
            _EmptyBox(
              icon: Icons.people_outline,
              text: 'अभी कोई Customer नहीं है',
            )
          else
            ...([...customers]
                  ..sort((a, b) => b.balance.compareTo(a.balance)))
                .take(5)
                .map(
                  (customer) => Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          customer.name.isEmpty
                              ? '?'
                              : customer.name[0].toUpperCase(),
                        ),
                      ),
                      title: Text(customer.name),
                      subtitle: Text(customer.mobile),
                      trailing: Text(
                        '₹${customer.balance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => _openCustomer(customer),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCustomers() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (value) => setState(() => searchText = value),
            decoration: InputDecoration(
              hintText: 'नाम या मोबाइल नंबर से Search करें',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() => searchText = ''),
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredCustomers.isEmpty
              ? _EmptyBox(
                  icon: Icons.person_add_alt_1,
                  text: searchText.isEmpty
                      ? 'अभी कोई Customer नहीं है\nनीचे Customer Add करें'
                      : 'कोई Customer नहीं मिला',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 25,
                          child: Text(
                            customer.name.isEmpty
                                ? '?'
                                : customer.name[0].toUpperCase(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Text(
                          customer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${customer.mobile}\nउधार: ₹${customer.totalUdhar.toStringAsFixed(0)} | जमा: ₹${customer.totalPayment.toStringAsFixed(0)}',
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'बाकी',
                              style: TextStyle(fontSize: 11),
                            ),
                            Text(
                              '₹${customer.balance.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _openCustomer(customer),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildItems() {
    return masterItems.isEmpty
        ? _EmptyBox(
            icon: Icons.inventory_2_outlined,
            text: 'कोई Item / Service Add नहीं है',
          )
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            itemCount: masterItems.length,
            itemBuilder: (context, index) {
              final item = masterItems[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      item.category == EntryCategory.product
                          ? Icons.shopping_bag_outlined
                          : Icons.build_outlined,
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    item.category == EntryCategory.product
                        ? 'Product'
                        : 'Service',
                  ),
                  trailing: Text(
                    '₹${item.rate.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildReports() {
    final pending = [...customers]
      ..sort((a, b) => b.balance.compareTo(a.balance));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Reports',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _ReportRow(
          title: 'Total Customers',
          value: customers.length.toString(),
          icon: Icons.people,
        ),
        _ReportRow(
          title: 'Total Udhar',
          value: '₹${totalUdhar.toStringAsFixed(0)}',
          icon: Icons.arrow_upward,
        ),
        _ReportRow(
          title: 'Total Payment Received',
          value: '₹${totalReceived.toStringAsFixed(0)}',
          icon: Icons.arrow_downward,
        ),
        _ReportRow(
          title: 'Total Pending',
          value: '₹${totalPending.toStringAsFixed(0)}',
          icon: Icons.account_balance_wallet,
        ),
        const SizedBox(height: 20),
        const Text(
          'Customer-wise Pending',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...pending.map(
          (customer) => Card(
            child: ListTile(
              title: Text(customer.name),
              subtitle: Text(customer.mobile),
              trailing: Text(
                '₹${customer.balance.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCustomer(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailPage(
          customer: customer,
          masterItems: masterItems,
          onDelete: () => deleteCustomer(customer),
        ),
      ),
    );
    setState(() {});
  }
}

// ======================= CUSTOMER DETAIL =======================

class CustomerDetailPage extends StatefulWidget {
  final Customer customer;
  final List<MasterItem> masterItems;
  final VoidCallback onDelete;

  const CustomerDetailPage({
    super.key,
    required this.customer,
    required this.masterItems,
    required this.onDelete,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  @override
  Widget build(BuildContext context) {
    final transactions = [...widget.customer.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'delete',
                child: Text('Customer Delete'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showEntryOptions,
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Text(
                    widget.customer.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.customer.mobile),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MiniAmount(
                        label: 'कुल उधार',
                        amount: widget.customer.totalUdhar,
                      ),
                      _MiniAmount(
                        label: 'जमा',
                        amount: widget.customer.totalPayment,
                      ),
                      _MiniAmount(
                        label: 'बाकी',
                        amount: widget.customer.balance,
                        bold: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Khata History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (widget.customer.openingBalance > 0)
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.account_balance),
                ),
                title: const Text('Opening Balance'),
                subtitle: const Text('पुराना बकाया'),
                trailing: Text(
                  '₹${widget.customer.openingBalance.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (transactions.isEmpty)
            _EmptyBox(
              icon: Icons.receipt_long,
              text: 'अभी कोई Transaction नहीं है',
            )
          else
            ...transactions.map(
              (transaction) => _TransactionTile(
                transaction: transaction,
              ),
            ),
        ],
      ),
    );
  }

  void _showEntryOptions() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              runSpacing: 10,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.add_shopping_cart),
                  ),
                  title: const Text('उधार / Item / Service Add'),
                  subtitle: const Text('क्या काम हुआ या कौन सा सामान दिया'),
                  onTap: () async {
                    Navigator.pop(context);
                    final transaction =
                        await Navigator.push<KhataTransaction>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddUdharEntryPage(
                          masterItems: widget.masterItems,
                        ),
                      ),
                    );
                    if (transaction != null) {
                      setState(() {
                        widget.customer.transactions.add(transaction);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.currency_rupee),
                  ),
                  title: const Text('Payment Received'),
                  subtitle: const Text('Customer से पैसा जमा हुआ'),
                  onTap: () async {
                    Navigator.pop(context);
                    final transaction =
                        await Navigator.push<KhataTransaction>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddPaymentPage(),
                      ),
                    );
                    if (transaction != null) {
                      setState(() {
                        widget.customer.transactions.add(transaction);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Customer Delete करें?'),
        content: const Text(
          'इस Customer का पूरा Khata भी हट जाएगा।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              widget.onDelete();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ======================= ADD CUSTOMER =======================

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final openingBalanceController = TextEditingController(text: '0');

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    openingBalanceController.dispose();
    super.dispose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Customer(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        mobile: mobileController.text.trim(),
        address: addressController.text.trim(),
        openingBalance:
            double.tryParse(openingBalanceController.text.trim()) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Customer')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Field(
              controller: nameController,
              label: 'Customer Name *',
              icon: Icons.person_outline,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'नाम डालें' : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: mobileController,
              label: 'Mobile Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: addressController,
              label: 'Address',
              icon: Icons.location_on_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: openingBalanceController,
              label: 'Opening Balance',
              icon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: const Text('Customer Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= ADD UDHAR ENTRY =======================

class AddUdharEntryPage extends StatefulWidget {
  final List<MasterItem> masterItems;

  const AddUdharEntryPage({
    super.key,
    required this.masterItems,
  });

  @override
  State<AddUdharEntryPage> createState() => _AddUdharEntryPageState();
}

class _AddUdharEntryPageState extends State<AddUdharEntryPage> {
  final formKey = GlobalKey<FormState>();
  final itemController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final rateController = TextEditingController(text: '0');
  final noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  EntryCategory category = EntryCategory.service;

  double get quantity =>
      double.tryParse(quantityController.text.trim()) ?? 0;

  double get rate => double.tryParse(rateController.text.trim()) ?? 0;

  double get total => quantity * rate;

  @override
  void dispose() {
    itemController.dispose();
    quantityController.dispose();
    rateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      KhataTransaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: selectedDate,
        type: TransactionType.udhar,
        category: category,
        itemName: itemController.text.trim(),
        quantity: quantity,
        rate: rate,
        amount: total,
        note: noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Udhar / Kaam Entry')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(_formatDate(selectedDate)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: pickDate,
              ),
            ),
            const SizedBox(height: 14),
            SegmentedButton<EntryCategory>(
              segments: const [
                ButtonSegment(
                  value: EntryCategory.product,
                  icon: Icon(Icons.shopping_bag_outlined),
                  label: Text('Product'),
                ),
                ButtonSegment(
                  value: EntryCategory.service,
                  icon: Icon(Icons.build_outlined),
                  label: Text('Service / Kaam'),
                ),
              ],
              selected: {category},
              onSelectionChanged: (value) {
                setState(() => category = value.first);
              },
            ),
            const SizedBox(height: 16),
            if (widget.masterItems.isNotEmpty)
              DropdownButtonFormField<MasterItem>(
                decoration: const InputDecoration(
                  labelText: 'Item Master से Select करें (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                items: widget.masterItems
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          '${item.name} - ₹${item.rate.toStringAsFixed(0)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (item) {
                  if (item != null) {
                    setState(() {
                      itemController.text = item.name;
                      rateController.text = item.rate.toString();
                      category = item.category;
                    });
                  }
                },
              ),
            if (widget.masterItems.isNotEmpty) const SizedBox(height: 14),
            _Field(
              controller: itemController,
              label: 'Item / Kaam का नाम *',
              icon: Icons.edit_note,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Item या काम का नाम डालें'
                  : null,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: quantityController,
                    label: 'Quantity',
                    icon: Icons.numbers,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(
                    controller: rateController,
                    label: 'Rate ₹',
                    icon: Icons.currency_rupee,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _Field(
              controller: noteController,
              label: 'Description / Note',
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: const Text('Udhar Entry Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= ADD PAYMENT =======================

class AddPaymentPage extends StatefulWidget {
  const AddPaymentPage({super.key});

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String paymentMode = 'Cash';

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      KhataTransaction(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: selectedDate,
        type: TransactionType.payment,
        itemName: 'Payment Received',
        quantity: 1,
        rate: double.tryParse(amountController.text.trim()) ?? 0,
        amount: double.tryParse(amountController.text.trim()) ?? 0,
        note: noteController.text.trim(),
        paymentMode: paymentMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Received')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Payment Date'),
                subtitle: Text(_formatDate(selectedDate)),
                onTap: pickDate,
              ),
            ),
            const SizedBox(height: 14),
            _Field(
              controller: amountController,
              label: 'Payment Amount ₹ *',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'सही Amount डालें';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: paymentMode,
              decoration: const InputDecoration(
                labelText: 'Payment Mode',
                prefixIcon: Icon(Icons.payments),
                border: OutlineInputBorder(),
              ),
              items: const ['Cash', 'UPI', 'Bank', 'Other']
                  .map(
                    (mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(mode),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => paymentMode = value);
              },
            ),
            const SizedBox(height: 14),
            _Field(
              controller: noteController,
              label: 'Note',
              icon: Icons.notes,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.check_circle),
              label: const Text('Payment Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= ADD ITEM =======================

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final rateController = TextEditingController();
  EntryCategory category = EntryCategory.product;

  @override
  void dispose() {
    nameController.dispose();
    rateController.dispose();
    super.dispose();
  }

  void save() {
    if (!formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      MasterItem(
        name: nameController.text.trim(),
        category: category,
        rate: double.tryParse(rateController.text.trim()) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item / Service Add')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<EntryCategory>(
              segments: const [
                ButtonSegment(
                  value: EntryCategory.product,
                  label: Text('Product'),
                  icon: Icon(Icons.shopping_bag),
                ),
                ButtonSegment(
                  value: EntryCategory.service,
                  label: Text('Service'),
                  icon: Icon(Icons.build),
                ),
              ],
              selected: {category},
              onSelectionChanged: (value) {
                setState(() => category = value.first);
              },
            ),
            const SizedBox(height: 16),
            _Field(
              controller: nameController,
              label: 'Item / Service Name *',
              icon: Icons.inventory_2_outlined,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'नाम डालें'
                  : null,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: rateController,
              label: 'Default Rate ₹',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: const Text('Item Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= COMMON WIDGETS =======================

class _SainiLogo extends StatelessWidget {
  final double size;

  const _SainiLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2E6B2D),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 23,
          ),
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF12305B),
              ),
              child: const Text(
                '₹',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final bool large;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(large ? 20 : 15),
        child: Row(
          children: [
            CircleAvatar(
              radius: large ? 28 : 22,
              child: Icon(icon, size: large ? 28 : 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '₹${value.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: large ? 25 : 18,
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
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 42) / 2,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ReportRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

class _MiniAmount extends StatelessWidget {
  final String label;
  final double amount;
  final bool bold;

  const _MiniAmount({
    required this.label,
    required this.amount,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: bold ? 20 : 16,
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final KhataTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isUdhar = transaction.type == TransactionType.udhar;

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          child: Icon(
            isUdhar
                ? transaction.category == EntryCategory.product
                    ? Icons.shopping_bag_outlined
                    : Icons.build_outlined
                : Icons.payments_outlined,
          ),
        ),
        title: Text(
          transaction.itemName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDate(transaction.date)),
            if (isUdhar)
              Text(
                'Qty: ${transaction.quantity} × ₹${transaction.rate.toStringAsFixed(0)}',
              ),
            if (!isUdhar) Text('Mode: ${transaction.paymentMode}'),
            if (transaction.note.isNotEmpty) Text(transaction.note),
          ],
        ),
        isThreeLine: true,
        trailing: Text(
          '${isUdhar ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isUdhar ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyBox({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 65, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}
