import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedMainTab = 0; // 0 = Items I rent out, 1 = Items I'm renting
  int _selectedSubTab = 0; // 0 = Upcoming, 1 = Pending, 2 = Active, 3 = Past

  // Sample bookings data with event markers
  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 12, 2): ['green'],
    DateTime.utc(2025, 12, 5): ['green'],
    DateTime.utc(2025, 12, 9): ['green'],
    DateTime.utc(2025, 12, 11): ['green', 'yellow'],
    DateTime.utc(2025, 12, 13): ['green'],
    DateTime.utc(2025, 12, 15): ['yellow'],
    DateTime.utc(2025, 12, 19): ['yellow'],
    DateTime.utc(2025, 12, 21): ['green'],
    DateTime.utc(2025, 12, 23): ['green'],
    DateTime.utc(2025, 12, 28): ['green'],
  };

  final List<Map<String, dynamic>> bookings = [
    {
      'title': 'Nike Jordan 6',
      'category': 'Footwear',
      'status': 'Rented Out',
      'ownerName': 'Mike Hesson',
      'amount': '€49.99',
      'dateToPay': 'Oct 5, 2025',
      'deliveryDate': 'Oct 20, 2001',

      'paymentStatus': 'Payment',
    },
    {
      'title': 'Nike Jordan 6',
      'category': 'Footwear',
      'status': 'Rented Out',
      'ownerName': 'Mike Hesson',
      'amount': '€49.99',
      'dateToPay': 'Oct 5, 2025',
      'deliveryDate': 'Oct 20, 2001',

      'paymentStatus': 'Payment',
    },
  ];

  List<Widget> _buildEventMarkers(DateTime day) {
    final events = _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
    if (events.isEmpty) return [];

    return events.map((color) {
      return Container(
        width: 30,
        height: 3,
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: color == 'green' ? Color(0xFF4CAF50) : Color(0xFFFFD37E),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }).toList();
  }

  Widget _buildMainTab(String title, int index, Color indicatorColor) {
    final isSelected = _selectedMainTab == index;
    return Expanded(
      child: Bounce(
        onTap: () {
          setState(() {
            _selectedMainTab = index;
          });
        },
        child: Column(
          children: [
            MyText(
              text: title,
              size: 16,
              color: isSelected ? kBlack : kSubText,
              weight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
            Gap(8),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? indicatorColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTab(String title, int index) {
    final isSelected = _selectedSubTab == index;
    return Expanded(
      child: Bounce(
        onTap: () {
          setState(() {
            _selectedSubTab = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? kPrimaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: MyText(
              textAlign: TextAlign.center,
              text: title,
              size: 14,
              color: isSelected ? kPrimaryColor : kSubText,
              weight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // Build action buttons based on selected tab
  Widget _buildActionButtons(Map<String, dynamic> booking) {
    // Upcoming tab - no buttons
    if (_selectedSubTab == 0) {
      return Gap(0);
    }

    // Pending tab - Accept and Decline buttons
    if (_selectedSubTab == 1) {
      return Row(
        children: [
          Expanded(
            child: MyButton(
              onTap: () {
                // Handle decline action
              },
              buttonText: "Decline",
              backgroundColor: kredColor.withOpacity(0.2),
              fontColor: kredColor,
              radius: 20,
            ),
          ),
          Gap(12),
          Expanded(
            child: MyButton(
              onTap: () {
                // Handle accept action
              },
              buttonText: "Accept",
              backgroundColor: kgreenColor.withOpacity(0.2),
              fontColor: kgreenColor,
              radius: 20,
            ),
          ),
        ],
      );
    }

    // Active tab - different buttons based on main tab
    if (_selectedSubTab == 2) {
      if (_selectedMainTab == 0) {
        // Items I rent out - Pay Now button
        return MyButton(
          onTap: () {},
          buttonText: "Pay Now",
          backgroundColor: kPrimaryColor.withOpacity(0.2),
          fontColor: kPrimaryColor,
          radius: 20,
        );
      } else {
        // Items I'm renting - Return Item button
        return MyButton(
          onTap: () {},
          buttonText: "Return Item",
          backgroundColor: kYellowColor.withOpacity(0.2),
          fontColor: kYellowColor,
          radius: 20,
        );
      }
    }

    // Past tab - View Details or Rate buttons
    if (_selectedSubTab == 3) {
      return Row(
        children: [
          Expanded(
            child: MyButton(
              onTap: () {
                // Handle view details action
              },
              buttonText: "View Details",
              backgroundColor: kSubText.withOpacity(0.2),
              fontColor: kSubText,
              radius: 20,
            ),
          ),
          Gap(12),
          Expanded(
            child: MyButton(
              onTap: () {
                // Handle rate action
              },
              buttonText: "Rate",
              backgroundColor: kPrimaryColor.withOpacity(0.2),
              fontColor: kPrimaryColor,
              radius: 20,
            ),
          ),
        ],
      );
    }

    return Gap(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedListView(
        padding: EdgeInsets.all(20),
        children: [
          Gap(50),
          // Header
          MyText(text: "Bookings", size: 28, weight: FontWeight.w700),
          Gap(24),

          // Calendar
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
            padding: EdgeInsets.all(16),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    weekendStyle: TextStyle(
                      color: kSubText,
                      fontSize: 14,
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
                      color: Color(0xFF4A5C6A),
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: kWhite,
                      fontWeight: FontWeight.w600,
                    ),
                    defaultTextStyle: TextStyle(
                      color: kBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    weekendTextStyle: TextStyle(
                      color: kBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    outsideTextStyle: TextStyle(
                      color: kSubText.withOpacity(0.5),
                      fontSize: 15,
                    ),
                    cellMargin: EdgeInsets.all(6),
                    markersMaxCount: 2,
                    markersAlignment: Alignment.bottomCenter,
                    markerDecoration: BoxDecoration(color: Colors.transparent),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final markers = _buildEventMarkers(date);
                      if (markers.isEmpty) return SizedBox.shrink();

                      return Positioned(
                        bottom: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: markers,
                        ),
                      );
                    },
                  ),
                  eventLoader: (day) {
                    return _events[DateTime.utc(
                          day.year,
                          day.month,
                          day.day,
                        )] ??
                        [];
                  },
                ),
              ],
            ),
          ),

          Gap(24),

          // Main Tabs (Items I rent out / Items I'm renting)
          Row(
            children: [
              _buildMainTab('Items I rent out', 0, kYellowColor),
              Gap(20),
              _buildMainTab('Items I\'m renting', 1, kgreenColor),
            ],
          ),

          Gap(24),

          // Sub Tabs (Upcoming, Pending, Active, Past)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                _buildSubTab('Upcoming', 0),
                const Gap(8),
                _buildSubTab('Pending', 1),
                const Gap(8),
                _buildSubTab('Active', 2),
                const Gap(8),
                _buildSubTab('Past', 3),
              ],
            ),
          ),
          const Gap(24),

          // Bookings count
          MyText(
            text: '${bookings.length} Bookings found',
            size: 16,
            color: kSubText,
            weight: FontWeight.w500,
          ),
          Gap(24),

          // Bookings List
          ListView.builder(
            padding: EdgeInsets.all(0),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return Container(
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: _selectedMainTab == 0 ? kYellowColor : kgreenColor,
                      width: 4,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item header with payment status
                          Row(
                            children: [
                              CommonImageView(
                                imagePath: Assets.imagesShoes1,
                                height: 50,
                              ),
                              Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      text: booking['title'],
                                      size: 18,
                                      weight: FontWeight.w600,
                                    ),
                                    Gap(4),
                                    MyText(
                                      text:
                                          '${booking['category']} | ${booking['status']}',
                                      size: 14,
                                      color: kSubText,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedMainTab == 0
                                      ? kredColor.withOpacity(0.2)
                                      : kgreenColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: _selectedMainTab == 0
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CommonImageView(
                                            imagePath: Assets.imagesTimer,
                                            height: 20,
                                          ),
                                          Gap(4),
                                          MyText(
                                            text: booking['paymentStatus'],
                                            size: 13,
                                            weight: FontWeight.w500,
                                            color: Color(0xFFE53935),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: kgreenColor,
                                            size: 16,
                                          ),
                                          Gap(4),
                                          MyText(
                                            text: "Ready to Rented",
                                            size: 12,
                                            weight: FontWeight.w500,
                                            color: kgreenColor,
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                          Gap(10),
                          Divider(color: kDividerColor),
                          Gap(10),
                          // Booking details - Different layout for Pending tab when "Items I rent out"
                          if (_selectedSubTab == 1 && _selectedMainTab == 0)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            text: 'Owner Name',
                                            size: 13,
                                            color: kSubText,
                                            weight: FontWeight.w600,
                                          ),
                                          Gap(4),
                                          MyText(
                                            text: booking['ownerName'] ?? 'N/A',
                                            size: 16,
                                            color: kBlack,
                                            weight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            text: 'Delivery Date',
                                            size: 13,
                                            color: kSubText,
                                            weight: FontWeight.w600,
                                          ),
                                          Gap(4),
                                          MyText(
                                            text: "Oct 20, 2025",
                                            size: 16,
                                            color: kBlack,
                                            weight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText(
                                            text: 'Rented since',
                                            size: 13,
                                            color: kSubText,
                                            weight: FontWeight.w600,
                                          ),
                                          Gap(4),
                                          MyText(
                                            text: "Oct 20, 2025",
                                            size: 16,
                                            color: kBlack,
                                            weight: FontWeight.w600,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: Gap(0)),
                                  ],
                                ),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: 'Owner Name',
                                        size: 13,
                                        color: kSubText,
                                        weight: FontWeight.w600,
                                      ),
                                      Gap(4),
                                      MyText(
                                        text: booking['ownerName'],
                                        size: 16,
                                        color: kBlack,
                                        weight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: 'Amount/month',
                                        size: 13,
                                        color: kSubText,
                                        weight: FontWeight.w600,
                                      ),
                                      Gap(4),
                                      MyText(
                                        text: booking['amount'],
                                        size: 16,
                                        color: kBlack,
                                        weight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: 'Date to Pay',
                                        size: 13,
                                        color: kSubText,
                                        weight: FontWeight.w600,
                                      ),
                                      Gap(4),
                                      MyText(
                                        text: booking['dateToPay'],
                                        size: 16,
                                        color: kBlack,
                                        weight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          Gap(20),
                          // Action buttons based on selected tab
                          _buildActionButtons(booking),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Gap(100),
        ],
      ),
    );
  }
}
