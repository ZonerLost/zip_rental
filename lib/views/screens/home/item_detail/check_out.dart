import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/screens/bottomsheets/bottom_sheets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/custom_checkbox_widget.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:zip_peer/views/widget/my_textfeild.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Delivery', 'Pickup'];
  final TextEditingController _discountController = TextEditingController();

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
                selectPaymentBottomSheet(context);
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
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTabIndex == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? kPrimaryColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: MyText(
                          text: _tabs[index],
                          size: 14,
                          weight: FontWeight.w600,
                          color: isSelected ? kPrimaryColor : Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Gap(20),

          _selectedTabIndex == 0 ? DeliveryTabs() : PickupTab(),

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
  const DeliveryTabs({super.key});

  @override
  State<DeliveryTabs> createState() => _DeliveryTabsState();
}

class _DeliveryTabsState extends State<DeliveryTabs> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Select Address Button
        MyButton(
          onTap: () {
            showSelectAddressBottomSheet(context);
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
        // Added Items Section
        MyText(
          text: "ADDED ITEMS",
          size: 12,
          paddingLeft: 10,
          weight: FontWeight.w600,
          color: kSubText,
        ),
        Gap(20),
        // Item Card
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CommonImageView(imagePath: Assets.imagesShoes2, height: 120),
              Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: "Nike's Jordan 3310",
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                    Gap(4),
                    MyText(
                      text: "30+ Times rented | 9.7 condition",
                      size: 12,
                      color: kSubText,
                      weight: FontWeight.w600,
                    ),
                    Gap(8),
                    Row(
                      children: [
                        MyText(
                          text: "\$49.99",
                          size: 18,
                          weight: FontWeight.w700,
                        ),
                        MyText(text: " / month", size: 14, color: kSubText),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
