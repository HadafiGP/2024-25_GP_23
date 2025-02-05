import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'StudentHomePage.dart';
import 'CV.dart';
import 'interview.dart';
import 'welcome.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CVPage extends StatefulWidget {
  const CVPage({super.key});

  @override
  State<CVPage> createState() => _CVPageState();
}

class _CVPageState extends State<CVPage> {
  final _openAI = OpenAI.instance.build(
    token: dotenv.env['openAI_api_cv_key'] ?? '',
    baseOption: HttpSetup(
      receiveTimeout: const Duration(seconds: 60),
      connectTimeout: const Duration(seconds: 60),
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
  String connectionErrorMessage = ''; // For displaying internet error

  late SharedPreferences _preferences; // For saving and loading history
  String historyKey = "cvEnhancementHistory"; // Key for SharedPreferences

  String? _cvText; //Saving text for later use
  String? fileSize; //Saving file size for later use
  bool disableInput = false; //used to disable input after entering position

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences();
    _checkInternetConnection(); // Check internet connection on load
    _sendWelcomeMessage();
  }

  Future<void> _initializeSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    _loadHistory();
  }

  /// Check for internet connection
  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        connectionErrorMessage =
            'No internet connection. Please check your network.';
      });
    } else {
      setState(() {
        connectionErrorMessage = ''; // Clear the error message if connected
      });
    }
  }

  void _sendWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text:
              "Welcome to Hadafi CV Enhancement! Please select or enter the position you're applying for.",
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

  Future<void> _saveHistory() async {
    List<String> messagesJson =
        _messages.map((e) => jsonEncode(e.toJson())).toList();
    await _preferences.setStringList(historyKey, messagesJson);
  }

  void _loadHistory() {
    List<String>? messagesJson = _preferences.getStringList(historyKey);
    if (messagesJson != null && messagesJson.isNotEmpty) {
      setState(() {
        _messages = messagesJson
            .map((e) => ChatMessage.fromJson(jsonDecode(e)))
            .toList();
      });
    }
  }

  /// Show connectivity error banner
  Widget _showConnectionError() {
    if (connectionErrorMessage.isNotEmpty) {
      return Container(
        color: Colors.red,
        padding: const EdgeInsets.all(12.0),
        child: Text(
          connectionErrorMessage,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    return const SizedBox.shrink(); // Empty widget if no error
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
      body: Column(
        children: [
          _showConnectionError(), // Show internet error if any
          Expanded(
            child: Stack(
              children: [
                DashChat(
                  currentUser: _currentUser,
                  messageOptions: MessageOptions(
                    currentUserContainerColor: Colors.cyan,
                    containerColor: const Color(0xFF113F67),
                    textColor: Colors.white,
                    parsePatterns: [
                      MatchText(
                        pattern: r"/Content",
                        style: const TextStyle(
                            color: Color(0xFFF9F871),
                            fontWeight: FontWeight.bold),
                        onTap: (matchedText) => _handleOptionClick(matchedText),
                      ),
                      MatchText(
                        pattern: r"/Format",
                        style: const TextStyle(
                            color: Color(0xFFDDE47A),
                            fontWeight: FontWeight.bold),
                        onTap: (matchedText) => _handleOptionClick(matchedText),
                      ),
                      MatchText(
                        pattern:
                            r"Error Type:|How it affects ATS parsing accuracy:|Why It’s Recommended:|How it affects ATS parsing:",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        onTap: (matchedText) => _handleOptionClick(matchedText),
                      ),
                      MatchText(
                        pattern:
                            r"/CertificateSuggestions|Suggested Correction:|Fix:|Where to Obtain It:",
                        style: const TextStyle(
                            color: Color(0xFF8CDE7E),
                            fontWeight: FontWeight.bold),
                        onTap: (matchedText) => _handleOptionClick(matchedText),
                      ),
                      MatchText(
                        pattern: r"Certification Name:",
                        style: const TextStyle(
                            color: Color(0xFF00BB95),
                            fontWeight: FontWeight.bold),
                        onTap: (matchedText) => _handleOptionClick(matchedText),
                      ),
                      MatchText(
                        pattern:
                            r"/All\b", 
                        style: const TextStyle(
                          color: Color(0xFFFFA500),
                          fontWeight: FontWeight.bold,
                        ),
                        onTap: (matchedText) => _handleOptionClick(matchedText),
                      ),
                      MatchText(
                        pattern:
                            r"Issue:|Original Phrase:|Original Date Format:",
                        style: const TextStyle(
                            color: Color(0xFFFF4D4D),
                            fontWeight: FontWeight.bold),
                        onTap: (matchedText) => _handleOptionClick(matchedText),
                      ),
                      MatchText(
                        pattern:
                            r"Grammar & Spelling Analysis|Section Header Analysis|Date Format Analysis|Repetition Analysis|File Size Analysis|Word Count Analysis|Certification Recommendations",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
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
                              onPressed: () async {
                                bool isConnected =
                                    await _checkInternetBeforeAction();
                                if (isConnected) _pickMedia();
                              },
                            ),
                          ],
                          sendButtonBuilder: (_) => const SizedBox.shrink(),
                          inputDisabled: disableInput,
                        )
                      : InputOptions(
                          inputDecoration: InputDecoration(
                            hintText: disableInput
                                ? "Choose an option from above to review your CV!"
                                : "Enter the position you're applying for...",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          sendOnEnter: true,
                          inputDisabled: disableInput,
                        ),
                  quickReplyOptions: QuickReplyOptions(
                    onTapQuickReply: (QuickReply reply) async {
                      bool isConnected = await _checkInternetBeforeAction();
                      if (isConnected) _handleQuickReply(reply.value!);
                    },
                  ),
                  onSend: (ChatMessage message) async {
                    bool isConnected = await _checkInternetBeforeAction();
                    if (isConnected) _handleSend(message);
                  },
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
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 590.0), // Adjust if needed
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CVHistoryPage(messages: _messages),
              ),
            );
          },
          mini: true,
          backgroundColor: const Color.fromARGB(
              200, 194, 215, 240), // Match your app's theme
          child: const Icon(Icons.history, color: const Color(0xFF113F67)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Reusable method to check internet connection before actions
  Future<bool> _checkInternetBeforeAction() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        connectionErrorMessage =
            'No internet connection. Please check your network.';
      });
      return false; // No internet
    }
    setState(() {
      connectionErrorMessage = ''; // Clear error if connected
    });
    return true; // Internet is connected
  }

  void _handleQuickReply(String reply) async {
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
      return;
    }

    //  quick replies for cv check options
    if (reply == "/Content") {
      await _CVContentChecking(
          _enteredPosition ?? "Unknown Position", _cvText ?? "");
      _askForAnotherCheck();
      return;
    } else if (reply == "/Format") {
      await _CVFormatChecking(_enteredPosition ?? "Unknown Position",
          _cvText ?? "", fileSize ?? "");
      _askForAnotherCheck();
      return;
    } else if (reply == "/CertificateSuggestions") {
      await _CVSuggestions(
          _enteredPosition ?? "Unknown Position", _cvText ?? "");
      _askForAnotherCheck();
      return;
    } else if (reply == "/All") {
      await _CVContentChecking(
          _enteredPosition ?? "Unknown Position", _cvText ?? "");
      await _CVFormatChecking(_enteredPosition ?? "Unknown Position",
          _cvText ?? "", fileSize ?? "");
      await _CVSuggestions(
          _enteredPosition ?? "Unknown Position", _cvText ?? "");
      _askForAnotherCheck();
      return;
    } else if (reply == "/Stop") {
      setState(() {
        _messages.add(
          ChatMessage(
            user: _chatGPTUser,
            createdAt: DateTime.now(),
            text: "Thank you for using Hadafi CV Enhancement! 🎉 Best of luck!",
          ),
        );
      });
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
    disableInput = true;
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

        //Get file size for CV analysis
        final File selectedFile = File(filePath);
        double fileSizeInMB = selectedFile.lengthSync() / (1024 * 1024);
        fileSize = "${fileSizeInMB.toStringAsFixed(2)} MB";

        if (fileExtension == 'pdf') {
          final extractedText = await _extractTextFromPdf(filePath);
          _cvText = extractedText; // Save extracted CV text
          _showCheckOptions(); // Show CV check options
        } else {
          setState(() {
            _messages.add(
              ChatMessage(
                user: _chatGPTUser,
                createdAt: DateTime.now(),
                text:
                    "Unsupported file type. Please upload a valid PDF or DOCX file.",
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
      await Future.delayed(const Duration(seconds: 2));
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

  void _showCheckOptions() {
    setState(() {
      _cvRequested = false;
      _messages.add(
        ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: "Would you like to check your CV for: \n \n"
              "/Content: Check grammar & spelling mistakes, check if section headers are ATS-friendly, and spot repeated words or phrases in the CV, and if the date format aligns with ATS standards. \n \n"
              "/Format: Check if your file size is appropriate, and if the length of the CV aligns with the standard entry-level length. \n \n"
              "/CertificateSuggestions: Get recommendations for relevant certifications for your position. \n \n"
              "/All: Check all the above.",
          quickReplies: [
            QuickReply(title: "Content", value: "/Content"),
            QuickReply(title: "Format", value: "/Format"),
            QuickReply(
                title: "Certificate Suggestions",
                value: "/CertificateSuggestions"),
            QuickReply(title: "All", value: "/All"),
          ],
        ),
      );
    });
  }

  void _handleOptionClick(String option) async {
    if (option == "/Content") {
      await _CVContentChecking(
          _enteredPosition ?? "Unknown Position", _cvText ?? "");
      _askForAnotherCheck();
    } else if (option == "/Format") {
      await _CVFormatChecking(_enteredPosition ?? "Unknown Position",
          _cvText ?? "", fileSize ?? "");
      _askForAnotherCheck();
    } else if (option == "/CertificateSuggestions") {
      await _CVSuggestions(
          _enteredPosition ?? "Unknown Position", _cvText ?? "");
      _askForAnotherCheck();
    } else if (option == "/All") {
      await _CVContentChecking(
          _enteredPosition ?? "Unknown Position", _cvText ?? "");
      await _CVFormatChecking(_enteredPosition ?? "Unknown Position",
          _cvText ?? "", fileSize ?? "");
      await _CVSuggestions(
          _enteredPosition ?? "Unknown Position", _cvText ?? "");

      _askForAnotherCheck();
    }
  }

  void _askForAnotherCheck() {
    setState(() {
      _messages.add(
        ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: "Would you like to check anything else?",
          quickReplies: [
            QuickReply(title: "Content", value: "/Content"),
            QuickReply(title: "Format", value: "/Format"),
            QuickReply(
                title: "Certificate Suggestions",
                value: "/CertificateSuggestions"),
            QuickReply(title: "All", value: "/All"),
            QuickReply(title: "I'm done", value: "/Stop"),
          ],
        ),
      );
    });
  }

  Future<void> _CVContentChecking(String position, String cvText) async {
    // Notify the user about grammar & spelling check
    setState(() {
      _messages.add(ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "🔍 Analyzing Grammar & Spelling, Please wait ⏳",
      ));
    });

    // Grammar & spelling check
    final grammarRequest = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {
          "role": "system",
          "content": "You are an expert in resume grammar correction."
        },
        {
          "role": "user",
          "content": """
You are an ATS Resume Optimization Specialist. Evaluate the following resume $cvText for spelling and grammar, focusing on maintaining professional and ATS-compatible language.

Instructions:

1. Title the output “Grammar & Spelling Analysis”

2.	Identify spelling or grammar issues in the text.

3.	For each issue, provide:
•	Original Phrase: [Insert problematic text].
•	Error Type: [spelling, grammar]. -Don’t include any other types beside these-
•	Suggested Correction: [Provide the corrected text].

3- Ignore grammar & speeling issues related to email links, and contact alignment, and dates. Focus only on textual content that Imoact ATS parsing.

4. Keep your output brief, focusing only on critical issues and actionable corrections.

5. If you find no errors in the resume output: “Congratulations! Your resume is free of grammar and spelling errors! 🎉✨”.

Use a professional and supportive tone in your suggestions to help improve the resume’s impact. Keep the corrections concise and relevant to ATS optimization.
      """
        },
      ],
      maxToken: 500,
    );

    final grammarResponse =
        await _openAI.onChatCompletion(request: grammarRequest);

    if (grammarResponse?.choices.isNotEmpty ?? false) {
      setState(() {
        _messages.add(ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: grammarResponse!.choices.first.message!.content,
        ));
      });
    }

    // Notify the user about section headers check
    setState(() {
      _messages.add(ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "🔍 Analyzing Section Headers, Please wait ⏳",
      ));
    });

    // Section header check
    final headerRequest = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {
          "role": "system",
          "content": "You are an expert in ATS resume header evaluation."
        },
        {
          "role": "user",
          "content": """
   You are an ATS Optimization Specialist tasked with evaluating resumes for text-based compatibility with ATS systems. Analyze a nearly-graduated student’s resume $cvText applying for $position, focusing specifically on identifying weaknesses in section headers that may hinder ATS parsing.
 Instructions:
1- Title the output with “Section Header Analysis”

2- Ensure the resume uses clear, standard headers like “Work Experience,” “Education,” “Skills,” and “Projects,” avoiding creative or ambiguous headings.

3- identify if any important or required headers are missing, such as “Certifications,” “Internships,” “Achievements,” or “Technical Skills,” which are commonly relevant for ATS systems when evaluating entry-level candidates.

4-		For each issue, provide:
    • issue: [insert issue text]
    • How it affects ATS parsing accuracy: [insert the affects text]
    • Suggested Correction: [Provide the corrected text] 

5- Keep your output brief, focusing only on describing the issue related to the section header, how it affects parsing accuracy, and a suggestion to fix it.

6- If there are no mistakes and all required headers are present output: ‘Congratulations! There are no mistakes in your section headers! And you already have all required ones! 🎉✨.’

Maintain a professional and constructive tone and don’t provide a summary of the findings or fixes.
      """
        },
      ],
      maxToken: 500,
    );

    final headerResponse =
        await _openAI.onChatCompletion(request: headerRequest);

    if (headerResponse?.choices.isNotEmpty ?? false) {
      setState(() {
        _messages.add(ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: headerResponse!.choices.first.message!.content,
        ));
      });
    }

    //  Notify the user about repetition check
    setState(() {
      _messages.add(ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "🔍 Analyzing Repetition, Please wait ⏳",
      ));
    });

    // Repetition check
    final repetitionRequest = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {
          "role": "assistant",
          "content": "You are an expert in ATS resume evaluation."
        },
        {
          "role": "user",
          "content": """
You are an ATS Optimization Specialist tasked with evaluating resumes for text-based compatibility with ATS systems. Analyze a nearly-graduated student’s resume $cvText applying for $position, focusing specifically on identifying weaknesses related to repetition that may hinder ATS parsing and readability.

Instructions:
	1-	Title the output with “Repetition Analysis.”

	2-	Identify and flag overused words or phrases, particularly in skills and achievements. Look for excessive repetition of the same verbs, adjectives, or industry-specific terms.

	3-	Detect redundant information, such as similar bullet points repeated across different roles or sections.

	4-	For each issue, provide:
    • original phrase: [insert problematic text]
    • How it affects ATS parsing: [insert the affects text]
    • Suggested Correction: [Provide the corrected text] 

  5-	If there are no issues, output: “Congratulations! There are no repetition issues in your CV! 🎉✨”

	6-	Keep your output brief, focusing only on giving a brief description of the detected repetition, how it affects ATS parsing and readability, and a suggestion to fix it.


Maintain a professional and constructive tone and avoid summarizing findings or fixes.
      """
        },
      ],
      maxToken: 500,
    );

    final repetitionResponse =
        await _openAI.onChatCompletion(request: repetitionRequest);

    if (repetitionResponse?.choices.isNotEmpty ?? false) {
      setState(() {
        _messages.add(ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: repetitionResponse!.choices.first.message!.content,
        ));
      });
    }

    //  Notify the user about date check
    setState(() {
      _messages.add(ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "🔍 Analyzing date format, Please wait ⏳",
      ));
    });

    // Date check
    final DateRequest = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {
          "role": "assistant",
          "content": "You are an expert in ATS resume evaluation."
        },
        {
          "role": "user",
          "content": """
You are an ATS Resume Optimization Specialist. Evaluate the following resume $_cvText for date formatting issues, ensuring consistency and ATS compatibility.

Instructions:
	1.	Title the output “Date Format Analysis.”

	2.	Identify date formatting issues that may hinder ATS parsing, such as:
	•	Inconsistent date formats (e.g., “Jan 2023 – Present” vs. “01/2023 – 12/23”).
	•	Non-standard or ambiguous formats that ATS may misinterpret (e.g., “Summer 2022” or “Current” instead of “Present”).
	•	Missing start or end dates for roles, internships, or education.

	3.	For each issue, provide:
	•	Original Date Format: [Insert problematic text].
	•	Error Type: [Inconsistent Format, Ambiguous Date, Missing Date]. (Do not include any other types beside these.)
	•	Suggested Correction: [Provide the corrected date format].

	4.	Keep your output brief, focusing only on critical issues and actionable corrections to improve ATS compatibility only.

	5.	If you find no errors in the resume, output: “Congratulations! Your resume has no date formatting issues! 🎉✨”

Use a professional and supportive tone in your suggestions to help improve the resume’s impact. Ensure all corrections follow a clear, ATS-friendly format to avoid parsing errors.
      """
        },
      ],
      maxToken: 500,
    );

    final DateResponse = await _openAI.onChatCompletion(request: DateRequest);

    if (DateResponse?.choices.isNotEmpty ?? false) {
      setState(() {
        _messages.add(ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: DateResponse!.choices.first.message!.content,
        ));
      });
    }
  }

  Future<void> _CVFormatChecking(
      String position, String cvText, String size) async {
    // Notify the user about file size check
    setState(() {
      _messages.add(ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "🔍 Analyzing CV size, Please wait ⏳",
      ));
    });

    // CV size check
    final sizeRequest = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {
          "role": "system",
          "content": "You are an expert in resume grammar correction."
        },
        {
          "role": "user",
          "content": """
You are an ATS Optimization Specialist. Evaluate the following CV file size $size to ensure it meets industry standards and ATS compatibility. The ideal file size should be under 2MB.

Instructions:
1. If the file size exceeds 2MB, respond with the exact amount that needs to be reduced to meet the limit. 
   • Example response:
     ‘File Size Analysis
     
     Your resume file is currently 2.5MB, which is 500KB over the recommended limit of 2MB for ATS parsing. To optimize your CV, consider compressing images, removing unnecessary graphics, or converting it to a text-based PDF format.’

2. If the file size is within the ideal range (below 2MB), respond only with:
   ‘Congratulations! Your resume meets the maximum upload limit (2MB) accepted by most platforms. Ensure it stays within this limit to avoid submission issues. 🎉✨.’

Keep the output short, actionable, and focused on file size adjustments only.

      """
        },
      ],
      maxToken: 500,
    );

    final sizeResponse = await _openAI.onChatCompletion(request: sizeRequest);

    if (sizeResponse?.choices.isNotEmpty ?? false) {
      setState(() {
        _messages.add(ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: sizeResponse!.choices.first.message!.content,
        ));
      });
    }

    // Notify the user about CV length check
    setState(() {
      _messages.add(ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "🔍 Analyzing CV length, Please wait ⏳",
      ));
    });

    // CV length check
    final lengthRequest = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {
          "role": "system",
          "content": "You are an expert in ATS resume header evaluation."
        },
        {
          "role": "user",
          "content": """
You are an ATS Optimization Specialist. Evaluate the word count of the following resume: $cvText for an entry-level position based on industry standards and ATS parsing best practices. The ideal word count range is 450–600 words.

Instructions:
1. If the word count is too short or too long, respond with the exact number of words that need to be added or removed to align with the 450–600 word range.

2. Frame your response in a professional yet supportive tone. For example: 
‘Word Count Analysis
issue: Your resume currently contains 100 words, which is 350 words below the recommended range of 450–600 words for entry-level roles. 

Fix: Consider adding more content such as’ and then suggest which areas to add more content to.

3. If the word count is already within the ideal range, respond only with: ‘Congratulations! The length of your resume is perfect for the role you are applying for 🎉✨.’

Keep the output short, actionable, and focused on word count adjustments only.

      """
        },
      ],
      maxToken: 500,
    );

    final lengthResponse =
        await _openAI.onChatCompletion(request: lengthRequest);

    if (lengthResponse?.choices.isNotEmpty ?? false) {
      setState(() {
        _messages.add(ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: lengthResponse!.choices.first.message!.content,
        ));
      });
    }

    /*  Notify the user about Bullets check
    setState(() {
      _messages.add(ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "🔍 Analyzing Bullet Points length, Please wait ⏳",
      ));
    });

    // Bullets check
    final BulletsRequest = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {
          "role": "assistant",
          "content": "You are an expert in ATS resume evaluation."
        },
        {
          "role": "user",
          "content": """
You are an ATS Optimization Specialist tasked with evaluating resumes for text-based compatibility with ATS systems. Analyze a nearly-graduated student’s resume $cvText applying for $position, focusing only on bullet point usage and length to enhance ATS optimization.

Instructions: 
1- Title the output “Bullet Point Analysis"

2- Check for Proper Bullet Point Usage: 
   • Identify if the Work Experience, Skills, Achievements, Projects, Certifications, and Education sections use bullet points instead of paragraphs.  
   • If bullet points are missing, highlight the issue and suggest a structured format.  

   • Example Response (if bullet points are missing):
   Bullet Point Analysis
     Issue: Your resume currently uses paragraph formatting in the Work Experience section while the recommended formatting is bullet points.  

     Recommended Fix: Convert responsibilities and achievements into bullet points.   
     Current:“Managed social media campaigns and increased engagement by 30% over six months. Led a team of three interns, providing training and performance feedback. Implemented a new content strategy that reduced costs by 15%.”  
     Improved:
     - Managed social media campaigns, increasing engagement by 30% in six months.  
     - Led a team of three interns, providing training and performance feedback.  
     - Implemented a new content strategy,  reducing costs by 15%.  

2- Evaluate Bullet Point Length (20–50 words):

   • Identify if any bullet points are too short (<20 words) or too long (>50 words).  
   • If a bullet point is too short, specify the number of words missing and suggest areas to expand.  
   • If a bullet point is too long, specify how many words should be removed and suggest a concise rewrite.  

   • Example Response (if bullet points need adjustments):
       Bullet Point Analysis:
       Issue: Some bullet points exceed or fall below the 20–50 word range.
       Recommended Fix:  Add details on implementation and impact.   
       Current: ‘Increased revenue by optimizing sales strategy.’ (9 words)   
       Improved: ‘Increased revenue **by 15% in three months by optimizing sales strategy and enhancing client outreach efforts.’ (22 words)  
 
3-If bullet points are correctly formatted and within the ideal length, respond only with:
   "Congratulations! All your bullet points follow the recommended length of 20–50 words! 🎉✨"

4- Keep the output brief, focusing only on bullet points critical issues, recommended fixes, and how to improve/fix them

Maintain a professional and constructive tone, keeping the response brief and actionable without unnecessary summaries or mentioning any issues like missing section headers, you are only analyzing bullet point usage and length.

      """
        },
      ],
      maxToken: 500,
    );

    final BulletsResponse =
        await _openAI.onChatCompletion(request: BulletsRequest);

    if (BulletsResponse?.choices.isNotEmpty ?? false) {
      setState(() {
        _messages.add(ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: BulletsResponse!.choices.first.message!.content,
        ));
      });
    } */
  }

  Future<void> _CVSuggestions(String position, String cvText) async {
    // Notify the user about suggestions
    setState(() {
      _messages.add(ChatMessage(
        user: _chatGPTUser,
        createdAt: DateTime.now(),
        text: "🔍 Analyzing CV for suggestions, Please wait ⏳",
      ));
    });

    // Certification suggestions
    final suggestionsRequest = ChatCompleteText(
      model: Gpt4ChatModel(),
      messages: [
        {
          "role": "system",
          "content": "You are an expert in resume grammar correction."
        },
        {
          "role": "user",
          "content": """
You are an ATS Optimization Specialist tasked with evaluating resumes for text-based compatibility with ATS systems. Analyze a nearly-graduated student’s resume $cvText applying for $position, focusing only on identifying relevant certifications that can enhance the user’s acceptance for this position.

Instructions:
1-Title the output with “Certification Recommendations”.

2- Based on the job role $position, analyze the candidate’s skills, education, coursework, and any relevant sections in the resume to determine which relevant certifications would strengthen their profile.

3- DO NOT recommend certifications that are already listed in the CV.

4- Recommend only widely recognized certifications that directly enhance the user’s competitiveness for $position.

5- For each recommended certification, provide:
  - Certification Name: [Insert Name]

  - Why It’s Recommended: [Explain how it aligns with the job role and enhances hiring chances]

  - Where to Obtain It: [If applicable, suggest a well-known certifying body or institution]

5- If the resume already contains all necessary certifications, output: “Congratulations! Your resume already includes all relevant certifications for $_enteredPosition. No further recommendations needed! 🎉✨”

Maintain a professional and constructive tone, keeping the recommendations clear, concise, and relevant.

      """
        },
      ],
      maxToken: 500,
    );

    final suggestionsResponse =
        await _openAI.onChatCompletion(request: suggestionsRequest);

    if (suggestionsResponse?.choices.isNotEmpty ?? false) {
      setState(() {
        _messages.add(ChatMessage(
          user: _chatGPTUser,
          createdAt: DateTime.now(),
          text: suggestionsResponse!.choices.first.message!.content,
        ));
      });
    }
  }

  /* Future<void> _sendCVForImprovement(String position, String cvText) async {
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
  } */
}

