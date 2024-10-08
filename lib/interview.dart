// ignore_for_file: no_leading_underscores_for_local_identifiers

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
      receiveTimeout: const Duration(seconds: 15),
      connectTimeout: const Duration(seconds: 15),
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
  bool isTyping = false; // typing indicator 

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
      // Start typing indicator
      setState(() {
        isTyping = true;
      });

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
        isTyping = false; // Stop typing indicator after receiving response
      });

      ChatMessage stopMessage = ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: 'If you want to stop the interview, just type "STOP".',
      );

      setState(() {
        _messages.insert(0, stopMessage);
        isTyping = false; // Stop typing indicator 
      });

    } catch (e) {
      setState(() {
        connectionErrorMessage =
            'Failed to connect. Please check your internet connection and try again.';
        isTyping = false; // Stop typing indicator on error
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
              messages: _messages,
              typingUsers: isTyping ? [_chatGPTUser] : [], // Display typing indicator
              onSend: (ChatMessage m) {
                getChatResponse(m);
              },
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

    // if connected, continue
    setState(() {
      _messages.insert(0, m);
      isWaiting = false;
    });

    if (m.text.trim().toUpperCase() == "STOP") {
      setState(() {
        isTyping = true; // Show typing indicator before STOP
      });

      noMoreQuestions = true;
      isLastQuestion = false;
      isWaiting = true;
      _ITimer?.cancel();
      interviewFeedback();

      setState(() {
        isTyping = false; // Stop typing indicator after STOP
      });

      return;
    }

    if (sentRestartQuestion == true) {
      if (m.text.trim().toLowerCase() == "yes") {
        restartInterview();
      } else if (m.text.trim().toLowerCase() == "no") {
        setState(() {
          isTyping = true; // Show typing indicator before Goodbye
        });

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _messages.insert(
                0,
                ChatMessage(
                  user: _chatGPTUser,
                  createdAt: DateTime.now(),
                  text: "Goodbye!",
                ));
            isTyping = false; // Stop typing indicator after Goodbye
          });
        });

        return;
      } else {
        setState(() {
          isTyping = true; // Show typing indicator before Please enter Yes or no
        });

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _messages.insert(
                0,
                ChatMessage(
                  user: _chatGPTUser,
                  createdAt: DateTime.now(),
                  text: "Please enter Yes or no only.",
                ));
            isTyping = false; // Stop typing indicator after Please enter Yes or no
          });
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
      // Start typing indicator before response
      setState(() {
        isTyping = true;
      });

      final response = await _openAI.onChatCompletion(request: request);

      setState(() {
        isTyping = false; // Stop typing indicator after response
      });

    } catch (e) {
      setState(() {
        connectionErrorMessage =
            'Failed to retrieve the response. Please check your connection and try again.';
        isTyping = false; // Stop typing indicator on error
      });
    }

    // Trigger the single question function.
    if (m.text.isNotEmpty) {
      await askQuestions(_messagesHistory);
    }
  }

  // Make the chat ask the questions one at a time
  Future<void> askQuestions(List<Map<String, dynamic>> messagesHistory) async {
    print("inside askQuestions");
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
    print("Inside SEInterview");
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
    print("Inside interviewFeedback");

    // Set typing indicator before feedback
    setState(() {
      isTyping = true;
    });

    List<Map<String, dynamic>> _messagesHistory = _messages.reversed.where((m) {
    if (m.user == _currentUser && m.text.trim().toUpperCase() == "STOP") {
      return false; 
    }
    return true;
  }).map((m) {
    if (m.user == _currentUser) {
      return {"role": "user", "content": m.text};
    } else {
      return {"role": "assistant", "content": m.text};
    }}).toList();


    bool hasHistory = _messagesHistory.any((msg) => msg["role"] == "user");
    int messageCount = _messagesHistory.where((msg) => msg["role"] == "user").length;
    if (!hasHistory || messageCount==1) {
    setState(() {
      print("inside no history");

      // Show typing indicator before "There are no interview answers"
      isTyping = true;

      _messages.insert(
        0,
        ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: "There are no interview answers to give feedback on.",
        ),
      );
      isTyping = false; // Stop typing indicator after "There are no interview answers"
    });
  }else{
          print("inside history");
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
      isTyping = false; // Stop typing indicator after feedback
      print("outside interview");
    });

  }

    restartInterviewQuestion();
  }

  @override
  void dispose() {
    _ITimer?.cancel();
    super.dispose();
  }

  void restartInterviewQuestion() async {
        print("Inside restartInterviewQuestion");

    // Show typing indicator before "Would you like to have another interview?"
    setState(() {
      isTyping = true;
    });

    setState(() {
      _messages.insert(
          0,
          ChatMessage(
            user: _chatGPTUser,
            createdAt: DateTime.now(),
            text:
                "This interview is over. Would you like to have another interview? -Respond with yes or no-",
          ));

      isTyping = false; // Stop typing indicator after the message is inserted
    });

    sentRestartQuestion = true;
  }

  void restartInterview() {
    _ITimer?.cancel(); 
    print("Inside restart");

    // Show typing indicator before "Your new interview will start now."
    setState(() {
      isTyping = true;
    });

    // Delay the insertion of the message to allow the typing indicator to be visible
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              user: _chatGPTUser,
              createdAt: DateTime.now(),
              text: "Your new interview will start now.",
            ));

        isTyping = false; // Stop typing indicator after the message is inserted
      });

      // Delay before starting the next interview
      Future.delayed(Duration(seconds: 2), () {
        sentRestartQuestion = false;
        noMoreQuestions = false;
        sentRestartQuestion = false;
        isLastQuestion = false; 
        sentFeedback = false; 
        sentFeedback = false;
        isWaiting = true;
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
