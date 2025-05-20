import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';

import 'package:uytaza/screen/order/calendar_page.dart';

class OrderBuildPage extends StatefulWidget {
  const OrderBuildPage({super.key});

  @override
  State<OrderBuildPage> createState() => _OrderBuildPageState();
}

class _OrderBuildPageState extends State<OrderBuildPage> {
  String selectedType = "initial";
  String selectedFrequency = "monthly";
  Set<String> selectedExtras = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          "Your Plan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Selected Cleaning",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          changeCleaningType("initial");
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 140,
                              width: MediaQuery.of(context).size.width * 0.43,
                              decoration: BoxDecoration(
                                color: TColor.primary.withOpacity(0.5),
                                image: DecorationImage(
                                  image: AssetImage(
                                    "assets/img/carpet_service.png",
                                  ),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Initial CLeaning",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child:
                                  (selectedType == "initial")
                                      ? Icon(
                                        Icons.check_circle,
                                        color: TColor.secondary,
                                        size: 30,
                                      )
                                      : Container(),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          changeCleaningType("upkeep");
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 140,
                              width: MediaQuery.of(context).size.width * 0.43,
                              decoration: BoxDecoration(
                                color: TColor.primary.withOpacity(0.5),
                                image: DecorationImage(
                                  image: AssetImage(
                                    "assets/img/disifnfection_service.png",
                                  ),
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Upkeep Cleaning",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffededed),
                              ),
                              child:
                                  (selectedType == "upkeep")
                                      ? Icon(
                                        Icons.check_circle,
                                        color: TColor.secondary,
                                        size: 30,
                                      )
                                      : Container(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    "selected Frequecy",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          changeFrequency("weekly");
                        },
                        child: Container(
                          height: 50,
                          width: 110,
                          decoration:
                              (selectedFrequency == "weekly")
                                  ? BoxDecoration(
                                    color: TColor.secondary,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  )
                                  : BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                          child: Center(
                            child: Text(
                              "Weekly",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    (selectedFrequency == "weekly")
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          changeFrequency("biweekly");
                        },
                        child: Container(
                          height: 50,
                          width: 110,
                          decoration:
                              (selectedFrequency == "biweekly")
                                  ? BoxDecoration(
                                    color: TColor.secondary,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  )
                                  : BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                          child: Center(
                            child: Text(
                              "Bi-Weekly",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    (selectedFrequency == "biweekly")
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          changeFrequency("monthly");
                        },
                        child: Container(
                          height: 50,
                          width: 110,
                          decoration:
                              (selectedFrequency == "monthly")
                                  ? BoxDecoration(
                                    color: TColor.secondary,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  )
                                  : BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                          child: Center(
                            child: Text(
                              "Monthly",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    (selectedFrequency == "monthly")
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Selected Extras",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      extraWidget("carpet", "Carpet", true),
                      extraWidget("hand-sanitizer", "Disinfection", true),
                      extraWidget("window-cleaning", "Windows", false),
                      extraWidget("laundry", "Laundry", false),
                    ],
                  ),
                  Expanded(child: Container()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CalendarPage(
                                    cleaningType: selectedType,
                                    frequency: selectedFrequency,
                                    extras: selectedExtras.toList(),
                                  ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: TColor.primary,
                          ),
                          child: Text(
                            "Next",
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changeCleaningType(String type) {
    selectedType = type;
    setState(() {});
  }

  void changeFrequency(String frequency) {
    selectedFrequency = frequency;
    setState(() {});
  }

  Column extraWidget(String img, String name, bool initiallySelected) {
    final isSelected = selectedExtras.contains(name);
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedExtras.remove(name);
              } else {
                selectedExtras.add(name);
              }
            });
          },
          child: Stack(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TColor.primary,
                ),
                child: Container(
                  margin: EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/$img.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Icon(Icons.check_circle, color: TColor.primary),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 5),
        Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  void openCalendarPage() {
    Navigator.pushNamed(context, '/CalendarPage');
  }
}
