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
    // return Container(
    //
    //   padding: EdgeInsets.only(
    //       top: 4,
    //       bottom: 4,
    //       left: widget.sentByMe ? 0 : 24,
    //       right: widget.sentByMe ? 24 : 0),
    //   alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
    //   child: Container(
    //     margin: widget.sentByMe
    //         ? const EdgeInsets.only(left: 30)
    //         : const EdgeInsets.only(right: 30),
    //     padding:
    //         const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
    //     decoration: BoxDecoration(
    //         borderRadius: widget.sentByMe
    //             ? const BorderRadius.only(
    //                 topLeft: Radius.circular(20),
    //                 topRight: Radius.circular(20),
    //                 bottomLeft: Radius.circular(20),
    //               )
    //             : const BorderRadius.only(
    //                 topLeft: Radius.circular(20),
    //                 topRight: Radius.circular(20),
    //                 bottomRight: Radius.circular(20),
    //               ),
    //         color: widget.sentByMe
    //             ? Theme.of(context).primaryColor
    //             : Colors.grey[700]),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           widget.sender.toUpperCase(),
    //           textAlign: TextAlign.start,
    //           style: const TextStyle(
    //               fontSize: 13,
    //               fontWeight: FontWeight.bold,
    //               color: Colors.white,
    //               letterSpacing: -0.5),
    //         ),
    //         const SizedBox(
    //           height: 8,
    //         ),
    //         Text(widget.message,
    //             textAlign: TextAlign.start,
    //             style: const TextStyle(fontSize: 16, color: Colors.white))
    //       ],
    //     ),
    //   ),
    // );
  }

  getSenderView(CustomClipper clipper, BuildContext context, String text,
          String user) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
          Text(
            user.toUpperCase(),
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 5),
          ),
        ],
      );

  getReceiverView(
          CustomClipper clipper, BuildContext, String text, String user) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            user.toUpperCase(),
            textAlign: TextAlign.start,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: -0.5),
          ),
        ],
      );
}
