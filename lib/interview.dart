// ignore_for_file: no_leading_underscores_for_local_identifiers

//flutter pixel3, pixel 3 pie all works 

import 'dart:async';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
  final _openAI = OpenAI.instance.build(
    token: dotenv.env['openAI_api_interview_key'] ?? '',
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 10),
      connectTimeout: const Duration(seconds: 10),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
      ChatUser(id: "1", firstName: "user", lastName: "user");
  final ChatUser _chatGPTUser = ChatUser(
      id: "2",
      firstName: "Hadafi",
      lastName: "",
      profileImage: "https://i.imgur.com/Be1jZ9c.jpeg");

  List<ChatMessage> _messages = <ChatMessage>[];
  Timer? _ITimer;
  Duration IDuration = Duration(minutes: 1);
  bool waitForUserResponse = false;
  String? promptMsg;
  bool sentRestartQuestion = false;
  String feedback = "";
  bool isLastQuestion = false;
  bool sentFeedback = false;
  bool isWaiting = true;
  bool noMoreQuestions = false;
  String connectionErrorMessage = ''; // connection error tracking msg

  Future<bool> checkConnectivity(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        connectionErrorMessage =
            'No internet connection. Please check your network and try again.';
      });
      return false; // no internet connection
    }
    setState(() {
      connectionErrorMessage = ''; // clear msg when connected
    });
    return true; // Connected
  }

  // Initiate the first message: Asking about the COOP/Internship position
  @override
  void initState() {
    super.initState();

    // Check connectivity first
    checkConnectivity(context);

    SEInterview();
    _handleInitialMessage(
      'Introduce yourself as "Hadafi COOP/internship interviewer", and please ask what is the COOP/internship position the user is applying for.' +
          ' Reask the user without notifying them if his text appears like gibberish, not relevant to the question, or doesn\'t sound like a real postion title',
    );
  }

  // Handle the response of the prompt.
  Future<void> _handleInitialMessage(String character) async {
    bool isConnected =
        await checkConnectivity(context); // check connectivity before calling api
    if (!isConnected) {
      return;
    }

    try {
      final request = ChatCompleteText(
        messages: [
          Map.of({"role": "assistant", "content": character})
        ],
        maxToken: 200,
        model: Gpt4ChatModel(),
      );

      final response = await _openAI.onChatCompletion(request: request);

      ChatMessage message = ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: response!.choices.first.message!.content
                .trim()
                .replaceAll('"', '') ??
            'No content',
      );

      setState(() {
        _messages.insert(0, message);
      });
    } catch (e) {
      setState(() {
        connectionErrorMessage =
            'Failed to connect. Please check your internet connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const messageOptions = const MessageOptions(
      currentUserContainerColor: Colors.cyan,
      containerColor: Color(0xFF113F67),
      textColor: Colors.white,
    );
    return Scaffold(
      backgroundColor: Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        title: const Text(
          'Interview Simulator',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Red banner for connectivity msg
          if (connectionErrorMessage.isNotEmpty)
            Container(
              color: Colors.red,
              padding: const EdgeInsets.all(12.0),
              width: double.infinity,
              child: Text(
                connectionErrorMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messageOptions: messageOptions,
              onSend: (ChatMessage m) {
                getChatResponse(m);
              },
              messages: _messages,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    // check connection
    bool isConnected = await checkConnectivity(context);
    if (!isConnected) {
      return;
    }

    // if connected ,continue
    setState(() {
      _messages.insert(0, m);
      isWaiting = false;
    });

    if (sentRestartQuestion == true) {
      if (m.text.trim().toLowerCase() == "yes") {
        restartInterview();
      } else if (m.text.trim().toLowerCase() == "no") {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                user: _chatGPTUser,
                createdAt: DateTime.now(),
                text: "Goodbye",
              ));
        });
        return;
      } else {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                user: _chatGPTUser,
                createdAt: DateTime.now(),
                text: "Please enter Yes or no only.",
              ));
        });
        return;
      }

      sentRestartQuestion = false;
      return;
    }

    if (isLastQuestion) {
      isLastQuestion = false;
      interviewFeedback();
      return;
    }

    if (sentFeedback) {
      sentFeedback = false;
      return;
    }

    // Convert the ChatMessage objects into the required Map<String, dynamic> format
    List<Map<String, dynamic>> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return {"role": "user", "content": m.text};
      } else {
        return {"role": "assistant", "content": m.text};
      }
    }).toList();

    // Make the request with properly formatted messages
    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: _messagesHistory,
      maxToken: 200,
    );

    try {
      final response = await _openAI.onChatCompletion(request: request);


    } catch (e) {
      setState(() {
        connectionErrorMessage =
            'Failed to retrieve the response. Please check your connection and try again.';
      });
    }

    // Trigger the single question function.
    if (m.text.isNotEmpty) {
      await askQuestions(_messagesHistory);
    }
  }

  // Make the chat ask the questions one at a time
  Future<void> askQuestions(List<Map<String, dynamic>> messagesHistory) async {
    isWaiting = true;

    if (!noMoreQuestions) {
      final request = ChatCompleteText(
        model: Gpt4ChatModel(),
        messages: [
          ...messagesHistory,
          Map.of({
            "role": "assistant",
            "content": "Utilize the user's message history to ask ONE interview question. Reask the user if their text appears gibberish or irrelevant. Play the role of an interviewer, keeping in mind that users are recent graduates with little work experience."
          })
        ],
        maxToken: 200,
      );

      final response = await _openAI.onChatCompletion(request: request);

      ChatMessage message = ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: response!.choices.first.message!.content.trim(),
      );

      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  // Set an interview for 15 minutes
  void SEInterview() {
    _ITimer = Timer(IDuration, () async {
      Timer.periodic(Duration(milliseconds: 100), (timer) async {
        if (isWaiting == false) {
          noMoreQuestions = true;
          timer.cancel();

          List<Map<String, dynamic>> _messagesHistory =
              _messages.reversed.map((m) {
            if (m.user == _currentUser) {
              return {"role": "user", "content": m.text};
            } else {
              return {"role": "assistant", "content": m.text};
            }
          }).toList();

          final request = ChatCompleteText(
            model: Gpt4ChatModel(),
            messages: [
              ..._messagesHistory,
              Map.of({
                "role": "assistant",
                "content":
                    "Using the user’s previous responses, ask a closing QUESTION. Ensure to write only a question, and clarify it's the last question."
              })
            ],
            maxToken: 200,
          );

          final response = await _openAI.onChatCompletion(request: request);

          ChatMessage message = ChatMessage(
            user: _chatGPTUser,
            createdAt: DateTime.now(),
            text: response!.choices.first.message!.content.trim(),
          );

          setState(() {
            _messages.insert(0, message);
            isLastQuestion = true;
          });
        }
      });
    });
  }

  void interviewFeedback() async {
    List<Map<String, dynamic>> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return {"role": "user", "content": m.text};
      } else {
        return {"role": "assistant", "content": m.text};
      }
    }).toList();

    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        ..._messagesHistory,
        Map.of({
          "role": "assistant",
          "content":
              "Use the user’s complete message history to provide a comprehensive feedback on the user's entire interview answers."
        })
      ],
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);

    ChatMessage message = ChatMessage(
      user: _chatGPTUser,
      createdAt: DateTime.now(),
      text: response!.choices.first.message!.content.trim(),
    );

    setState(() {
      _messages.insert(0, message);
      sentFeedback = true;
    });

    restartInterviewQuestion();
  }

  @override
  void dispose() {
    _ITimer?.cancel();
    super.dispose();
  }

  void restartInterviewQuestion() async {
    setState(() {
      _messages.insert(
          0,
          ChatMessage(
            user: _chatGPTUser,
            createdAt: DateTime.now(),
            text:
                "This interview is over. Would you like to have another interview? -Respond with yes or no-",
          ));
    });

    sentRestartQuestion = true;
  }

  void restartInterview() {
    setState(() {
      _messages.insert(
          0,
          ChatMessage(
            user: _chatGPTUser,
            createdAt: DateTime.now(),
            text: "Your new interview will start now.",
          ));
      Future.delayed(Duration(seconds: 2), () {
        sentRestartQuestion = false;
        noMoreQuestions = true;
        _messages.clear();
        _handleInitialMessage(
          'Introduce yourself as "Hadafi COOP/internship interviewer", and please ask what is the COOP/internship position the user is applying for.' +
              ' Reask the user without notifying them if his text appears like gibberish, not relevant to the question, or doesn\'t sound like a real postion title',
        );
        SEInterview();
      });
    });
  }
}
