// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'allHistory.dart';
import 'main.dart';
import 'StudentHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
  final _openAI = OpenAI.instance.build(
    token: dotenv.env['openAI_api_interview_key'] ?? '',
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 30),
      connectTimeout: const Duration(seconds: 30),
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

  List<ChatMessage> _messages =
      <ChatMessage>[]; //A list that store all the messages.
  final List<ChatMessage> _displayedMessages =
      []; //A list that store the messages displayed in the UI
  String? promptMsg;
  bool sentRestartQuestion =
      false; //A variable that indicates if the restart question has been shown to the user
  String feedback = "";
  bool isLastQuestion =
      false; //A variable that indicates if the last interview question has been asked.
  bool sentFeedback =
      false; //A variable that indicates if the  interview feedback has been sent to the user.
  bool isWaiting =
      true; //A variable that indicates wether the chatbot is watining for the user to respond.
  bool noMoreQuestions =
      false; //A variable that indicates whether to stop asking quesztions or not.
  String connectionErrorMessage = ''; // connection error tracking msg
  bool isTyping = false; // typing indicator
  bool showQuickReplies = false; // flag to show quick replies
  late SharedPreferences
      preferences; //SharedPreferences instance used to keep the message history saved all the time.
  String userKey = ""; // String to save the user generated keys
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController =
      TextEditingController(); //controller for sending with enter
  final FocusNode _focusNode =
      FocusNode(); // used for the input field focus effect

  ////waits for the SharedPreferences instance, and when initalized, assigning the message history to _messages using readHistoryMessages(), and when initalized, assigning the message history to _messages using readHistoryMessages()
  getSharedPrefernces() async {
    preferences = await SharedPreferences.getInstance();
    _messages = readHistoryMessages();
  }

  void handleQuickReply(String title) {
    ChatMessage quickReplyMessage = ChatMessage(
      text: title,
      user: _currentUser,
      createdAt: DateTime.now(),
    );

    setState(() {
      showQuickReplies = false; // Hide quick replies after selection
    });

    // Send reply to get chat responses
    getChatResponse(quickReplyMessage);
  }

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
    //waits for the SharedPreferences instance.
    getSharedPrefernces();
    super.initState();

    // Check connectivity first
    checkConnectivity(context);
    //A prompt that controls how the chatbot will start the interview.
    _handleInitialMessage(
      'Introduce yourself as "Hadafi application COOP/internship interviewer", and tell the user that you would conduct an interview about the COOP/internship Position he is interested in. Make the introduction short.',
    );
  }

  // Handle the response of the prompt.
  Future<void> _handleInitialMessage(String character) async {
    bool isConnected = await checkConnectivity(
        context); // check connectivity before calling api
    if (!isConnected) {
      return;
    }

    try {
      // Start typing indicator
      setState(() {
        isTyping = true;
      });
      //Send first prompt
      final request = ChatCompleteText(
        messages: [
          Map.of({"role": "assistant", "content": character})
        ],
        maxToken: 200,
        model: Gpt4ChatModel(),
      );

      final response = await _openAI.onChatCompletion(request: request);

      //Clean the response
      ChatMessage message = ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: response!.choices.first.message!.content
                .trim()
                .replaceAll('"', '') ??
            'No content',
      );

      //after recieving the response, insert it to the _messages/_displayedMessages list.
      setState(() {
        _messages.insert(0, message);
        _displayedMessages.insert(0, message);
        saveHistoryMessages(); //save messages permantely
        isTyping = false; // Stop typing indicator
      });

      // Start typing indicator
      setState(() {
        isTyping = true;
      });

      //Send the stop message
      ChatMessage stopMessage = ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text:
            'If you want to stop the interview, type "STOP" and answer the last interview question',
      );

      //insert the stop message _messages/_displayedMessages list.
      setState(() {
        _messages.insert(0, stopMessage);
        _displayedMessages.insert(0, stopMessage);
        saveHistoryMessages(); //save messages permantely
        isTyping = false; // Stop typing indicator
      });

      // Start typing indicator
      setState(() {
        isTyping = true;
      });

      //Send the COOP/Inetnship postion question
      final request2 = ChatCompleteText(
        messages: [
          Map.of({
            "role": "assistant",
            "content":
                'Ask what is the COOP/internship position the user is applying for. Limit the accepted titles (without saying) to real-world job position titles. Reask the user without notifying them if their text is gibberish, irrelevant, or not a real world job title.'
          })
        ],
        maxToken: 200,
        model: Gpt4ChatModel(),
      );

      final response2 = await _openAI.onChatCompletion(request: request2);

      //Clean the response
      ChatMessage message2 = ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: response2!.choices.first.message!.content
                .trim()
                .replaceAll('"', '') ??
            'No content',
      );

      //insert the position message _messages/_displayedMessages list.
      setState(() {
        _messages.insert(0, message2);
        _displayedMessages.insert(0, message2);
        saveHistoryMessages(); //save messages permantely
        isTyping = false; // Stop typing indicator
        showQuickReplies = true;
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
    final messageOptions = MessageOptions(
      currentUserContainerColor: Colors.cyan,
      containerColor: const Color(0xFF113F67),
      textColor: Colors.white,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        title: const Text(
          'Interview Simulator',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      drawer: HadafiDrawer(),
      body: Column(
        children: [
          // Display connectivity error banner if there's a connection issue
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
          // Main chat interface using DashChat
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messageOptions: messageOptions,
              messages: _displayedMessages,
              typingUsers: isTyping ? [_chatGPTUser] : [],
              onSend: (ChatMessage message) {
                getChatResponse(message); // Handle message sending
                _messageController.clear(); // clear input field after sending
              },
              inputOptions: InputOptions(
                textController:
                    _messageController, // controller to use for the (Enter) action
                focusNode: _focusNode, // focus

                sendOnEnter: true, // send on (Enter) key press
                textInputAction: TextInputAction.send, // Show 'send' action
                inputDecoration: InputDecoration(
                  hintText: 'Type your message...',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  filled: true,
                  fillColor: Colors.white, //input field color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF113F67),
                    ),
                  ),
        
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Color(0xFF113F67),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(
                      color: Colors.cyan,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Quick replies section (visible only if showQuickReplies is true)
          if (showQuickReplies)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    "Software Engineer Intern",
                    "Data Analyst",
                    "IT Intern",
                    "Marketing Intern",
                    "UI/UX Designer",
                    "Finance Intern",
                    "Legal Intern",
                  ].map((title) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: OutlinedButton(
                        onPressed: () => handleQuickReply(title),
                        child: Text(title),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
      // Floating Action Button to show previous interviews
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 590.0),
        child: FloatingActionButton(
          onPressed: () => _showPreviousInterviews(),
          mini: true, // Navigate to history
          child: const Icon(Icons.history),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    // Check connection
    bool isConnected = await checkConnectivity(context);
    if (!isConnected) {
      return;
    }

    // If connected, continue
    setState(() {
      _messages.insert(0, m);
      _displayedMessages.insert(0, m);
      saveHistoryMessages(); // Save messages permanently
      isWaiting = false;
      showQuickReplies = false; // Hide replies
    });

    // If user types stop then stop interview and display feedback
    if (m.text.trim().toUpperCase() == "STOP") {
      setState(() {
        isTyping = true; // Show typing indicator before STOP
      });

      noMoreQuestions = true;
      isLastQuestion = true;
      isWaiting = true;
      endInterview();
      return;
    }


    // Handle user response to the restart question
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
                  text:
                      "The interview has ended, thank you for your time and good luck in your COOP/internship search!",
                ));
            _displayedMessages.insert(
                0,
                ChatMessage(
                  user: _chatGPTUser,
                  createdAt: DateTime.now(),
                  text:
                      "The interview has ended, thank you for your time and good luck in your COOP/internship search!",
                ));
            saveHistoryMessages(); // Save messages permanently
            isTyping = false; // Stop typing indicator after Goodbye
          });
        });

        return;
      } else {
        setState(() {
          isTyping =
              true; // Show typing indicator before Please enter Yes or no
        });

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _messages.insert(
                0,
                ChatMessage(
                  user: _chatGPTUser,
                  createdAt: DateTime.now(),
                  text: "Please answer with 'Yes' or 'No' only.",
                ));
            _displayedMessages.insert(
                0,
                ChatMessage(
                  user: _chatGPTUser,
                  createdAt: DateTime.now(),
                  text: "Please answer with 'Yes' or 'No' only.",
                ));
            saveHistoryMessages(); // Save messages permanently
            isTyping =
                false; // Stop typing indicator after Please enter Yes or no
          });
        });
      }

      sentRestartQuestion = false;
      return;
    }

    // If the lastQuestion is sent call feedback function
    if (isLastQuestion) {
      setState(() {
        isLastQuestion = false;
      });

      interviewFeedback();
      return;
    }

    // If feedback is sent make the variable false to handle future interviews feedback.
    if (sentFeedback) {
      sentFeedback = false;
      return;
    }

    // Convert the ChatMessage objects into the required Map<String, dynamic> format
    List<Map<String, dynamic>> _messagesHistory =
        _displayedMessages.reversed.map((m) {
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
      // catches 429 exception: too many requests
      if (e.toString().contains("429")) {
        // tries resending the request after two seconds
        await Future.delayed(Duration(seconds: 2));

        try {
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
      } else {
        setState(() {
          connectionErrorMessage =
              'Failed to retrieve the response. Please check your connection and try again.';
          isTyping = false; // Stop typing indicator on error
        });
      }
    }

    // Trigger the single question function.
    if (m.text.isNotEmpty) {
      await askQuestions(_messagesHistory);
    }
  }

  // Make the chatbot ask the questions one at a time
  Future<void> askQuestions(List<Map<String, dynamic>> messagesHistory) async {
    isWaiting = true;

    if (!noMoreQuestions) {
      final request = ChatCompleteText(
        model: Gpt4ChatModel(),
        messages: [
          ...messagesHistory,
          Map.of({
            "role": "assistant",
            "content":
                "Act as a professional interviewer while keeping in mind that users are recent graduates with little work experience. Utilize the user's message history to ask ONE random and unique interview question from a diverse pool of topics, including technical skills, soft skills, problem-solving, teamwork, and career aspirations, Use your internal randomness to generate unique questions every time. Reask the user if their text appears gibberish, irrelevant, or unresponsive. Avoid repeating questions."
          })
        ],
        temperature: 1.0,
        topP: 0.95,
        presencePenalty: 0.8,
        frequencyPenalty: 0.5,
      );

      final response = await _openAI.onChatCompletion(request: request);

      ChatMessage message = ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: response!.choices.first.message!.content.trim(),
      );

      setState(() {
        _messages.insert(0, message);
        _displayedMessages.insert(0, message);
        saveHistoryMessages(); //save messages permantely
      });
    }
  }

  // Set an interview timer of 10 minutes and send the last question of the interview after the timer ends.
  void endInterview() async {

    List<Map<String, dynamic>> messagesHistory =
        _displayedMessages.reversed.map((m) {
      if (m.user == _currentUser) {
        return {"role": "user", "content": m.text};
      } else {
        return {"role": "assistant", "content": m.text};
      }
    }).toList();

    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        ...messagesHistory,
        Map.of({
          "role": "assistant",
          "content":
              "Using the user’s previous responses, ask one closing QUESTION (clarify it's the last question). If there are insufficient responses to formulate a closing question (The user only provided their position or stopped without answering any questions), explicitly state: 'There is not enough interview history to ask a closing question. Please ensure to answer at leat one question in the interview. Resond with an \"OK\" if you understand' Ensure the output is either a clear closing question or this message about insufficient responses."
        })
      ],
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);

    ChatMessage lastQuestion = ChatMessage(
      user: _chatGPTUser,
      createdAt: DateTime.now(),
      text: response!.choices.first.message!.content.trim(),
    );

    setState(() {
      _messages.insert(0, lastQuestion);
      _displayedMessages.insert(0, lastQuestion);
      saveHistoryMessages();
      isLastQuestion = true;
      isTyping = false;
    });
  }

  //sends a feedback on all the interview questions after the interview ends or when the user types "stop". Calls restartInterviewQuestion() after sneding the feedback
  void interviewFeedback() async {
    setState(() {
      isTyping = true;
    });

    List<Map<String, dynamic>> _messagesHistory =
        _displayedMessages.reversed.where((m) {
      if (m.user == _currentUser && m.text.trim().toUpperCase() == "STOP") {
        return false;
      }
      return true;
    }).map((m) {
      if (m.user == _currentUser) {
        return {"role": "user", "content": m.text};
      } else {
        return {"role": "assistant", "content": m.text};
      }
    }).toList();

    bool hasHistory = _messagesHistory.any((msg) => msg["role"] == "user");
    int messageCount =
        _messagesHistory.where((msg) => msg["role"] == "user").length;

    if (!hasHistory || messageCount == 1) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            user: _chatGPTUser,
            createdAt: DateTime.now(),
            text: "There are no interview answers to give feedback on.",
          ),
        );
        _displayedMessages.insert(
          0,
          ChatMessage(
            user: _chatGPTUser,
            createdAt: DateTime.now(),
            text: "There are no interview answers to give feedback on.",
          ),
        );
        saveHistoryMessages();
        isTyping = false;
      });
    } else {
      setState(() {
        isTyping = true;
      });

      final feedbackRequest = ChatCompleteText(
        model: Gpt4ChatModel(),
        messages: [
          ..._messagesHistory,
          Map.of({
            "role": "assistant",
            "content":
                "Act as a professional HR recruiter and analyze the user's entire interview answers in detail. Provide constructive feedback on their strengths (if any) and areas for improvement, ensuring your assessment is realistic and straightforward. Avoid overgeneralizations or unwarranted praise—do not state the answers are 'good' overall unless they genuinely meet high standards. If there are no strengths, explicitly state this and explain why. Highlight specific weaknesses and unanswered questions, except for the one where the user stopped the interview. Offer real and sometimes harsh feedback if necessary, without sugar-coating or being vague. If there are insufficient responses to provide feedback (The user only provided their position or stopped without answering any questions), explicitly state: 'There is not enough interview history to provide' Ensure the output is either a constructive feedback or this message about insufficient responses."
          })
        ],
        maxToken: 1000,
      );

      final feedbackResponse =
          await _openAI.onChatCompletion(request: feedbackRequest);

      ChatMessage feedbackMessage = ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: feedbackResponse!.choices.first.message!.content.trim(),
      );

      setState(() {
        _messages.insert(0, feedbackMessage);
        _displayedMessages.insert(0, feedbackMessage);
        saveHistoryMessages();
      });

      setState(() {
        isTyping = true;
      });

      final resourceRequest = ChatCompleteText(
        model: Gpt4ChatModel(),
        messages: [
          ..._messagesHistory,
          Map.of({
            "role": "assistant",
            "content":
                "Analyze the user's interview responses and feedback to identify weaknesses. For each weakness, provide 2-3 improvement resources, including: Books: Title, short description, and relevance to position and weakness. Online Courses/Websites: Name, link, and relevance to position and weakness. YouTube Videos/Channels: Specific links and relevance to position and weakness. Organize resources by weakness and ensure recommendations are specific and clear. Avoid generic responses like 'we will review your application.' If there are insufficient responses to recommend resources (The user only provided their position or stopped without answering any questions), explicitly state: 'There is not enough interview history to recommend resources.' Ensure the output is either weaknesses and relevant recommendations or this message about insufficient responses."
          })
        ],
        maxToken: 1000,
      );

      final resourceResponse =
          await _openAI.onChatCompletion(request: resourceRequest);

      ChatMessage resourceMessage = ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: resourceResponse!.choices.first.message!.content.trim(),
      );

      setState(() {
        _messages.insert(0, resourceMessage);
        _displayedMessages.insert(0, resourceMessage);
        saveHistoryMessages();
        isTyping = false;
      });
    }

    restartInterviewQuestion();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  //Sends the restart question.
  void restartInterviewQuestion() async {
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
      _displayedMessages.insert(
          0,
          ChatMessage(
            user: _chatGPTUser,
            createdAt: DateTime.now(),
            text:
                "This interview is over. Would you like to have another interview? -Respond with yes or no-",
          ));
      saveHistoryMessages(); //save messages permantely

      isTyping = false; // Stop typing indicator after the message is inserted
    });

    sentRestartQuestion = true;
  }

  //Handles the restart logic by cleaning the UI, resetting the variables, and calling _handleInitialMessage(character)
  void restartInterview() {
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
        _displayedMessages.insert(
            0,
            ChatMessage(
              user: _chatGPTUser,
              createdAt: DateTime.now(),
              text: "Your new interview will start now.",
            ));
        saveHistoryMessages(); //save messages permantely

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
        _displayedMessages.clear();
        _handleInitialMessage(
          'Introduce yourself as "Hadafi application COOP/internship interviewer", and tell the user that you would conduct an interview about the COOP/internship Position he is interested in. Make the introduction short.',
        );
      });
    });
  }

