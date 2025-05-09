

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String username;
  final String profilePic;

  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.username,
    required this.profilePic,
  });


  factory Comment.fromMap(Map<String, dynamic> map) {
      print("DEBUG: createdAt raw value -> ${map['createdAt']}"); 
      print("DEBUG: createdAt type -> ${map['createdAt'].runtimeType}"); 

    return Comment(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] is Timestamp
    ? (map['createdAt'] as Timestamp).toDate()
    : map['createdAt'] is String
        ? DateTime.parse(map['createdAt'])
        : map['createdAt'] is DateTime
            ? map['createdAt']
            : DateTime.now(),
      postId: map['postId'] ?? '',
      username: map['username'] ?? '',
      profilePic: map['profilePic'] ?? '',
    );
  }

 
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt), 
      'postId': postId,
      'username': username,
      'profilePic': profilePic,
    };
  }


  Comment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? postId,
    String? username,
    String? profilePic,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
    );
  }

 
  @override
  String toString() {
    return 'Comment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, username: $username, profilePic: $profilePic)';
  }
}
