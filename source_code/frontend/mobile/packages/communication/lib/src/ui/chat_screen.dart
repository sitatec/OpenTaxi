import 'dart:async';
import 'package:intl/intl.dart';
import 'package:communication/src/domain/communication_manager.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/message/base_message.dart';
import 'package:shared/shared.dart' show gray, idToProfilePicture, lightGray;

const fastReplyMessage = [
  "I am Arrived",
  "I am waiting",
  "Hurry Up! I am waiting"
];

class ChatScreen extends StatefulWidget {
  final bool canCall;
  // final ComunicationManager _communicationManager;
  const ChatScreen(
      /*this._communicationManager,*/ {Key? key, this.canCall = true})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <BaseMessage>[];
  // String _typedMessage = "";
  var _textFieldController = TextEditingController();
  // late final _communicationManager = widget._communicationManager;
  StreamSubscription? _newMessageStreamSubscription;

  @override
  void initState() {
    super.initState();
    // _newMessageStreamSubscription =
    //     _communicationManager.newMessagesStream?.listen(
    //   (newMessage) {
    //     if (newMessage != null) {
    //       setState(() => _messages.insert(0, newMessage));
    //     }
    //   },
    // );
    _loadPreviousMessages();
    _textFieldController.addListener(() {
      if (_textFieldController.text.isEmpty ||
          _textFieldController.text.length == 1) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _newMessageStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPreviousMessages() async {
    if (_messages.length < 35) {
      for (int i = _messages.length, j = i + 10; i < j; i++) {
        final message = i % 3 == 0
            ? "Short Message"
            : i % 5 == 0
                ? "Medium message length just here."
                : "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Dui, facilisis a mi rutrum integer. Augue commodo convallis dictum bibendum tellus. Ipsum lobortis elit sit amet leo.";
        _messages.add(
          BaseMessage(
              message: message,
              sendingStatus: null,
              channelUrl: "channelUrl",
              channelType: ChannelType.group),
        );
      }
      _messages.add(
        BaseMessage(
            message: "",
            sendingStatus: null,
            channelUrl: "channelUrl",
            channelType: ChannelType.group),
      );
      await Future.delayed(const Duration(seconds: 1));
      setState(() {});
      // if (_communicationManager.previousMessagesQuery!.hasNext) {
      //   final previousMessage =
      //       await _communicationManager.previousMessagesQuery!.loadNext();
      //   setState(() {
      //     _messages.addAll(previousMessage);
      //   });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No old Message")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 3,
        toolbarHeight: 60,
        backgroundColor: theme.scaffoldBackgroundColor,
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.navigate_before, size: 28),
                ),
              ),
              CircleAvatar(
                backgroundImage: NetworkImage(idToProfilePicture("")),
                radius: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                "Nicole Mason",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              if (widget.canCall) ...[
                const Expanded(child: SizedBox()),
                InkWell(
                  onTap: () {},
                  child: Image.asset(
                    "assets/images/call.png",
                    package: "communication",
                  ),
                )
              ],
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _loadPreviousMessages,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 55),
                    itemCount: _messages.length,
                    // reverse: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: MessageWidet(
                          _messages[index],
                          isReceived: index % 2 == 0,
                        ),
                      );
                    },
                  ),
                ),
                if (_textFieldController.text.isEmpty)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < fastReplyMessage.length; i++)
                            InkWell(
                              onTap: () => setState(
                                () => _textFieldController.text =
                                    fastReplyMessage[i],
                              ),
                              child: Container(
                                margin:
                                    const EdgeInsets.only(left: 8, bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 6,
                                ),
                                child: Text(
                                  fastReplyMessage[i],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 30,
              left: 16,
              right: 16,
            ),
            color: lightGray,
            child: Row(
              children: [
                InkWell(
                  onTap: () {},
                  child: Image.asset(
                    "assets/images/image_icon.png",
                    package: "communication",
                    width: 35,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextField(
                    controller: _textFieldController,
                    maxLines: 4,
                    minLines: 1,
                    decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.send,
                        color: theme.primaryColor,
                        size: 22,
                      ),
                      contentPadding: const EdgeInsets.all(11),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      isDense: true,
                      isCollapsed: true,
                      hintText: "Type a message here",
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageWidet extends StatelessWidget {
  final bool isReceived;
  final BaseMessage message;

  const MessageWidet(this.message, {Key? key, this.isReceived = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text(_getTimeFromTimestamp(message.createdAt)),
        //     IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz)),
        //   ],
        // ),
        // TODO refactor create a separate sent message widget and received message widget.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:
              isReceived ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            Flexible(
              child: SizedBox(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 5),
                          child: Text(""),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 100),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isReceived
                                ? const Color(0xFF546071)
                                : Colors.white,
                            borderRadius: _getMessageBorderRadius(),
                            border: isReceived
                                ? null
                                : Border.all(color: const Color(0x40707C97)),
                          ),
                          child: Text(
                            message.message,
                            style: TextStyle(
                                color: isReceived ? Colors.white : gray),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _getTimeFromTimestamp(message.createdAt),
                      style: const TextStyle(color: gray, fontSize: 13),
                    ),
                    Positioned(
                      right: 0,
                      child: InkWell(
                        onTap: () {},
                        child: Icon(
                          Icons.more_horiz,
                          color: gray.withAlpha(180),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isReceived)
              Column(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(""),
                  ),
                  Icon(Icons.check, color: gray),
                ],
              )
          ],
        ),
      ],
    );
  }

  String _getTimeFromTimestamp(int timestamp) {
    final localDateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true).toLocal();
    final _numberFormatter = NumberFormat("00");
    final hour = _numberFormatter.format(localDateTime.hour);
    final minute = _numberFormatter.format(localDateTime.minute);
    return "$hour:$minute";
  }

  BorderRadius _getMessageBorderRadius() => isReceived
      ? const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        )
      : const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          topLeft: Radius.circular(16),
        );
}
