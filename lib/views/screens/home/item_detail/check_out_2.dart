import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/add_item_module/add_insurance2.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_checkbox_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class CheckoutScreen2 extends StatefulWidget {
  const CheckoutScreen2({super.key});

  @override
  State<CheckoutScreen2> createState() => _CheckoutScreen2State();
}

class _CheckoutScreen2State extends State<CheckoutScreen2> {
  final TextEditingController _discountController = TextEditingController();
  String? _selectedDeliveryFee; // Track delivery fee from selected address

  bool isDeliveryEnabled = true; // from backend
  bool isPickupEnabled = true; // from backend

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: kWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomCheckbox2(
              text: "Agree to",
              text2: "Terms & Cancellation Policy",
              onChanged: (bool value) async {},
            ),
            Gap(20),
            Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: _discountController,
                    hint: "discount code",
                    hintColor: kSubText,
                    hintsize: 14,
                    marginBottom: 0,
                    backgroundColor: kbackground,
                  ),
                ),
                Gap(12),
                MyButton(
                  onTap: () {},
                  buttonText: "Apply",
                  backgroundColor: kPrimaryColor.withOpacity(0.2),
                  fontColor: kPrimaryColor,
                  width: 100,
                  height: 50,
                  radius: 12,
                  fontSize: 14,
                  hasgrad: false,
                ),
              ],
            ),

            Gap(20),

            Column(
              children: [
                _buildPriceRow("Items Price", "\$199.00"),
                Gap(12),
                _buildPriceRow("Discount (5%)", "\$15.00"),
                Gap(12),
                
                // Show delivery fees only when Delivery tab is selected
                if (_selectedDeliveryFee != null) ...[
                  _buildPriceRow("Delivery Fees", _selectedDeliveryFee!),
                  Gap(12),
                ],
                _buildPriceRow("Subtotal", "\$500.00"),
                Gap(12),
                Divider(color: kDividerColor),
                Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        MyText(
                          text: "Price to Pay (Security Hold)",
                          size: 14,
                          color: kSubText,
                        ),
                        Gap(4),
                        CommonImageView(
                          imagePath: Assets.imagesInfoCircleBlack,
                          height: 20,
                        ),
                      ],
                    ),
                    MyText(text: "\$100.00", size: 14, weight: FontWeight.w600),
                  ],
                ),
              ],
            ),
            Gap(20),
            MyButton(
              onTap: () {
                Get.to(() => const AddInsuranceScreen2());
              },
              buttonText: "Continue to payment",
              height: 56,
              radius: 30,
              fontSize: 16,
            ),
            Gap(20),
          ],
        ),
      ),
      body: AnimatedListView(
        padding: EdgeInsets.all(20),
        children: [
          Gap(50),
          // Top Bar
          Row(
            children: [
              Bounce(
                onTap: () => Get.back(),
                child: CommonImageView(
                  imagePath: Assets.imagesBack,
                  height: 50,
                ),
              ),
              MyText(
                text: "Checkout",
                size: 20,
                paddingLeft: 12,
                weight: FontWeight.w600,
              ),
            ],
          ),
          Gap(20),
          DeliveryTabs(),
          // Custom Tabs
          Gap(100),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText(text: label, size: 14, color: kSubText),
        MyText(text: price, size: 14, weight: FontWeight.w600),
      ],
    );
  }
}

class DeliveryTabs extends StatefulWidget {
  final Function(String fee, String addressTitle)? onAddressSelected;

  const DeliveryTabs({super.key, this.onAddressSelected});

  @override
  State<DeliveryTabs> createState() => _DeliveryTabsState();
}

class _DeliveryTabsState extends State<DeliveryTabs> {
  int selectedItemIndex = 0;
  bool isDeliveryEnabled = true; // from backend
  bool isPickupEnabled = true; // from backend
  String? pickupPoint; // e.g. "Downtown Mall, Paris"

  String? _selectedOption; // "delivery" | "pickup"

