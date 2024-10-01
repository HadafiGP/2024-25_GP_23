// ignore_for_file: no_leading_underscores_for_local_identifiers


//flutter pixel3, pixel 3 pie all works hello

import 'dart:async';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class InterviewPage extends StatefulWidget {
  const InterviewPage({super.key});

  @override
  State<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends State<InterviewPage> {
final _openAI = OpenAI.instance.build(
  token: dotenv.env['openAI_api_interview_key'] ?? '', // this is the change that we applied to the code after encountring the push issues regarding API secrete key
  baseOption: HttpSetup(
    receiveTimeout: const Duration(seconds: 20),  // Increase this to 20 seconds or more
    connectTimeout: const Duration(seconds: 20),  // Increase this to 20 seconds or more
  ),
  enableLog: true,
);


  final ChatUser _currentUser =
      ChatUser(id: "1", firstName: "user", lastName: "user");
  final ChatUser _chatGPTUser =
      ChatUser(id: "2", firstName: "chat", lastName: "gpt");
  List<ChatMessage> _messages = <ChatMessage>[];

  bool? _isLoading;
  Timer? _ITimer;
  Duration IDuration = Duration(minutes: 15);
  bool waitForUserResponse=false;
  String? promptMsg;


//Initate the first message:Asking about the COOP/Internship positoon
@override
void initState(){
  _isLoading=false;
  startInterview();
  _handleInitialMessage(
    'You are a COOP/internship interviewer, please askwhat is the COOP/internship position the user is applying for. introduce yourself as Hadafi interview simulator. ',
  );
  super.initState();
}

//Set an interview for 15min
void startInterview(){
   _ITimer = Timer(IDuration, () {
      setState(() {
        _messages.insert(0, ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: "The interview is over. Thank you for your time!",
        ));
      });
    });
}

  @override
  void dispose() {
    _ITimer?.cancel();  
    super.dispose();
  }

//Handle the response of the prompt.
Future<void> _handleInitialMessage(String character) async {
  setState(() {
    _isLoading = true;
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
  text: response!.choices.first.message!.content.trim().replaceAll('"', '') ?? 'No content', 
);

  setState(() {
    _messages.insert(0, message);
    _isLoading = false;
  });
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: Color(0xFF1BAEC6),
        title: const Text(
          'Interview Simulator',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: DashChat(
        currentUser: _currentUser,

        messageOptions: const MessageOptions(
          currentUserContainerColor: Colors.black,
          containerColor: Colors.cyan,
          textColor: Colors.white,
        ), //
        onSend: (ChatMessage m) {
          getChatResponse(m);
        },
        messages: _messages,
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
    });
    
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
      messages:
          _messagesHistory, // Ensure the messages are in Map<String, dynamic> format
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);

    //Trigger the single question function.
        if (m.text.isNotEmpty) {
    await _askQuestions(_messagesHistory); 
  }
    
  }

//Make the chat ask the questions one at a time:take into consideration full history.
  Future<void> _askQuestions(List<Map<String, dynamic>> messagesHistory) async {


    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        ...messagesHistory,
        Map.of({"role": "assistant", "content": "Based on the user previous response, ask only one INTERVIEW question. Do not provide feedback only customize futher questions. Make sure to play the role of an interviewer and make flow logical"})
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



