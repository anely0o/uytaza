import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/icon_select_button.dart';
import 'package:uytaza/common_widget/round_button.dart';
import 'package:uytaza/screen/order/client/order_success_page.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int selectMethod = 1;
  bool selectSavePaypal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back, color: TColor.primary),
        ),
        title: Text(
          selectMethod == 0
              ? "Credit Card"
              : selectMethod == 1
              ? "Paypal"
              : "Cash",
          style: TextStyle(
            color: TColor.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: selectMethod == 1
                ? ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15, vertical: 30),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: TColor.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            "assets/img/paypal.png",
                            width: 70,
                            fit: BoxFit.fitWidth,
                          ),
                          IconButton(
                            onPressed: () {
                              // more options
                            },
                            icon: Icon(
                              Icons.more_horiz,
                              color: TColor.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "123456@paypal.me",
                        style: TextStyle(
                          color: TColor.textPrimary,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Added on 15/05/2025",
                        style: TextStyle(
                          color: TColor.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) =>
              const SizedBox(height: 15),
              itemCount: 1,
            )
                : selectMethod == 2
                ? Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 20),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: TColor.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Cash",
                                  style: TextStyle(
                                    color: TColor.textPrimary,
                                    fontSize: 17,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Pay once you get the order at your home",
                                  style: TextStyle(
                                    color: TColor.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              // select this
                            },
                            icon: Icon(
                              Icons.check_circle_outline,
                              color: selectMethod == 2
                                  ? TColor.primary
                                  : TColor.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
                : Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: TColor.softShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/img/master_card.png",
                        width: 70,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Master Card",
                              style: TextStyle(
                                color: TColor.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "**** **** **** 4748",
                              style: TextStyle(
                                color: TColor.textPrimary,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // update card
                        },
                        child: Text(
                          "Update",
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: IconSelectButton(
                    icon: "assets/img/credit_card_payment.png",
                    isSelect: selectMethod == 0,
                    onPressed: () {
                      setState(() {
                        selectMethod = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: IconSelectButton(
                    icon: "assets/img/ic_paypal.png",
                    isSelect: selectMethod == 1,
                    onPressed: () {
                      setState(() {
                        selectMethod = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: IconSelectButton(
                    icon: "assets/img/Ic_saved_cards.png",
                    isSelect: selectMethod == 2,
                    onPressed: () {
                      setState(() {
                        selectMethod = 2;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectSavePaypal = !selectSavePaypal;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectSavePaypal
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: selectSavePaypal
                              ? TColor.primary
                              : TColor.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Save PayPal ID",
                          style: const TextStyle(
                            fontSize: 15,
                          ).copyWith(color: TColor.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                RoundButton(
                  width: 150,
                  title: "Next",
                  backgroundColor: TColor.primary,
                  textColor: Colors.white,
                  onPressed: () {
                    context.push(const OrderSuccessPage());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
