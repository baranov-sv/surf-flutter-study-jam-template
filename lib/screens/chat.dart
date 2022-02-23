import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:surf_practice_chat_flutter/enums.dart';
import 'package:surf_practice_chat_flutter/constants.dart';
import 'package:surf_practice_chat_flutter/data/chat/application_state.dart';
import 'package:surf_practice_chat_flutter/data/chat/models/message.dart';
import 'package:surf_practice_chat_flutter/data/chat/models/geolocation.dart';
import 'package:surf_practice_chat_flutter/data/chat/models/user.dart';
import 'package:surf_practice_chat_flutter/services/location.dart';

/// Chat screen templete. This is your starting point.
class ChatScreen extends StatelessWidget {
  const ChatScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ApplicationState>(
            builder: (context, appState, _) => NicknameForm(
                nickname: appState.nickname,
                nicknameState: appState.nicknameState,
                startNicknameFlow: appState.startNicknameFlow,
                setNickname: appState.setNickname)),
        actions: [
          Consumer<ApplicationState>(
              builder: (context, appState, _) => LoadingButton(
                    loadingMessagesState: appState.loadingMessagesState,
                    callback: appState.loadMessages,
                  ))
        ],
      ),
      body: Column(children: [
        Expanded(
            child: Consumer<ApplicationState>(
                builder: (context, appState, _) => ListMessages(
                    nicknameState: appState.nicknameState,
                    loadingMessagesState: appState.loadingMessagesState,
                    messages: appState.messages))),
        Container(
            height: 3, color: ColorConstants.dividerColor.withOpacity(0.1)),
        Consumer<ApplicationState>(
            builder: (context, appState, _) => MessageForm(
                loadingMessagesState: appState.loadingMessagesState,
                nicknameState: appState.nicknameState,
                callback: appState.sendMessage))
      ]),
    );
  }
}

class LoadingButton extends StatelessWidget {
  final ApplicationLoadingMessagesState loadingMessagesState;
  final Future<void> Function() callback;

  const LoadingButton(
      {Key? key, required this.loadingMessagesState, required this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed:
            loadingMessagesState == ApplicationLoadingMessagesState.loading
                ? null
                : callback,
        icon: const Icon(Icons.refresh));
  }
}

class ListMessages extends StatelessWidget {
  final ApplicationNicknameState nicknameState;
  final ApplicationLoadingMessagesState loadingMessagesState;
  final List<ChatMessageDto> messages;

  const ListMessages(
      {Key? key,
      required this.nicknameState,
      required this.loadingMessagesState,
      required this.messages})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (loadingMessagesState) {
      case ApplicationLoadingMessagesState.loading:
        return const Center(child: CircularProgressIndicator());
      case ApplicationLoadingMessagesState.failed:
        return const Center(
            child: Text('Loading error',
                style: TextStyle(fontWeight: FontWeight.bold)));
      default:
        return Scrollbar(
          child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final message = messages[i];
                return Container(
                    padding: const EdgeInsets.all(8.0),
                    color: message.author is ChatUserLocalDto
                        ? ColorConstants.primaryColor.withOpacity(0.2)
                        : null,
                    child: message is ChatMessageGeolocationDto
                        ? _MessageGeolocation(message: message)
                        : _Message(
                            message: message,
                          ));
              }),
        );
    }
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50.0,
        height: 50.0,
        child: Text(_extractLabel(name),
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ColorConstants.avatarTextColor)),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
            color: ColorConstants.primaryColor, shape: BoxShape.circle));
  }

  String _extractLabel(String name) {
    return name.substring(0, 1).toUpperCase();
  }
}

class _Message extends StatelessWidget {
  final ChatMessageDto message;
  const _Message({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(
          name: message.author.name,
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message.author.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(message.message)
            ],
          ),
        ))
      ],
    );
  }
}

