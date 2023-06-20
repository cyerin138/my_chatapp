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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 10, 5),
            child: Text(
              user.toUpperCase(),
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
              ),
            ),
          ),
          ChatBubble(
            clipper: clipper,
            alignment: Alignment.topRight,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 0, 5),
            child: Text(
              user.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
),
            ),
          ),
          ChatBubble(
            clipper: clipper,
            backGroundColor: Color(0xffE7E7ED),
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
