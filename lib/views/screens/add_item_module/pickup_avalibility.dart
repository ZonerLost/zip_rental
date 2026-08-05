import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zip_peer/constants/app_colors.dart';
import 'package:zip_peer/controllers/items/add_item_controller.dart';
import 'package:zip_peer/generated/assets.dart';
import 'package:zip_peer/models/items/item_models.dart';
import 'package:zip_peer/views/screens/add_item_module/bosst.dart';
import 'package:zip_peer/views/widget/common_image_view_widget.dart';
import 'package:zip_peer/views/widget/custom_animated_column.dart';
import 'package:zip_peer/views/widget/my_button_new.dart';
import 'package:zip_peer/views/widget/my_text_widget.dart';

class PickupAvailabilityScreen extends StatefulWidget {
  const PickupAvailabilityScreen({super.key});

  @override
  State<PickupAvailabilityScreen> createState() =>
      _PickupAvailabilityScreenState();
}

class _PickupAvailabilityScreenState extends State<PickupAvailabilityScreen> {
  DateTime selectedWeekStart = DateTime.now();
  String? scheduleType; // recurring or specific
  String? bookingType; // manual or instant
  String? rentalType; // delivery, pickup, or both
  Map<String, dynamic>? itemDraft;

  final Map<String, bool> dayAvailability = {
    'Monday': true,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };

  // "All Day" defaults to 9:00 AM - 8:00 PM
  final Map<String, Map<String, TimeOfDay>> dayTimes = {
    'Monday': {
      'from': TimeOfDay(hour: 9, minute: 0),
      'to': TimeOfDay(hour: 20, minute: 0),
    },
    'Tuesday': {
      'from': TimeOfDay(hour: 9, minute: 0),
      'to': TimeOfDay(hour: 20, minute: 0),
    },
    'Wednesday': {
      'from': TimeOfDay(hour: 9, minute: 0),
      'to': TimeOfDay(hour: 20, minute: 0),
    },
    'Thursday': {
      'from': TimeOfDay(hour: 9, minute: 0),
      'to': TimeOfDay(hour: 20, minute: 0),
    },
    'Friday': {
      'from': TimeOfDay(hour: 9, minute: 0),
      'to': TimeOfDay(hour: 20, minute: 0),
    },
    'Saturday': {
      'from': TimeOfDay(hour: 9, minute: 0),
      'to': TimeOfDay(hour: 20, minute: 0),
    },
    'Sunday': {
      'from': TimeOfDay(hour: 9, minute: 0),
      'to': TimeOfDay(hour: 20, minute: 0),
    },
  };

