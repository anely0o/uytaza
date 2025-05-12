import 'package:flutter/material.dart';
import 'package:uytaza/common/color_extension.dart';
import 'package:uytaza/common/extension.dart';
import 'package:uytaza/common_widget/image_picker_screen.dart';
import 'package:uytaza/common_widget/popup_layout.dart';

class ChatMessageScreen extends StatefulWidget {
  const ChatMessageScreen({super.key});

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.primary,
      appBar: AppBar(
        backgroundColor: TColor.primary,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              "assets/img/only_logo.png",
              height: 100,
              fit: BoxFit.fitHeight,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Image.asset("assets/img/back.png"),
          ),
        ],
        leading: IconButton(
          onPressed: () {},
          icon: Image.asset("assets/img/menu.png", width: 20, height: 20),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: double.maxFinite,
            height: context.height * 0.75,
            decoration: BoxDecoration(
              color: TColor.secondary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Image.asset(
                  "assets/img/user_placeholder.png",
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),

              const Text(
                "Anida Mitalipova",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      itemBuilder: (context, index) {
                        bool isSender = index % 2 == 1;

                        return Row(
                          mainAxisAlignment:
                              isSender
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isSender) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "12:12",
                                  style: TextStyle(
                                    color: TColor.placeholder,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 15,
                              ),
                              constraints: BoxConstraints(
                                maxWidth: context.width * 0.50,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSender
                                        ? TColor.chatTextBG
                                        : TColor.chatTextBG2,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                  bottomLeft: Radius.circular(
                                    isSender ? 30 : 0,
                                  ),
                                  bottomRight: Radius.circular(
                                    !isSender ? 30 : 0,
                                  ),
                                ),
                              ),
                              child: Text(
                                isSender
                                    ? "hi"
                                    : "Hi ma name is MArzhan and i want to order a carpet cleaning",
                                style: TextStyle(
                                  color:
                                      isSender
                                          ? Colors.white
                                          : TColor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isSender) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "12:12",
                                  style: TextStyle(
                                    color: TColor.placeholder,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 15),
                      itemCount: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: TColor.secondary),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          top: 18,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  PopupLayout(
                    bgColor: Colors.black12,
                    child: ImagePickerScreen(
                      didSelect: (selectPath) {
                        debugPrint(selectPath);
                      },
                    ),
                  ),
                );
              },
              child: Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                  color: TColor.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/img/camera.png",
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 100),
                        child: TextField(
                          maxLines: null,
                          autocorrect: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(12),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: "Type Message here",
                            hintStyle: TextStyle(
                              color: TColor.placeholder,
                              fontSize: 15,
                            ),
                          ),
                          style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Image.asset(
                        "assets/img/send.png",
                        height: 35,
                        width: 35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
