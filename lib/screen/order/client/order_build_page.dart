// lib/screen/order/client/order_build_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/api/api_routes.dart';
import 'package:uytaza/api/api_service.dart';
import 'package:uytaza/screen/models/cleaning_service.dart';
import 'package:uytaza/screen/profile/profile_api.dart';
import 'package:uytaza/screen/profile/client/choose_address_screen.dart';
import 'package:uytaza/common/extension.dart';
import '../../payment/payment_page.dart';
import '../../subscription/subscription_build_page.dart';
import 'order_success_page.dart';

class OrderBuildPage extends StatefulWidget {
  const OrderBuildPage({super.key});
  @override
  State<OrderBuildPage> createState() => _OrderBuildPageState();
}

class _OrderBuildPageState extends State<OrderBuildPage> {
  // ────────── STATE ──────────
  String selectedType = 'custom';
  final Set<String> selectedServiceIds = {};
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

  List<CleaningService> services = [];
  double totalPrice = 0;

  bool loadingServices = true;
  bool loadingProfile = true;
  bool submitting = false;

  String? _profileAddress;
  final addressCtl = TextEditingController();
  final noteCtl = TextEditingController();

  // Список типов уборки для карусели
  final List<_CleaningType> cleaningTypes = [
    _CleaningType(
      key: 'custom',
      label: 'Custom',
      asset: 'assets/img/custom_service.png',
    ),
    _CleaningType(
      key: 'initial',
      label: 'Initial',
      asset: 'assets/img/initial_service.png',
    ),
    _CleaningType(
      key: 'standard',
      label: 'Standard',
      asset: 'assets/img/standard_service.png',
    ),
  ];

