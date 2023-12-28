import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpt_deneme/main.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isuser;

  ChatMessage({required this.text, required this.isuser});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  List<ChatMessage> chatMessages = [];

  void sendMessage(String message) async {
    final response = await http.post(
        Uri.parse(
            'https://api.openai.com/v1/engines/text-davinci-003/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $api_key',
        },
        body: json.encode({
          'prompt': message,
          'max_tokens': 50,
        }));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        chatMessages.add(ChatMessage(text: message, isuser: true));
        chatMessages.add(ChatMessage(
            text: jsonResponse['choices'][0]['text'], isuser: false));
      });
    } else {
      print(" Request Failed with Status : ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chatgpt app'),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: chatMessages.length,
            itemBuilder: (context, index) {
              final message = chatMessages[index];
              return ChatBubble(
                text: message.text,
                isUser: message.isuser,
              );
            },
          )),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: messageController,
                  decoration:
                      const InputDecoration(hintText: 'enter your message'),
                )),
                IconButton(
                    onPressed: () {
                      sendMessage(messageController.text);
                      messageController.clear();
                    },
                    icon: const Icon(Icons.send)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            const CircleAvatar(
              backgroundColor: Colors.black,
              child: Text('AI'),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(10)),
            child: Text(text,
                style: const TextStyle(
                  color: Colors.white,
                )),
          ),
          if (isUser)
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.person),
            )
        ],
      ),
    );
  }
}
