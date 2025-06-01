import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/screen/order/client/payment_method_screen.dart';

class OrderBuildPage extends StatefulWidget {
  const OrderBuildPage({super.key});

  @override
  State<OrderBuildPage> createState() => _OrderBuildPageState();
}

class _OrderBuildPageState extends State<OrderBuildPage> {
  String selectedType = "initial";
  String selectedFrequency = "monthly";
  Set<String> selectedExtras = {};

  DateTime selectedDate = DateTime.now();
  DateTime displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  void changeCleaningType(String type) {
    setState(() {
      selectedType = type;
    });
  }

  void changeFrequency(String frequency) {
    setState(() {
      selectedFrequency = frequency;
    });
  }

  void toggleExtra(String extra) {
    setState(() {
      if (selectedExtras.contains(extra)) {
        selectedExtras.remove(extra);
      } else {
        selectedExtras.add(extra);
      }
    });
  }

  Widget extraWidget(String key, String title, bool isTop) {
    bool isSelected = selectedExtras.contains(key);
    return InkWell(
      onTap: () {
        toggleExtra(key);
      },
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: isSelected ? TColor.secondary : const Color(0xffededed),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.check,
                color: isSelected ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Your Plan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Selected Cleaning",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        cleaningTypeCard(
                          "initial",
                          "Initial Cleaning",
                          "assets/img/carpet_service.png",
                        ),
                        cleaningTypeCard(
                          "upkeep",
                          "Upkeep Cleaning",
                          "assets/img/disifnfection_service.png",
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Selected Frequency",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        frequencyOption("weekly"),
                        frequencyOption("biweekly"),
                        frequencyOption("monthly"),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Selected Extras",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        extraWidget("carpet", "Carpet", true),
                        extraWidget("hand-sanitizer", "Disinfection", true),
                        extraWidget("window-cleaning", "Windows", false),
                        extraWidget("laundry", "Laundry", false),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Select Date",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    calendarWidget(),
                    const SizedBox(height: 20),
                    Text(
                      "Selected: ${selectedDate.day.toString().padLeft(2, '0')}.${selectedDate.month.toString().padLeft(2, '0')}.${selectedDate.year}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentMethodScreen(),
                    ),
                  );
                },
                child: const Text("Next"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cleaningTypeCard(String type, String label, String imagePath) {
    return InkWell(
      onTap: () {
        changeCleaningType(type);
      },
      child: Column(
        children: [
          Container(
            height: 140,
            width: MediaQuery.of(context).size.width * 0.43,
            decoration: BoxDecoration(
              color: TColor.primary.withOpacity(0.5),
              image: DecorationImage(image: AssetImage(imagePath)),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  selectedType == type ? Colors.white : const Color(0xffededed),
            ),
            child:
                selectedType == type
                    ? Icon(
                      Icons.check_circle,
                      color: TColor.secondary,
                      size: 30,
                    )
                    : Container(),
          ),
        ],
      ),
    );
  }

  Widget frequencyOption(String freq) {
    return InkWell(
      onTap: () {
        changeFrequency(freq);
      },
      child: Container(
        height: 50,
        width: 110,
        decoration:
            selectedFrequency == freq
                ? BoxDecoration(
                  color: TColor.secondary,
                  borderRadius: BorderRadius.circular(10),
                )
                : BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
        child: Center(
          child: Text(
            freq[0].toUpperCase() + freq.substring(1).replaceAll("-", " "),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: selectedFrequency == freq ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget calendarWidget() {
    final year = displayedMonth.year;
    final month = displayedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday;

    List<Widget> dayWidgets = [];

    List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    dayWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            weekDays
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TColor.primary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );

    List<Widget> days = [];
    for (int i = 0; i < firstWeekday - 1; i++) {
      days.add(const Expanded(child: SizedBox()));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDay = DateTime(year, month, day);
      final isSelected =
          selectedDate.year == currentDay.year &&
          selectedDate.month == currentDay.month &&
          selectedDate.day == currentDay.day;
      final isPast = currentDay.isBefore(
        DateTime.now().subtract(const Duration(days: 1)),
      );

      days.add(
        Expanded(
          child: GestureDetector(
            onTap:
                isPast
                    ? null
                    : () {
                      setState(() {
                        selectedDate = currentDay;
                      });
                    },
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? TColor.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: TextStyle(
                    color: isPast ? Colors.grey : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      if ((days.length) % 7 == 0) {
        dayWidgets.add(Row(children: days));
        days = [];
      }
    }

    if (days.isNotEmpty) {
      while (days.length < 7) {
        days.add(const Expanded(child: SizedBox()));
      }
      dayWidgets.add(Row(children: days));
    }

    return Column(children: dayWidgets);
  }
}
