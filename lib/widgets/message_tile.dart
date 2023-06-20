import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;

  const MessageTile(
      {Key? key,
      required this.message,
      required this.sender,
      required this.sentByMe})
      : super(key: key);

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: widget.sentByMe
          ? getSenderView(ChatBubbleClipper3(type: BubbleType.sendBubble),
              context, widget.message, widget.sender)
          : getReceiverView(ChatBubbleClipper3(type: BubbleType.receiverBubble),
              context, widget.message, widget.sender),
    );
  }

  getSenderView(CustomClipper clipper, BuildContext context, String text,
          String user) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            user.toUpperCase(),
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 5),
          ),
          ChatBubble(
            clipper: clipper,
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: 20),
            backGroundColor: Theme.of(context).primaryColor,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                text,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),

        ],
      );

  getReceiverView(
          CustomClipper clipper, BuildContext, String text, String user) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.toUpperCase(),
            textAlign: TextAlign.start,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5),
          ),
          ChatBubble(
            clipper: clipper,
            backGroundColor: Color(0xffE7E7ED),
            margin: EdgeInsets.only(top: 20),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                text,
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ),

        ],
      );
}
