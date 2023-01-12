import 'dart:async';

import 'package:chat_gpt_bot/three_dots.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

import 'chat_message.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messagesList = [];
  ChatGPT? chatGPT;
  bool _isImageSearch = false;

  StreamSubscription? _subscription;
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    chatGPT = ChatGPT.instance;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    ChatMessage message = ChatMessage(text: _controller.text, sender: "user");
    setState(() {
      _messagesList.insert(0, message);
      isTyping = true;
    });
    _controller.clear();

    final request = CompleteReq(
        prompt: message.text, model: kTranslateModelV3, max_tokens: 200);
    _subscription = chatGPT!
        .builder("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",
            orgId: "")
        .onCompleteStream(request: request)
        .listen((response) {
      Vx.log(response!.choices[0].text);
      ChatMessage botmessage = ChatMessage(
        text: response!.choices[0].text,
        sender: "bot",
      );
      setState(() {
        isTyping = false;
        _messagesList.insert(0, botmessage);
      });
    });
  }

  Widget _buildTextComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: InputDecoration.collapsed(hintText: 'Send a Message'),
          ),
        ),
        IconButton(
          onPressed: () => _sendMessage(),
          icon: Icon(Icons.send),
        ),
      ],
    ).px8();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Chat GPT Bot',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
              reverse: true,
              padding: Vx.m12,
              itemCount: _messagesList.length,
              itemBuilder: (context, index) {
                return _messagesList[index];
              },
            )),
            if (isTyping) ThreeDots(),
            const Divider(
              height: 1,
            ),
            Container(
              decoration: BoxDecoration(color: context.cardColor),
              child: _buildTextComposer(),
            )
          ],
        ),
      ),
    );
  }
}
