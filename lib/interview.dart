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
  token: dotenv.env['openAI_api_interview_key'] ?? '', 
  baseOption: HttpSetup(
    receiveTimeout: const Duration(seconds: 20),  
    connectTimeout: const Duration(seconds: 20),  
  ),
  enableLog: true,
);


  final ChatUser _currentUser =
      ChatUser(id: "1", firstName: "user", lastName: "user");
  final ChatUser _chatGPTUser =
      ChatUser(id: "2", firstName: "Hadafi", lastName: "" , profileImage: "https://i.imgur.com/Be1jZ9c.jpeg");
  List<ChatMessage> _messages = <ChatMessage>[];

  Timer? _ITimer;
  Duration IDuration = Duration(minutes: 2);
  bool waitForUserResponse=false;
  String? promptMsg;
  bool sentRestartQuestion=false;
  String feedback="";
  bool isLastQuestion=false;
  bool sentFeedback=false;
  bool isWaiting=true;
  bool noMoreQuestions=false;


//Initate the first message:Asking about the COOP/Internship positoon
@override
void initState(){
  SEInterview();
  _handleInitialMessage(
    'You are a COOP/internship interviewer, please askwhat is the COOP/internship position the user is applying for. introduce yourself as Hadafi interview simulator. ',
  );
  super.initState();
}


//Handle the response of the prompt.
Future<void> _handleInitialMessage(String character) async {
  setState(() {

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
  });
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor:  Color(0xFF113F67),
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
          currentUserContainerColor: Colors.cyan,
          containerColor: Color(0xFF113F67),
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
      isWaiting=false;
      });

      if(sentRestartQuestion==true){
        if(m.text.trim().toLowerCase() == "yes"){
          restartInterview();
        }
        else if(m.text.trim().toLowerCase() == "no"){
         setState(() {
      _messages.insert(0, ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "Goodbye",
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
      messages:
          _messagesHistory, // Ensure the messages are in Map<String, dynamic> format
      maxToken: 200,
    );

    final response = await _openAI.onChatCompletion(request: request);

    //Trigger the single question function.
  if (m.text.isNotEmpty) {
    print("iNSIDE await");
    await askQuestions(_messagesHistory); 
  }
    
  }

//Make the chat ask the questions one at a time:take into consideration full history.
  Future<void> askQuestions(List<Map<String, dynamic>> messagesHistory) async {
    isWaiting=true;

    if(noMoreQuestions==false){

          final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        ...messagesHistory,
        Map.of({"role": "assistant", "content": "Based on the user previous response, ask only one INTERVIEW question. Do not provide feedback only customize futher questions. Make sure to play the role of an interviewer and make flow logical. Keep in mind all users are recent graduates with limited experience"})
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
          print("iNSIDE askQuestions");
      _messages.insert(0, message);
    });

    }

  }

  //Set an interview for 15min
void SEInterview(){


   _ITimer = Timer(IDuration, () async{
    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if(isWaiting==false){
        noMoreQuestions=true;
        timer.cancel();

     List<Map<String, dynamic>> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return {"role": "user", "content": m.text};
      } else {
        return {"role": "assistant", "content": m.text};
      }
    }).toList();

    print("iNSIDE SEInterview");
     final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        ..._messagesHistory,
        Map.of({"role": "assistant", "content": "Based on the user previous responses,ask a closing QUESTON and end the interview. -Ensure it's a question-"})
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
      isLastQuestion=true;
    });

    }

    });


   });
}

void interviewFeedback() async{
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
        Map.of({"role": "assistant", "content": "Based on the user message history, provide a feedback on their interview answers"})
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
      sentFeedback=true;
    });

    restartInterviewQuestion();
   
}


  @override
  void dispose() {
    _ITimer?.cancel();  
    super.dispose();
  }

  void restartInterviewQuestion() async{
    setState(() {
      _messages.insert(0, ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "This interview is over. Would you like to have an another interview? -Respond with yes or no-",
      ));
    });

    sentRestartQuestion=true;


  }

  void restartInterview(){
          setState(() {
        _messages.insert(0, ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: "Your interview will restart....",
        ));
        sentRestartQuestion = false;
        noMoreQuestions=true;
        _messages.clear(); 
        _handleInitialMessage(
        'You are a COOP/internship interviewer, please ask what is the COOP/internship position the user is applying for. introduce yourself as Hadafi interview simulator. ');
        SEInterview();
      });
  }

}

