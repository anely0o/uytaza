// 📄 ChatMessageScreen.dart — Обновлённый стиль

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
      backgroundColor: TColor.background,
      appBar: AppBar(
        backgroundColor: TColor.card,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage("assets/img/user_placeholder.png"),
              radius: 20,
            ),
            const SizedBox(width: 12),
            Text("Adviser",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) {
                bool isSender = index % 2 == 0;
                return Align(
                  alignment: isSender
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints:
                    BoxConstraints(maxWidth: context.width * 0.7),
                    decoration: BoxDecoration(
                      color: isSender
                          ? TColor.primary.withOpacity(0.85)
                          : TColor.card,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                        Radius.circular(isSender ? 16 : 0),
                        bottomRight:
                        Radius.circular(isSender ? 0 : 16),
                      ),
                      boxShadow: TColor.softShadow,
                    ),
                    child: Text(
                      isSender ? "Thank you for contacting us!" : "Hello!",
                      style: TextStyle(
                        color: isSender ? Colors.white : TColor.primaryText,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
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
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: TColor.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: TColor.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Type your message",
                              hintStyle: TextStyle(
                                  color: TColor.placeholder, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send_rounded,
                              color: TColor.primary),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
