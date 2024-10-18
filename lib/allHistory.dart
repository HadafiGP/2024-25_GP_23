import 'dart:convert';

class allHistory {
  final String sender;
  final String message;

  allHistory({required this.sender, required this.message});
//convets back from JSON
  factory allHistory.fromJson(Map<String, dynamic> json) {
    return allHistory(
      sender: json['sender'] as String,
      message: json['message'] as String,
    );
  }
//convetrs to JSON
  Map<String, dynamic> toJson() => {
      'sender': sender,
      'message': message,
    
  };
}