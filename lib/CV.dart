import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'StudentHomePage.dart';
import 'CV.dart';
import 'interview.dart';
import 'welcome.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


// import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
// import 'package:dash_chat_2/dash_chat_2.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:file_picker/file_picker.dart';
// import 'dart:io';
// import 'package:syncfusion_flutter_pdf/pdf.dart';

class CVPage extends StatefulWidget {
  const CVPage({super.key});

  @override
  State<CVPage> createState() => _CVPageState();
}

class _CVPageState extends State<CVPage> {
  final _openAI = OpenAI.instance.build(
    token: dotenv.env['openAI_api_cv_key'] ?? '',
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 20),
      connectTimeout: const Duration(seconds: 20),
    ),
    enableLog: true,
  );

  final ChatUser _currentUser =
      ChatUser(id: "1", firstName: "User", lastName: "User");
  final ChatUser _chatGPTUser = ChatUser(
    id: "2",
    firstName: "Hadafi",
    profileImage: "https://i.imgur.com/Be1jZ9c.jpeg",
  );

  List<ChatMessage> _messages = <ChatMessage>[];
  bool _positionRequested = false;
  bool _cvRequested = false;
  bool _isLoading = false; // Track loading state
  String? _enteredPosition;

  @override
  void initState() {
    super.initState();
    _sendWelcomeMessage();
  }

  void _sendWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: "Welcome to Hadafi CV Enhancement! Please select or enter the position you're applying for.",
          quickReplies: [
            QuickReply(title: "IT intern", value: "IT intern"),
            QuickReply(title: "Software Engineer", value: "Software Engineer"),
            QuickReply(title: "Data Analyst", value: "Data Analyst"),
            QuickReply(title: "Marketing", value: "Marketing"),
            QuickReply(title: "IS", value: "IS"),
            QuickReply(title: "Legal intern", value: "Legal intern"),
          ],
        ),
      );
    });
    _positionRequested = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        title: const Text(
          'CV Enhancement',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      drawer: HadafiDrawer(),
      body: Stack(
        children: [
          DashChat(
            currentUser: _currentUser,
            messageOptions: MessageOptions(
              currentUserContainerColor: Colors.cyan,
              containerColor: const Color(0xFF113F67),
              textColor: Colors.white,
            ),
            inputOptions: _cvRequested
                ? InputOptions(
                    inputDecoration: InputDecoration(
                      hintText: "Upload your CV using the attach button",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _pickMedia,
                      ),
                    ],
                    sendButtonBuilder: (_) => const SizedBox.shrink(),
                  )
                : InputOptions(
                    inputDecoration: InputDecoration(
                      hintText: "Enter the position you're applying for...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        
                      ),
                    ),
                    sendOnEnter: true,
                  ),
            quickReplyOptions: QuickReplyOptions(
              onTapQuickReply: (QuickReply reply) {
                _handleQuickReply(reply.value!);
              },
            ),
            onSend: (ChatMessage message) => _handleSend(message),
            messages: _messages.reversed.toList(),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "We are uploading your CV! Please wait...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleQuickReply(String reply) {
    setState(() {
      _messages.add(
        ChatMessage(
          user: _currentUser,
          createdAt: DateTime.now(),
          text: reply,
        ),
      );
    });

    if (_positionRequested && !_cvRequested) {
      _handlePositionInput(reply);
    }
  }

  void _handleSend(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });

    if (_positionRequested && !_cvRequested) {
      _handlePositionInput(message.text);
    }
  }

  void _handlePositionInput(String position) {
    _enteredPosition = position;
    setState(() {
      _messages.add(
        ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text:
              "Thank you! You entered: $position\nNow, please upload your CV in PDF or DOCX format.",
        ),
      );
    });
    _positionRequested = false;
    _cvRequested = true;
  }

  Future<void> _pickMedia() async {
    debugPrint("Attachment icon pressed.");
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _isLoading = true; // Show loading indicator
        });

        final filePath = result.files.single.path!;
        final fileExtension = result.files.single.extension;

        if (fileExtension == 'pdf') {
          final extractedText = await _extractTextFromPdf(filePath);

          // Send the extracted text and position to OpenAI
          await _sendCVForImprovement(_enteredPosition ?? "", extractedText);
        } else {
          setState(() {
            _messages.add(
              ChatMessage(
                user: _chatGPTUser,
                createdAt: DateTime.now(),
                text: "Unsupported file type. Please upload a valid PDF or DOCX file.",
              ),
            );
          });
        }
      } else {
        debugPrint("No file selected.");
      }
    } catch (e) {
      debugPrint("Media selection error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  Future<String> _extractTextFromPdf(String filePath) async {
    try {
      final fileBytes = File(filePath).readAsBytesSync();
      final PdfDocument document = PdfDocument(inputBytes: fileBytes);

      final String text = PdfTextExtractor(document).extractText();

      document.dispose();

      return text;
    } catch (e) {
      debugPrint("PDF extraction error: $e");
      return "Error extracting text from PDF.";
    }
  }

  Future<void> _sendCVForImprovement(String position, String cvText) async {
    final prompt =
        "Here is the CV text for a candidate applying for the position of '$position'. Based on ATS (Applicant Tracking System) optimization, provide specific recommendations to improve this CV. Suggest powerful entry-level courses or certifications that can strengthen the CV for this position:\n\n$cvText";

    final request = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {"role": "system", "content": "You are an expert in CV optimization."},
        {"role": "user", "content": prompt},
      ],
      maxToken: 500,
    );

    final response = await _openAI.onChatCompletion(request: request);

    for (var choice in response?.choices ?? []) {
      if (choice.message != null) {
        setState(() {
          _messages.add(
            ChatMessage(
              user: _chatGPTUser,
              createdAt: DateTime.now(),
              text: choice.message!.content,
            ),
          );
        });
      }
    }

    // Send a closing message after recommendations
    setState(() {
      _messages.add(
        ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text:
              "Thank you for using Hadafi CV Enhancement!\nWe hope these recommendations help you improve your CV.\nGood luck!",
        ),
      );
    });
  }
}