  final List<Map<String, dynamic>> items = [
    {
      'image': Assets.imagesShoes2,
      'title': "Nike's Jordan 3310",
      'rentedTimes': '30+',
      'condition': '9.7',
      'price': '\$49.99',
      'duration': 'month',
    },
    {
      'image': Assets.imagesShoes1,
      'title': "Adidas Ultra Boost",
      'rentedTimes': '20+',
      'condition': '9.5',
      'price': '\$39.99',
      'duration': 'month',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Select Address Button

        // Added Items Section
        MyText(
          text: "ADDED ITEMS",
          size: 12,
          paddingLeft: 10,
          weight: FontWeight.w600,
          color: kSubText,
        ),
        Gap(20),
        // Item Cards List
        ...List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = selectedItemIndex == index;

          return Padding(
            padding: EdgeInsets.only(bottom: index < items.length - 1 ? 16 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedItemIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryColor.withOpacity(0.3) : kWhite,
                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? kPrimaryColor.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Selection Indicator
                    CommonImageView(imagePath: item['image'], height: 120),
                    Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: item['title'],
                            size: 16,
                            weight: FontWeight.w600,
                          ),
                          Gap(4),
                          MyText(
                            text:
                                "${item['rentedTimes']} Times rented | ${item['condition']} condition",
                            size: 12,
                            color: kSubText,
                            weight: FontWeight.w600,
                          ),
                          Gap(8),
                          Row(
                            children: [
                              MyText(
                                text: item['price'],
                                size: 18,
                                weight: FontWeight.w700,
                                color: isSelected ? kPrimaryColor : kBlack,
                              ),
                              MyText(
                                text: " / ${item['duration']}",
                                size: 14,
                                color: kSubText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        Gap(20),
        MyButton(
          onTap: () {
            showCalenderBottomSheet(context);
          },
          buttonText: "View Calendar",
          height: 50,
          radius: 30,
          fontSize: 14,
          backgroundColor: kWhite,
          fontColor: kBlack,
        ),
        Gap(20),
        Row(
          spacing: 10,
          children: [
            if (isDeliveryEnabled)
              Expanded(
                child: MyButton(
                  onTap: () {
                    setState(() {
                      _selectedOption = "delivery";
                    });
                    // 👉 DO NOT open map
                    // 👉 Just enable "Select address"
                  },
                  buttonText: "Delivery",
                  height: 50,
                  radius: 30,
                  fontSize: 14,
                  backgroundColor: _selectedOption == "delivery"
                      ? kPrimaryColor
                      : kWhite,
                  fontColor: _selectedOption == "delivery" ? kWhite : kBlack,
                ),
              ),

            if (isPickupEnabled)
              Expanded(
                child: MyButton(
                  onTap: () {
                    setState(() {
                      _selectedOption = "pickup";
                      pickupPoint = "Approx. pickup near Downtown Mall";
                    });

                    showMapBottomSheet(context);
                  },
                  buttonText: "Pickup",
                  height: 50,
                  radius: 30,
                  fontSize: 14,
                  backgroundColor: _selectedOption == "pickup"
                      ? kPrimaryColor
                      : kWhite,
                  fontColor: _selectedOption == "pickup" ? kWhite : kBlack,
                ),
              ),
          ],
        ),

        Gap(20),
        if (_selectedOption == "delivery")
          MyButton(
            onTap: () {
              showSelectAddressBottomSheet(
                context,
                onAddressSelected: (String fee, String addressTitle) {
                  if (widget.onAddressSelected != null) {
                    widget.onAddressSelected!(fee, addressTitle);
                  }
                },
              );
            },
            buttonText: "Select address",
            backgroundColor: kPrimaryColor.withOpacity(0.2),
            fontColor: kPrimaryColor,
            height: 56,
            radius: 30,
            fontSize: 16,
            hasgrad: false,
          ),
        Gap(20),
      ],
    );
  }
}

class PickupTab extends StatefulWidget {
  const PickupTab({super.key});

  @override
  State<PickupTab> createState() => _PickupTabState();
}

class _PickupTabState extends State<PickupTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  @override
  Widget build(BuildContext context) {
    return AnimatedColumn(
      children: [
        Container(
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextFormatter: (date, locale) =>
                      DateFormat('EEE, MMM dd, yyyy').format(date),
                  titleTextStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kBlack,
                  ),
                  leftChevronIcon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kWhite3,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chevron_left, color: kBlack, size: 20),
                  ),
                  rightChevronIcon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kWhite3,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.chevron_right, color: kBlack, size: 20),
                  ),
                  decoration: BoxDecoration(
                    color: kWhite3,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  headerPadding: EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  headerMargin: EdgeInsets.only(bottom: 16),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: kSubText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendStyle: TextStyle(
                    color: kSubText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Color(0xFF4A5C6A),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                    color: kWhite,
                    fontWeight: FontWeight.w600,
                  ),
                  defaultTextStyle: TextStyle(
                    color: kBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  weekendTextStyle: TextStyle(
                    color: kBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  outsideTextStyle: TextStyle(
                    color: kSubText.withOpacity(0.5),
                    fontSize: 12,
                  ),
                  cellMargin: EdgeInsets.all(3),
                  markersMaxCount: 2,
                  markersAlignment: Alignment.bottomCenter,
                  markerDecoration: BoxDecoration(color: Colors.transparent),
                ),
                calendarBuilders: CalendarBuilders(),
              ),
              Row(
                children: [
                  Expanded(
                    child: Bounce(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kWhite3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: "Available From",
                              size: 12,
                              color: kSubText,
                            ),
                            Gap(4),
                            MyText(
                              text: "09:00 PM",
                              size: 16,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Gap(12),
                  Expanded(
                    child: Bounce(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: kWhite3,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: "Available To",
                              size: 12,
                              color: kSubText,
                            ),
                            Gap(4),
                            MyText(
                              text: "06:00 PM",
                              size: 18,
                              weight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