  final PageController _typeController =
  PageController(viewportFraction: 0.75);

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadProfileAddress();
  }

  /// Загружает список доступных услуг
  Future<void> _loadServices() async {
    try {
      final res = await ApiService.getWithToken(ApiRoutes.services);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        services = list
            .map((e) => CleaningService.fromJson(
            Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _showError('Services HTTP ${res.statusCode}');
      }
    } catch (e) {
      _showError('Services error: $e');
    } finally {
      if (mounted) setState(() => loadingServices = false);
    }
  }

  /// Загружает сохранённый адрес из профиля
  Future<void> _loadProfileAddress() async {
    _profileAddress = await ProfileApi.fetchAddress();
    if (mounted) setState(() => loadingProfile = false);
  }

  /// Объединяет дату и время в один объект DateTime
  DateTime _combineDateTime() => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  /// Форматирует в ISO-строку (с Z)
  String _backendDate(DateTime dtUtc) {
    final utc = dtUtc.toUtc();
    final core = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(utc);
    return '$core' + 'Z';
  }

  /// Пересчитывает итоговую сумму, складывая цены выбранных услуг
  void _recalcTotal() {
    totalPrice = services
        .where((s) => selectedServiceIds.contains(s.id))
        .fold(0.0, (sum, s) => sum + s.price);
  }

  /// Включает/выключает услугу по ID
  void _toggleService(String id) {
    setState(() {
      if (!selectedServiceIds.add(id)) {
        selectedServiceIds.remove(id);
      }
      _recalcTotal();
    });
  }

  /// Открывает диалог выбора адреса (профиль или карта)
  Future<void> _pickAddress() async {
    if (loadingProfile) return;

    final picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_profileAddress != null)
              ListTile(
                leading: const Icon(Icons.person_pin_circle),
                title: const Text('Use profile address'),
                subtitle: Text(_profileAddress!),
                onTap: () => Navigator.pop(context, _profileAddress),
              ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: const Text('Choose on map'),
              onTap: () async {
                final addr = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChooseAddressScreen()),
                );
                Navigator.pop(context, addr);
              },
            ),
          ],
        ),
      ),
    );

    if (picked != null && picked.isNotEmpty) {
      setState(() => addressCtl.text = picked);
    }
  }

  /// Создаёт заказ на сервере, отправляя полный JSON
  Future<void> _createOrder() async {
    if (addressCtl.text.trim().isEmpty) {
      _showError('Address required');
      return;
    }
    if (selectedServiceIds.isEmpty) {
      _showError('Pick at least one service');
      return;
    }

    setState(() => submitting = true);

    final body = <String, dynamic>{
      "address": addressCtl.text.trim(),
      "service_ids": selectedServiceIds.toList(),
      "service_type": selectedType,
      "date": _backendDate(_combineDateTime()),
      "comment": noteCtl.text.trim(),
    };

    try {
      final res =
      await ApiService.postWithToken(ApiRoutes.orders, body);
      if (res.statusCode == 201) {
        final orderJson = res.body.isNotEmpty
            ? Map<String, dynamic>.from(jsonDecode(res.body))
            : <String, dynamic>{};
        await _onOrderSuccess(orderJson);
      } else {
        final map = res.body.isNotEmpty
            ? jsonDecode(res.body)
            : {'error': res.statusCode};
        throw map['error'] ?? 'HTTP ${res.statusCode}';
      }
    } catch (e) {
      _showError('Order failed: $e');
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  /// После успешного создания заказа спрашиваем про подписку или оплату
  Future<void> _onOrderSuccess(
      Map<String, dynamic> orderJson) async {
    if (!mounted) return;

    // Предлагаем подписку
    final repeat = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Repeat this order?'),
        content: const Text(
            'Would you like to create a subscription based on this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    final orderId = orderJson['id']?.toString() ?? '';
    if (repeat == true && orderId.isNotEmpty) {
      // Переходим на создание подписки, передав только ID заказа
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionBuildPage(),
          settings: RouteSettings(arguments: orderId),
        ),
      );
      return;
    }

    // Иначе – сразу на оплату
    final userId = orderJson['user_id']?.toString() ?? '';
    final amount = (orderJson['total_price'] is num)
        ? (orderJson['total_price'] as num).toInt()
        : totalPrice.toInt();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          entityType: 'order',
          entityId: orderId,
          userId: userId,
          amount: amount,
        ),
      ),
    );
  }

  /// Показывает Snackbar с ошибкой
  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ────────── UI ──────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'New Order',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: loadingServices
          ? const Center(
          child: CircularProgressIndicator(color: Colors.white))
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAddress(),
                    const SizedBox(height: 20),
                    _buildNote(),
                    const SizedBox(height: 20),
                    _buildTypeCarousel(),
                    const SizedBox(height: 20),
                    _buildServicesChips(),
                    const SizedBox(height: 20),
                    _buildCalendar(),
                    const SizedBox(height: 20),
                    _buildTime(),
                    const SizedBox(height: 20),
                    _buildTotal(),
                  ],
                ),
              ),
            ),
          ),
          _buildSubmitBtn(),
        ],
      ),
    );
  }

  Widget _buildAddress() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Address',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _pickAddress,
        child: AbsorbPointer(
          child: TextField(
            controller: addressCtl,
            decoration: InputDecoration(
              hintText: loadingProfile
                  ? 'Loading...'
                  : 'Tap to select address',
              suffixIcon: const Icon(Icons.location_on_outlined),
              fillColor: TColor.background,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: TColor.divider),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildNote() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Apartment / Floor / Note',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: noteCtl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Optional',
          fillColor: TColor.background,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: TColor.divider),
          ),
        ),
      ),
    ],
  );

  Widget _buildTypeCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cleaning Type',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _typeController,
            itemCount: cleaningTypes.length,
            onPageChanged: (i) {
              setState(() => selectedType = cleaningTypes[i].key);
            },
            itemBuilder: (context, i) {
              final type = cleaningTypes[i];
              final isSel = selectedType == type.key;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: isSel ? 0 : 10,
                ),
                decoration: BoxDecoration(
                  color: isSel
                      ? TColor.primary.withOpacity(0.1)
                      : TColor.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? TColor.primary : TColor.divider,
                    width: isSel ? 2 : 1,
                  ),
                  boxShadow: isSel
                      ? [
                    BoxShadow(
                      color: TColor.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : null,
                ),
                child: GestureDetector(
                  onTap: () {
                    _typeController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    );
                    setState(() => selectedType = type.key);
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14)),
                          child: Image.asset(
                            type.asset,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel
                              ? TColor.textPrimary
                              : TColor.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        isSel ? Icons.check_circle : Icons.circle_outlined,
                        color: isSel ? TColor.primary : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServicesChips() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Additional Services',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: services.map(_serviceChip).toList(),
      ),
    ],
  );

  Widget _serviceChip(CleaningService s) {
    final sel = selectedServiceIds.contains(s.id);
    return ChoiceChip(
      label: Text('${s.name} (${s.price.toStringAsFixed(0)} ₸)'),
      selected: sel,
      onSelected: (_) => _toggleService(s.id),
      selectedColor: TColor.primary,
      labelStyle: TextStyle(
        color: sel ? Colors.white : TColor.textPrimary,
      ),
      backgroundColor: TColor.background,
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final daysCount = lastDay.day;
    final startWeekday = firstDay.weekday;
    List<Widget> rows = [];

    rows.add(Row(
      children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
          .map((d) => Expanded(
        child: Center(
          child: Text(
            d,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: TColor.primary,
            ),
          ),
        ),
      ))
          .toList(),
    ));

    List<Widget> currentRow = [];
    for (int i = 1; i < startWeekday; i++) {
      currentRow.add(const Expanded(child: SizedBox()));
    }

    for (int day = 1; day <= daysCount; day++) {
      final cur = DateTime(selectedDate.year, selectedDate.month, day);
      final sel = selectedDate.day == day;
      final past = cur.isBefore(
          DateTime.now().subtract(const Duration(days: 1)));

      currentRow.add(Expanded(
        child: GestureDetector(
          onTap: past ? null : () => setState(() => selectedDate = cur),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: sel ? TColor.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: past
                      ? Colors.grey
                      : sel
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ));

      if (currentRow.length == 7) {
        rows.add(Row(children: currentRow));
        currentRow = [];
      }
    }
    if (currentRow.isNotEmpty) {
      while (currentRow.length < 7) {
        currentRow.add(const Expanded(child: SizedBox()));
      }
      rows.add(Row(children: currentRow));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => setState(() {
                selectedDate = DateTime(
                  selectedDate.year,
                  selectedDate.month - 1,
                  1,
                );
              }),
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () => setState(() {
                selectedDate = DateTime(
                  selectedDate.year,
                  selectedDate.month + 1,
                  1,
                );
              }),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        ...rows,
        const SizedBox(height: 8),
        Text(
          'Selected: ${DateFormat('dd.MM.yyyy').format(selectedDate)}',
          style: TextStyle(color: TColor.textSecondary),
        ),
      ],
    );
  }

  Widget _buildTime() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select Time',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 10),
      GestureDetector(
        onTap: () async {
          final t = await showTimePicker(
              context: context, initialTime: selectedTime);
          if (t != null) setState(() => selectedTime = t);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: TColor.background,
            border: Border.all(color: TColor.divider),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedTime.format(context),
                style: const TextStyle(fontSize: 16),
              ),
              const Icon(Icons.access_time),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildTotal() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(),
      const SizedBox(height: 10),
      Text(
        'Total: ${totalPrice.toStringAsFixed(0)} ₸',
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ],
  );

  Widget _buildSubmitBtn() => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: ElevatedButton(
      onPressed: submitting ? null : _createOrder,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: TColor.primary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      child: submitting
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : const Text(
        'Create Order',
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    ),
  );
}

/// Класс для типа уборки
class _CleaningType {
  final String key;
  final String label;
  final String asset;
  const _CleaningType({
    required this.key,
    required this.label,
    required this.asset,
  });
}
