import 'dart:async';
import 'package:intl/intl.dart';
import 'package:communication/src/domain/communication_manager.dart';
import 'package:flutter/material.dart';
import 'package:sendbird_sdk/core/message/base_message.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';
import 'package:shared/shared.dart' show gray, idToProfilePicture, lightGray;
import 'package:simple_tooltip/simple_tooltip.dart';

const fastReplyMessage = [
  "I am Arrived",
  "I am waiting",
  "Hurry Up! I am waiting"
];

class ChatScreen extends StatefulWidget {
  final bool canCall;
  final CommunicationManager _communicationManager;
  const ChatScreen(this._communicationManager, {Key? key, this.canCall = true})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <BaseMessage>[];
  var _textFieldController = TextEditingController();
  bool _loadingMoreMessages = false;
  late final _communicationManager = widget._communicationManager;
  StreamSubscription? _newMessageStreamSubscription;
  bool _isSendingMessage = false;
  final _listViewScrollController = ScrollController();
  // TODO find a meaningfull name
  int _lastMessageIndex = CommunicationManager.messageLoadPageSize - 1;

  @override
  void initState() {
    super.initState();
    _newMessageStreamSubscription =
        _communicationManager.newMessagesStream?.listen(
      (newMessage) {
        if (newMessage != null) {
          setState(() => _messages.insert(0, newMessage));
        }
      },
    );
    _loadPreviousMessages();
    _textFieldController.addListener(() {
      if (_textFieldController.text.isEmpty ||
          _textFieldController.text.length == 1) {
        setState(() {});
        // show or hide fast reply messages
      }
    });
    _listViewScrollController.addListener(() {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    _newMessageStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPreviousMessages() async {
    if (_loadingMoreMessages) return;
    // if (_messages.length < 35) {
    //   for (int i = _messages.length, j = i + 10; i < j; i++) {
    //     final message = i % 3 == 0
    //         ? "Short Message"
    //         : i % 5 == 0
    //             ? "Medium message length just here."
    //             : "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Dui, facilisis a mi rutrum integer. Augue commodo convallis dictum bibendum tellus. Ipsum lobortis elit sit amet leo.";
    //     _messages.add(
    //       BaseMessage(
    //           message: message,
    //           sendingStatus: null,
    //           channelUrl: "channelUrl",
    //           channelType: ChannelType.group),
    //     );
    //   }
    //   _messages.add(
    //     BaseMessage(
    //         message: "",
    //         sendingStatus: null,
    //         channelUrl: "channelUrl",
    //         channelType: ChannelType.group),
    //   );
    //   await Future.delayed(const Duration(seconds: 1));
    //   setState(() {});
    if (_communicationManager.previousMessagesQuery!.hasNext) {
      try {
        setState(() {
          _loadingMoreMessages = true;
        });
        final previousMessage =
            await _communicationManager.previousMessagesQuery!.loadNext();
        setState(() {
          _messages.addAll(previousMessage);
          _loadingMoreMessages = false;
        });
        if (_messages.length > CommunicationManager.messageLoadPageSize) {
          _listViewScrollController.animateTo(
            _listViewScrollController.offset + 150,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeIn,
          );
        }
      } catch (e) {
        print(e);
        setState(() {
          _loadingMoreMessages = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("No old Messages")));
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
              Text(
                _communicationManager.channelData.remoteUserName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _listViewScrollController,
                    reverse: true,
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 55),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      if (index >= _lastMessageIndex) {
                        Future.delayed(Duration.zero, () async {
                          await _loadPreviousMessages();
                          _lastMessageIndex +=
                              CommunicationManager.messageLoadPageSize;
                        });
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: MessageWidet(
                          message,
                          isReceived: !message.sender!.isCurrentUser,
                        ),
                      );
                    },
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
                    ),
                  if (_isSendingMessage)
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(bottom: 16, right: 45),
                          child: CircularProgressIndicator(
                              color: theme.primaryColor),
                        )),
                  if (_loadingMoreMessages)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                            color: theme.primaryColor),
                      ),
                    ),
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
                        suffixIcon: IconButton(
                          onPressed: () async {
                            // TODO check if `_typedMessage` is not empty and add send file feature as well. and add loading message while sending message
                            if (_isSendingMessage) return;
                            setState(() {
                              _isSendingMessage = true;
                            });
                            try {
                              final message = await _communicationManager
                                  .sendTextMessage(_textFieldController.text);
                              setState(() {
                                _messages.insert(0, message);
                                _isSendingMessage = false;
                                _textFieldController.text = "";
                              });
                            } catch (e) {
                              setState(() {
                                _isSendingMessage = false;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Failed to send message"),
                                  ),
                                );
                              });
                            }
                          },
                          icon: Transform.rotate(
                            angle: -0.6,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Icon(
                                Icons.send,
                                color: _isSendingMessage
                                    ? theme.disabledColor
                                    : theme.primaryColor,
                                size: 22,
                              ),
                            ),
                          ),
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
      ),
    );
  }
}

class MessageWidet extends StatefulWidget {
  final bool isReceived;
  final BaseMessage message;

  const MessageWidet(this.message, {Key? key, this.isReceived = true})
      : super(key: key);

  @override
  State<MessageWidet> createState() => _MessageWidetState();
}

class _MessageWidetState extends State<MessageWidet> {
  bool isTooltipVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          widget.isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
          mainAxisAlignment: widget.isReceived
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
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
                            color: widget.isReceived
                                ? const Color(0xFF546071)
                                : Colors.white,
                            borderRadius: _getMessageBorderRadius(),
                            border: widget.isReceived
                                ? null
                                : Border.all(color: const Color(0x40707C97)),
                          ),
                          child: Text(
                            widget.message.message,
                            style: TextStyle(
                                color: widget.isReceived ? Colors.white : gray),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _getTimeFromTimestamp(widget.message.createdAt),
                      style: const TextStyle(color: gray, fontSize: 13),
                    ),
                    Positioned(
                      right: 0,
                      child: SimpleTooltip(
                        animationDuration: const Duration(milliseconds: 1),
                        tooltipDirection: TooltipDirection.horizontal,
                        ballonPadding: EdgeInsets.zero,
                        borderWidth: 0,
                        arrowLength: 0,
                        arrowTipDistance: 0,
                        arrowBaseWidth: 0,
                        maxWidth: 100,
                        minimumOutSidePadding: 0,
                        content: Focus(
                          child: Builder(builder: (context) {
                            final focusNode = Focus.of(context);
                            focusNode.requestFocus();
                            focusNode.addListener(() {
                              if (!focusNode.hasFocus) {
                                setState(() {
                                  isTooltipVisible = false;
                                });
                              }
                            });
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      print("Detail");
                                    },
                                    child: Text(
                                      "Detail",
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                  const Divider(),
                                  GestureDetector(
                                    onTap: () {
                                      print("Delete");
                                    },
                                    child: Text(
                                      "Delete",
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                  const Divider(),
                                  GestureDetector(
                                    onTap: () {
                                      print("Update");
                                    },
                                    child: Text("Update",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        show: isTooltipVisible,
                        child: InkWell(
                          onTap: () => setState(() {
                            isTooltipVisible = true;
                          }),
                          child: Icon(
                            Icons.more_horiz,
                            color: gray.withAlpha(180),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!widget.isReceived)
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

  BorderRadius _getMessageBorderRadius() => widget.isReceived
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
