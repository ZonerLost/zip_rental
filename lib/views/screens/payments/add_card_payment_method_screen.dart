import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/constants/app_sizes.dart';
import 'package:zip_peer/controllers/payments/payment_method_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/payments/payment_models.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_dropdown.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

/// Collects card *metadata* only (brand, last 4 digits, expiry) — matching
/// exactly what `POST /payments/methods` accepts. There is no gateway SDK
/// wired up on either side (see docs/backend-payment-methods-integration.md),
/// so this deliberately does not attempt to collect or transmit a full PAN/
/// CVV, which would never be safe to send to a plain JSON endpoint like this
/// one.
class AddCardPaymentMethodScreen extends StatefulWidget {
  const AddCardPaymentMethodScreen({super.key});

  @override
  State<AddCardPaymentMethodScreen> createState() =>
      _AddCardPaymentMethodScreenState();
}

class _AddCardPaymentMethodScreenState
    extends State<AddCardPaymentMethodScreen> {
  final _labelController = TextEditingController();
  final _last4Controller = TextEditingController();

  // Confirmed by backend 2026-09-28: matched case-insensitively, stored
  // lowercase, against exactly this list.
  static const _brands = [
    'visa',
    'mastercard',
    'amex',
    'discover',
    'jcb',
    'unionpay',
    'diners',
    'other',
  ];
  static const _brandLabels = {
    'visa': 'Visa',
    'mastercard': 'Mastercard',
    'amex': 'Amex',
    'discover': 'Discover',
    'jcb': 'JCB',
    'unionpay': 'UnionPay',
    'diners': 'Diners Club',
    'other': 'Other',
  };

  String _selectedBrand = 'visa';
  late final int _currentYear;
  late final int _currentMonth;
  late final List<String> _allMonths;
  late final List<String> _years;
  late String _selectedMonth;
  late String _selectedYear;

  bool _isDefault = false;
  bool _showError = false;
  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
    _allMonths = List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'));
    _years = List.generate(16, (i) => (_currentYear + i).toString());
    _selectedYear = _years.first;
    // Confirmed 2026-09-28: an already-expired card is now rejected
    // server-side, so default (and only offer) a month that isn't in the
    // past for whichever year is selected.
    _selectedMonth = _currentMonth.toString().padLeft(2, '0');
  }

  /// Months not yet expired for [_selectedYear] — every month when a future
  /// year is picked, only the remaining ones for the current year.
  List<String> get _availableMonths {
    if (_selectedYear != _currentYear.toString()) return _allMonths;
    return _allMonths.where((m) => int.parse(m) >= _currentMonth).toList();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _last4Controller.dispose();
    super.dispose();
  }

  bool _validate() {
    final last4 = _last4Controller.text.trim();
    if (_labelController.text.trim().isEmpty) {
      setState(() {
        _showError = true;
        _errorText = 'Give this card a label, e.g. "Visa ending 4242".';
      });
      return false;
    }
    if (last4.length != 4 || int.tryParse(last4) == null) {
      setState(() {
        _showError = true;
        _errorText = 'Enter exactly 4 digits for the last-4.';
      });
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (_isSaving || !_validate()) return;
    setState(() => _isSaving = true);

    final request = SavePaymentMethodRequest(
      label: _labelController.text.trim(),
      isDefault: _isDefault,
      card: PaymentCardInfo(
        brand: _selectedBrand,
        last4: _last4Controller.text.trim(),
        expiryMonth: int.parse(_selectedMonth),
        expiryYear: int.parse(_selectedYear),
      ),
    );

    PaymentMethodController? controller;
    try {
      controller = Get.find<PaymentMethodController>();
    } catch (_) {
      controller = null;
    }

    final saved = await (controller ?? PaymentMethodController()).addMethod(
      request,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (saved != null) {
      Get.back(result: saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSizes.DEFAULT,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              Row(
                children: [
                  Bounce(
                    onTap: () => Get.back(),
                    child: CommonImageView(
                      imagePath: Assets.imagesBack,
                      height: 50,
                    ),
                  ),
                  const Gap(8),
                  const MyText(
                    text: 'Add new payment method',
                    size: 16,
                    weight: FontWeight.w700,
                  ),
                ],
              ),
              const Gap(24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextField(
                        label: 'Card Label *',
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: 'e.g. Visa ending 4242',
                        hintColor: kBlack,
                        controller: _labelController,
                        alwaysShowLabel: true,
                        radius: 12,
                        onChanged: (_) => setState(() => _showError = false),
                      ),
                      const MyText(
                        text: 'Card Brand',
                        size: 12,
                        color: kSubText,
                        paddingBottom: 8,
                      ),
                      CustomDropDown(
                        hint: 'Select Brand',
                        items: _brands
                            .map((b) => _brandLabels[b]!)
                            .toList(growable: false),
                        selectedValue: _brandLabels[_selectedBrand]!,
                        onChanged: (value) => setState(() {
                          _selectedBrand = _brands.firstWhere(
                            (b) => _brandLabels[b] == value,
                          );
                        }),
                        bgColor: Colors.white,
                        labelText: '',
                      ),
                      const Gap(16),
                      MyTextField(
                        label: 'Last 4 Digits *',
                        labelColor: kSubText,
                        labelSize: 12,
                        labelWeight: FontWeight.w500,
                        hint: 'e.g. 4242',
                        hintColor: kBlack,
                        controller: _last4Controller,
                        alwaysShowLabel: true,
                        radius: 12,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() => _showError = false),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const MyText(
                                  text: 'Expiry Month',
                                  size: 12,
                                  color: kSubText,
                                  paddingBottom: 8,
                                ),
                                CustomDropDown(
                                  hint: 'Month',
                                  items: _availableMonths,
                                  selectedValue: _selectedMonth,
                                  onChanged: (value) =>
                                      setState(() => _selectedMonth = value),
                                  bgColor: Colors.white,
                                  labelText: '',
                                ),
                              ],
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const MyText(
                                  text: 'Expiry Year',
                                  size: 12,
                                  color: kSubText,
                                  paddingBottom: 8,
                                ),
                                CustomDropDown(
                                  hint: 'Year',
                                  items: _years,
                                  selectedValue: _selectedYear,
                                  onChanged: (value) => setState(() {
                                    _selectedYear = value;
                                    // Switching back to the current year can
                                    // leave a since-passed month selected —
                                    // clamp forward rather than let the user
                                    // submit an expired date.
                                    if (!_availableMonths.contains(_selectedMonth)) {
                                      _selectedMonth = _availableMonths.first;
                                    }
                                  }),
                                  bgColor: Colors.white,
                                  labelText: '',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Gap(8),
                      Bounce(
                        onTap: () => setState(() => _isDefault = !_isDefault),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isDefault,
                              activeColor: kPrimaryColor,
                              onChanged: (v) =>
                                  setState(() => _isDefault = v ?? false),
                            ),
                            const MyText(
                              text: 'Set as default payment method',
                              size: 14,
                              weight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                      if (_showError) ...[
                        const Gap(8),
                        Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: kredColor,
                              size: 16,
                            ),
                            const Gap(6),
                            Expanded(
                              child: MyText(
                                text: _errorText ?? 'Please check the form.',
                                size: 13,
                                color: kredColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Gap(32),
                    ],
                  ),
                ),
              ),
              MyButton(
                onTap: () {
                  if (!_isSaving) _submit();
                },
                buttonText: _isSaving ? 'Saving...' : 'Add',
                fontColor: Colors.white,
                height: 56,
                radius: 28,
                hasgrad: false,
                fontSize: 17,
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
