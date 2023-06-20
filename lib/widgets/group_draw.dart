import 'package:my_chatapp/pages/chat_page.dart';
import 'package:my_chatapp/widgets/widgets.dart';
import 'package:flutter/material.dart';

class GroupDraw extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;
  const GroupDraw(
      {Key? key,
      required this.groupId,
      required this.groupName,
      required this.userName})
      : super(key: key);

  @override
  State<GroupDraw> createState() => _GroupDrawState();
}

class _GroupDrawState extends State<GroupDraw> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
              groupId: widget.groupId,
              groupName: widget.groupName,
              userName: widget.userName,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white),
            ),
          ),
          title:
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0,0, 4),
            child: Text( widget.groupName, style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w800)),
          ),
          subtitle: Text(
            "${widget.userName} 님이 방에 입장 ",
            style: const TextStyle(fontSize: 13),
          ),
          trailing: Icon(
            Icons.send,
            color: Theme.of(context).primaryColor,
            size: 30,
          ),
        ),
      ),
    );
  }
}
