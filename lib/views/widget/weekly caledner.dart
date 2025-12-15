import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:week_of_year/week_of_year.dart';
import "package:weekly_date_picker/datetime_apis.dart";

class CustomWeeklyDatePicker extends StatefulWidget {
  const CustomWeeklyDatePicker({
    super.key,
    required this.selectedDays,
    required this.changeDays,
    this.weekdays = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.backgroundColor = Colors.white,
    this.selectedDigitBackgroundColor = const Color(0xFF1a237e),
    this.selectedDigitBorderColor = Colors.transparent,
    this.selectedDigitColor = Colors.white,
    this.digitsColor = const Color(0xFF424242),
    this.weekdayTextColor,
    this.enableWeeknumberText = false,
    this.weeknumberColor = Colors.transparent,
    this.weeknumberTextColor = Colors.transparent,
    this.daysInWeek = 7,
  }) : assert(
         weekdays.length == daysInWeek,
         "weekdays must be of length $daysInWeek",
       );

  final Set<DateTime> selectedDays;
  final Function(Set<DateTime>) changeDays;
  final List<String> weekdays;
  final Color backgroundColor;
  final Color selectedDigitBackgroundColor;
  final Color selectedDigitBorderColor;
  final Color selectedDigitColor;
  final Color digitsColor;
  final Color? weekdayTextColor;
  final bool enableWeeknumberText;
  final Color weeknumberColor;
  final Color weeknumberTextColor;
  final int daysInWeek;

  @override
  _WeeklyDatePickerState createState() => _WeeklyDatePickerState();
}

class _WeeklyDatePickerState extends State<CustomWeeklyDatePicker> {
  late DateTime _currentDate;
  late PageController _controller;
  late DateTime _initialSelectedDay;
  late int _weeknumberInSwipe;
  final DateTime _todaysDateTime = DateTime.now();
  final int _weekIndexOffset = 5200;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _initialSelectedDay = widget.selectedDays.isNotEmpty
        ? widget.selectedDays.first
        : DateTime.now();

    // Calculate initial page based on the selected date's week
    int initialWeekDifference =
        _initialSelectedDay.difference(_todaysDateTime).inDays ~/ 7;
    _controller = PageController(
      initialPage: _weekIndexOffset + initialWeekDifference,
    );
    _weeknumberInSwipe = _initialSelectedDay.weekOfYear;

    // Set initial selection
    if (widget.selectedDays.isEmpty) {
      widget.selectedDays.add(_initialSelectedDay);
      widget.changeDays(widget.selectedDays);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateMonth(bool increment) {
    setState(() {
      // Clear previous selection
      widget.selectedDays.clear();

      // Update current date to new month
      if (increment) {
        _currentDate = DateTime(
          _currentDate.year,
          _currentDate.month + 1,
          _currentDate.day,
        );
      } else {
        _currentDate = DateTime(
          _currentDate.year,
          _currentDate.month - 1,
          _currentDate.day,
        );
      }

      // Update selected day to the same day in new month
      _initialSelectedDay = _currentDate;
      widget.selectedDays.add(_initialSelectedDay);
      widget.changeDays(widget.selectedDays);

      // Calculate new page index based on the week difference
      int weekDifference =
          _initialSelectedDay.difference(_todaysDateTime).inDays ~/ 7;
      int newPage = _weekIndexOffset + weekDifference;

      // Jump to the week containing the selected date
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.jumpToPage(newPage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: [
        //       Bounce(
        //         onTap: () => _updateMonth(false),
        //         child: CommonImageView(
        //           imagePath: Assets.imagesLeftArrowBlueBg,
        //           height: 21,
        //         ),
        //       ),
        //       SizedBox(width: 13),
        //       MyText(
        //         text: DateFormat('MMMM yyyy').format(_currentDate),
        //         size: 14,
        //         weight: FontWeight.w800,
        //         color: kPrimaryColor,
        //       ),
        //       SizedBox(width: 13),
        //       Bounce(
        //         onTap: () => _updateMonth(true),
        //         child: CommonImageView(
        //           imagePath: Assets.imagesRightArrowBlueBg,
        //           height: 21,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Container(
          height: 80,
          color: widget.backgroundColor,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (int index) {
              setState(() {
                _weeknumberInSwipe = _initialSelectedDay
                    .addDays(7 * (index - _weekIndexOffset))
                    .weekOfYear;
              });
            },
            padEnds: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, weekIndex) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weekdays(weekIndex - _weekIndexOffset),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _weekdays(int weekIndex) {
    List<Widget> weekdays = [];
    for (int i = 0; i < widget.daysInWeek; i++) {
      final int offset = i - _initialSelectedDay.weekday;
      final int daysToAdd = weekIndex * 7 + offset;
      final DateTime dateTime = _initialSelectedDay.addDays(daysToAdd);
      weekdays.add(_dateButton(dateTime));
    }
    return weekdays;
  }

  Widget _dateButton(DateTime dateTime) {
    final String weekday = widget.weekdays[dateTime.weekday % 7];
    final bool isSelected = widget.selectedDays.any(
      (date) => date.isSameDateAs(dateTime),
    );

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              widget.selectedDays.removeWhere(
                (date) => date.isSameDateAs(dateTime),
              );
            } else {
              widget.selectedDays.add(dateTime);
            }
            widget.changeDays(widget.selectedDays);
          });
        },
        child: Container(
          height: 61,
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? widget.selectedDigitBackgroundColor : kWhite,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isSelected
                  ? widget.selectedDigitBackgroundColor
                  : kDividerColor,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                text: weekday,
                size: 12,
                weight: FontWeight.w400,
                color: isSelected ? Colors.white : kSubText,
              ),
              SizedBox(height: 4),
              MyText(
                text: '${dateTime.day}',
                size: 16,
                weight: FontWeight.w600,
                color: isSelected ? Colors.white : kSubText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors

class ScheduleCalendarPage extends StatefulWidget {
  const ScheduleCalendarPage({super.key});

  @override
  State<ScheduleCalendarPage> createState() => _ScheduleCalendarPageState();
}

class _ScheduleCalendarPageState extends State<ScheduleCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int selectedTimeIndex = -1;

  final List<String> timeSlots = [
    '08:00 PM',
    '08:30 PM',
    '09:00 PM',
    '09:30 PM',
    '10:00 PM',
    '10:30 PM',
    '11:00 PM',
    '11:30 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Calendar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(12),
                child: TableCalendar(
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
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimaryColor, width: 1.5),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: const Color(0xFFFFD37E),
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(color: Colors.black),
                    weekendTextStyle: TextStyle(color: Colors.black),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.black54),
                    weekendStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              const Gap(20),

              // Time Slots Title
              const MyText(
                text: "Available Time Slots",
                size: 16,
                weight: FontWeight.w600,
                color: Colors.black,
              ),
              const Gap(12),

              // Time Slots Grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(timeSlots.length, (index) {
                  final isSelected = selectedTimeIndex == index;
                  return Bounce(
                    onTap: () {
                      setState(() {
                        selectedTimeIndex = index;
                      });
                    },
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFFD37E)
                            : const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: MyText(
                          text: timeSlots[index],
                          color: isSelected ? Colors.black : Colors.black54,
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Gap(30),

              // Confirm Button
              Center(
                child: Bounce(
                  onTap: () {
                    if (_selectedDay == null || selectedTimeIndex == -1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select date and time.")),
                      );
                      return;
                    }
                    // Perform scheduling action
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: MyText(
                        text: "Confirm",
                        size: 16,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