class _MessageGeolocation extends StatelessWidget {
  final ChatMessageGeolocationDto message;
  const _MessageGeolocation({Key? key, required this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Avatar(
          name: message.author.name,
        ),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(message.author.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  const Text('shared geo location',
                      style: TextStyle(color: Colors.grey))
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () => _openMap(message.location),
                child: const Text('Open on the map',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.primaryColor)),
              ),
              if (message.message.isNotEmpty) Text(message.message)
            ],
          ),
        ))
      ],
    );
  }

  void _openMap(ChatGeolocationDto location) {
    launch(
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}');
  }
}

class MessageForm extends StatefulWidget {
  final ApplicationLoadingMessagesState loadingMessagesState;
  final ApplicationNicknameState nicknameState;
  final Future<void> Function(String message, Position? position) callback;

  const MessageForm(
      {Key? key,
      required this.nicknameState,
      required this.loadingMessagesState,
      required this.callback})
      : super(key: key);

  @override
  _MessageFormState createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final _controller = TextEditingController();
  var _sending = false;
  Position? _position;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
              onPressed: () async {
                final position = await _positionDialog(context);
                setState(() {
                  _position = position;
                });
              },
              icon: Icon(
                Icons.share_location_outlined,
                color: _position != null ? ColorConstants.primaryColor : null,
              )),
          const SizedBox(
            width: 5.0,
          ),
          Expanded(
              child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Enter message',
                  ))),
          widget.nicknameState == ApplicationNicknameState.known
              ? _sendButton()
              : _fakeSendButton()
        ],
      ),
    );
  }

  Future<Position?> _positionDialog(BuildContext context) async {
    return await showDialog<Position>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text(
              'Share geo location?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text(
                  'No',
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final position = await getCurrentPosition();
                    Navigator.pop(context, position);
                  } catch (err) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(err.toString())));
                  }
                },
                child: const Text(
                  'Yes',
                ),
              )
            ],
          );
        });
  }

  Future<void> _sendMessage() async {
    setState(() {
      _sending = true;
    });
    try {
      await widget.callback(_controller.text, _position);
      _position = null;
      _controller.clear();
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err.toString()),
      ));
    }

    setState(() {
      _sending = false;
    });
  }

  Widget _sendButton() {
    return IconButton(
        onPressed: _sending ||
                widget.loadingMessagesState ==
                    ApplicationLoadingMessagesState.loading
            ? null
            : _sendMessage,
        icon: _sending
            ? const CircularProgressIndicator()
            : const Icon(Icons.send));
  }

  Widget _fakeSendButton() {
    return IconButton(
        icon: const Icon(Icons.send),
        onPressed: () =>
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Enter your nickname'),
            )));
  }
}

class NicknameForm extends StatelessWidget {
  final ApplicationNicknameState nicknameState;
  final String? nickname;
  final void Function() startNicknameFlow;
  final void Function(
    String nickname,
  ) setNickname;

  const NicknameForm(
      {Key? key,
      required this.nickname,
      required this.nicknameState,
      required this.startNicknameFlow,
      required this.setNickname})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return nicknameState == ApplicationNicknameState.known
        ? _NicknameLabel(
            nickname: nickname!,
            onTapCallback: startNicknameFlow,
          )
        : _NicknameForm(
            nickname: nickname,
            callback: setNickname,
          );
  }
}

class _NicknameLabel extends StatelessWidget {
  final String nickname;
  final void Function() onTapCallback;

  const _NicknameLabel({
    Key? key,
    required this.onTapCallback,
    required this.nickname,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: () => onTapCallback(), child: Text(nickname));
  }
}

class _NicknameForm extends StatefulWidget {
  final String? nickname;
  final void Function(String nickname) callback;

  const _NicknameForm(
      {Key? key, required this.nickname, required this.callback})
      : super(key: key);

  @override
  _NicknameFormState createState() => _NicknameFormState();
}

class _NicknameFormState extends State<_NicknameForm> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        widget.callback(_controller.text);
      }
    });
    final text = widget.nickname;
    if (text != null) {
      _controller.text = text;
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: const InputDecoration(
        hintText: 'Enter your nickname',
      ),
    );
  }
}