// Call a function that displays the past message history interface when the icon is tapped.
  void _showPreviousInterviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PastInterviewsScreen(messages: _messages),
      ),
    );
  }

  String generateKey() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return 'userHistory:${user.uid}'; // Unique key per user
    }
    return 'cuserHistoryDefault:'; // Fallback if user is not logged in
  }

// Function that saves all the message history during page navigation
  Future<void> saveHistoryMessages() async {
    String userKey = generateKey();

    List<String> userMessages = _messages
        .map((ChatMessage chatMessage) => jsonEncode(chatMessage.toJson()))
        .toList();

    await preferences.setStringList(userKey, userMessages);
  }

// Function that transforms the message history from string => chatMessages
  List<ChatMessage> readHistoryMessages() {
    String userKey = generateKey();

    List<String>? userMessages = preferences.getStringList(userKey);

    if (userMessages != null && userMessages.isNotEmpty) {
      return userMessages
          .map((String messageString) =>
              ChatMessage.fromJson(json.decode(messageString)))
          .toList();
    }
    return [];
  }
}

// An interface that displays all the messagees history of all past interviews.
class PastInterviewsScreen extends StatelessWidget {
  final List<ChatMessage> _messages;
  final ChatUser _currentUser =
      ChatUser(id: "1", firstName: "user", lastName: "user");
  final ChatUser _chatGPTUser = ChatUser(
      id: "2",
      firstName: "Hadafi",
      lastName: "",
      profileImage: "https://i.imgur.com/Be1jZ9c.jpeg");

  PastInterviewsScreen({super.key, required List<ChatMessage> messages})
      : _messages = messages;

  @override
  Widget build(BuildContext context) {
    const messageOptions = MessageOptions(
      currentUserContainerColor: Colors.cyan,
      containerColor: Color(0xFF113F67),
      textColor: Colors.white,
    );
    if (_messages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No History'),
              content: Text('There\'s no Interview history to display!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }
    return Scaffold(
      backgroundColor: Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFF113F67),
        title: const Text(
          'Interview History',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: DashChat(
        currentUser: _currentUser,
        messages: _messages,
        readOnly: true,
        inputOptions: InputOptions(
          inputDisabled: true,
        ),
        onSend: (ChatMessage message) {},
        messageOptions: messageOptions,
      ),
    );
  }
}
