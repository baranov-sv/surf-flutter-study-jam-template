import 'package:flutter/material.dart';
import 'package:surf_practice_chat_flutter/enums.dart';
import 'package:surf_practice_chat_flutter/data/chat/repository/repository.dart';
import 'package:surf_practice_chat_flutter/data/chat/models/message.dart';

class ApplicationState extends ChangeNotifier {
  final ChatRepository chatRepository;

  ApplicationNicknameState _nicknameState = ApplicationNicknameState.unknown;
  ApplicationNicknameState get nicknameState => _nicknameState;

  String? _nickname;
  String? get nickname => _nickname;

  ApplicationLoadingMessagesState _loadingMessagesState =
      ApplicationLoadingMessagesState.loading;
  ApplicationLoadingMessagesState get loadingMessagesState =>
      _loadingMessagesState;

  List<ChatMessageDto> _messages = [];
  List<ChatMessageDto> get messages => _messages;

  ApplicationState(this.chatRepository) {
    init();
  }

  Future<void> init() async {
    await loadMessages();
  }

  Future<void> loadMessages() async {
    _loadingMessagesState = ApplicationLoadingMessagesState.loading;
    notifyListeners();

    try {
      _messages = await chatRepository.messages;
      _loadingMessagesState = ApplicationLoadingMessagesState.successfull;
    } catch (_) {
      _loadingMessagesState = ApplicationLoadingMessagesState.failed;
      _messages = [];
    }

    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (_nicknameState == ApplicationNicknameState.known) {
      _messages = await chatRepository.sendMessage(_nickname!, message);

      notifyListeners();
    }
  }

  void startNicknameFlow() {
    _nicknameState = ApplicationNicknameState.fillIn;
    notifyListeners();
  }

  void setNickname(String nickname) {
    if (nickname.isEmpty) {
      _nicknameState = ApplicationNicknameState.unknown;
      _nickname = null;
    } else {
      _nicknameState = ApplicationNicknameState.known;
      _nickname = nickname;
    }
    notifyListeners();
    loadMessages();
  }
}