  // Track which days are using "All Day" mode
  final Map<String, bool> dayAllDayMode = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': true,
    'Sunday': true,
  };

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      scheduleType = Get.arguments['scheduleType'];
      bookingType = Get.arguments['bookingType'] ?? 'manual';
      rentalType = Get.arguments['rentalType'];
      if (Get.arguments['itemDraft'] is Map<String, dynamic>) {
        itemDraft = Get.arguments['itemDraft'] as Map<String, dynamic>;
      }
    }
    scheduleType ??= itemDraft?['scheduleType'] as String?;
    _restoreFromDraft();
  }

  // Pre-fills the weekly schedule if this step was already completed earlier
  // in this session (e.g. the user went back to step 1 and is now continuing
  // forward again through a freshly-built instance of this screen).
  void _restoreFromDraft() {
    final saved = itemDraft?['pickupDaySchedule'];
    if (saved is! Map) return;

    TimeOfDay? parseTime(dynamic raw) {
      final parts = raw?.toString().split(':');
      if (parts == null || parts.length != 2) return null;
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) return null;
      return TimeOfDay(hour: hour, minute: minute);
    }

    saved.forEach((day, value) {
      final dayKey = day.toString();
      if (!dayAvailability.containsKey(dayKey) || value is! Map) return;

      dayAvailability[dayKey] = value['enabled'] == true;
      dayAllDayMode[dayKey] = value['allDay'] != false;

      final from = parseTime(value['from']);
      final to = parseTime(value['to']);
      if (from != null && to != null) {
        dayTimes[dayKey] = {'from': from, 'to': to};
      }
    });
  }

  String getWeekRangeText() {
    final endDate = selectedWeekStart.add(Duration(days: 6));
    return '${DateFormat('MMM d').format(selectedWeekStart)} - ${DateFormat('MMM d, yyyy').format(endDate)}';
  }

  void previousWeek() {
    setState(() {
      selectedWeekStart = selectedWeekStart.subtract(Duration(days: 7));
    });
  }

  void nextWeek() {
    setState(() {
      selectedWeekStart = selectedWeekStart.add(Duration(days: 7));
    });
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> selectTime(String day, bool isFrom) async {
    final currentTime = isFrom
        ? dayTimes[day]!['from']!
        : dayTimes[day]!['to']!;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          dayTimes[day]!['from'] = picked;
        } else {
          dayTimes[day]!['to'] = picked;
        }
        // Once user customizes time, disable "All Day" mode
        dayAllDayMode[day] = false;
      });
    }
  }

  void toggleAllDay(String day) {
    setState(() {
      if (dayAllDayMode[day]!) {
        // User is turning OFF "All Day" - keep current times
        dayAllDayMode[day] = false;
      } else {
        // User is turning ON "All Day" - reset to 9 AM - 8 PM
        dayAllDayMode[day] = true;
        dayTimes[day]!['from'] = TimeOfDay(hour: 9, minute: 0);
        dayTimes[day]!['to'] = TimeOfDay(hour: 20, minute: 0);
      }
    });
  }

  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  WeeklyScheduleModel _buildSchedule() {
    final days = <String, DayScheduleModel>{};
    for (final entry in dayAvailability.entries) {
      final dayKey = entry.key.toLowerCase();
      final enabled = entry.value;
      if (!enabled) {
        days[dayKey] = const DayScheduleModel(enabled: false);
      } else {
        final times = dayTimes[entry.key]!;
        days[dayKey] = DayScheduleModel(
          enabled: true,
          startTime: _fmtTime(times['from']!),
          endTime: _fmtTime(times['to']!),
        );
      }
    }
    return WeeklyScheduleModel(
      recurringDays: days,
      scheduleType: scheduleType ?? 'recurring',
    );
  }

  // Raw, restorable form of the same schedule — used to pre-fill this
  // screen's toggles/times if the user comes back through it again.
  Map<String, dynamic> _buildRawDaySchedule() {
    final raw = <String, dynamic>{};
    for (final entry in dayAvailability.entries) {
      final day = entry.key;
      final times = dayTimes[day]!;
      raw[day] = {
        'enabled': entry.value,
        'allDay': dayAllDayMode[day] ?? true,
        'from': _fmtTime(times['from']!),
        'to': _fmtTime(times['to']!),
      };
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyButton(
              onTap: () {
                final schedule = _buildSchedule();
                final rawDaySchedule = _buildRawDaySchedule();

                if (Get.isRegistered<AddItemController>()) {
                  Get.find<AddItemController>().mergeExtraDraftFields({
                    'bookingType': bookingType,
                    'pickupDaySchedule': rawDaySchedule,
                  });
                }

                Get.to(
                  () => const BoostScreen(),
                  arguments: {
                    'bookingType': bookingType,
                    'rentalType': rentalType,
                    'scheduleType': scheduleType,
                    'pickupSchedule': schedule,
                    'itemDraft': {
                      ...?itemDraft,
                      'bookingType': bookingType,
                      'pickupDaySchedule': rawDaySchedule,
                    },
                  },
                );
              },
              buttonText: "Continue",
              fontColor: Colors.white,
              height: 56,
              radius: 28,
              hasgrad: false,
              fontSize: 17,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Bounce(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    CommonImageView(imagePath: Assets.imagesBack, height: 40),
                    Gap(8),
                    MyText(
                      text: "Pickup Availability",
                      size: 18,
                      weight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              MyText(text: "Step 3/5", size: 14, color: kSubText),
            ],
          ),
          Gap(24),

          // Show week selector only for specific dates
          if (scheduleType == 'specific') ...[
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Bounce(
                    onTap: previousWeek,
                    child: Icon(Icons.chevron_left, size: 28),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 20),
                      Gap(8),
                      MyText(
                        text: getWeekRangeText(),
                        size: 16,
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  Bounce(
                    onTap: nextWeek,
                    child: Icon(Icons.chevron_right, size: 28),
                  ),
                ],
              ),
            ),
            Gap(24),
          ],

          // Days List
          ...dayAvailability.keys.map((day) {
            final isEnabled = dayAvailability[day]!;
            final isAllDay = dayAllDayMode[day]!;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(text: day, size: 16, weight: FontWeight.w600),
                        Switch(
                          value: isEnabled,
                          onChanged: (value) {
                            setState(() {
                              dayAvailability[day] = value;
                            });
                          },
                          activeColor: kPrimaryColor,
                          inactiveTrackColor: kbackground,
                        ),
                      ],
                    ),
                    if (isEnabled && scheduleType != 'specific') ...[
                      Gap(10),
                      Divider(color: kDividerColor),
                      Gap(10),

                      // "All Day" toggle with explanation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: "All Day",
                                size: 14,
                                weight: FontWeight.w600,
                              ),
                              Gap(2),
                              MyText(
                                text: "9:00 AM - 6:00 PM",
                                size: 12,
                                color: kSubText,
                              ),
                            ],
                          ),
                          Switch(
                            value: isAllDay,
                            onChanged: (value) => toggleAllDay(day),
                            activeColor: kPrimaryColor,
                            inactiveTrackColor: kbackground,
                          ),
                        ],
                      ),

                      // Show time pickers only if NOT in "All Day" mode
                      if (!isAllDay) ...[
                        Gap(12),
                        Row(
                          children: [
                            Expanded(
                              child: Bounce(
                                onTap: () => selectTime(day, true),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: kWhite3,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: "From",
                                        size: 12,
                                        color: kSubText,
                                      ),
                                      Gap(4),
                                      MyText(
                                        text: formatTimeOfDay(
                                          dayTimes[day]!['from']!,
                                        ),
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
                                onTap: () => selectTime(day, false),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: kWhite3,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        text: "To",
                                        size: 12,
                                        color: kSubText,
                                      ),
                                      Gap(4),
                                      MyText(
                                        text: formatTimeOfDay(
                                          dayTimes[day]!['to']!,
                                        ),
                                        size: 16,
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
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          Gap(20),
        ],
      ),
    );
  }
}