class CVHistoryPage extends StatelessWidget {
  final List<ChatMessage> messages;

  const CVHistoryPage({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    final ChatUser _currentUser =
        ChatUser(id: "1", firstName: "User", lastName: "User");
    final ChatUser _chatGPTUser = ChatUser(
      id: "2",
      firstName: "Hadafi",
      profileImage: "https://i.imgur.com/Be1jZ9c.jpeg",
    );

    final messageOptions = MessageOptions(
      currentUserContainerColor: Colors.cyan,
      containerColor: const Color(0xFF113F67),
      textColor: Colors.white,
      parsePatterns: [
        MatchText(
          pattern: r'(?<!\w)(https:\/\/[^\s\)]+)', // Match URLs
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          onTap: (url) async {
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
        ),
      ],
    );

    if (messages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('No History'),
              content:
                  const Text('There\'s no CV Enhancement history to display!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        title: const Text(
          'CV Enhancement History',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
      ),
      body: DashChat(
        currentUser: _currentUser,
        messages:
            messages.reversed.toList(), // Display messages chronologically
        readOnly: true, // Makes the chat read-only
        inputOptions: const InputOptions(
          inputDisabled: true, // Disables the input field
        ),
        onSend: (ChatMessage message) {}, // No send action
        messageOptions: messageOptions,
      ),
    );
  }
}
