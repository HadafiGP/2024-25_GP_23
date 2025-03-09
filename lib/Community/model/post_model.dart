// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String title;
  final String? link;
  final String? description;
  final String communityName;
  final String communityProfilePic;
  final List<String> upvotes;
  final List<String> downvotes;
  final int commentCount;
  final String username;
  final String uid;
  final String type;
  final DateTime createdAt;
  final List<String> awards;
  Post({
    required this.id,
    required this.title,
    this.link,
    this.description,
    required this.communityName,
    required this.communityProfilePic,
    required this.upvotes,
    required this.downvotes,
    required this.commentCount,
    required this.username,
    required this.uid,
    required this.type,
    required this.createdAt,
    required this.awards,
  });

  Post copyWith({
    String? id,
    String? title,
    String? link,
    String? description,
    String? communityName,
    String? communityProfilePic,
    List<String>? upvotes,
    List<String>? downvotes,
    int? commentCount,
    String? username,
    String? uid,
    String? type,
    DateTime? createdAt,
    List<String>? awards,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      communityName: communityName ?? this.communityName,
      communityProfilePic: communityProfilePic ?? this.communityProfilePic,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'description': description,
      'communityName': communityName,
      'communityProfilePic': communityProfilePic,
      'upvotes': List<dynamic>.from(upvotes), // ✅ Fix for List<String>
      'downvotes': List<dynamic>.from(downvotes), // ✅ Fix for List<String>
      'commentCount': commentCount,
      'username': username,
      'uid': uid,
      'type': type,
      'createdAt':
          Timestamp.fromDate(createdAt), // ✅ Fix Firestore DateTime issue
      'awards': List<dynamic>.from(awards), // ✅ Fix for List<String>
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      link: map['link'],
      description: map['description'],
      communityName: map['communityName'] ?? '',
      communityProfilePic: map['communityProfilePic'] ?? '',
      upvotes: List<String>.from(
          map['upvotes'] ?? []), // ✅ Convert List<dynamic> to List<String>
      downvotes: List<String>.from(
          map['downvotes'] ?? []), // ✅ Convert List<dynamic> to List<String>
      commentCount: map['commentCount'] ?? 0,
      username: map['username'] ?? '',
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      createdAt: map['createdAt'] is Timestamp
    ? (map['createdAt'] as Timestamp).toDate()
    : map['createdAt'] is String
        ? DateTime.parse(map['createdAt'])
        : map['createdAt'] is DateTime
            ? map['createdAt']
            : DateTime.now(),// ✅ Convert Firestore Timestamp to DateTime
      awards: List<String>.from(
          map['awards'] ?? []), // ✅ Convert List<dynamic> to List<String>
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, link: $link, description: $description, communityName: $communityName, communityProfilePic: $communityProfilePic, upvotes: $upvotes, downvotes: $downvotes, commentCount: $commentCount, username: $username, uid: $uid, type: $type, createdAt: $createdAt, awards: $awards)';
  }

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.link == link &&
        other.description == description &&
        other.communityName == communityName &&
        other.communityProfilePic == communityProfilePic &&
        listEquals(other.upvotes, upvotes) &&
        listEquals(other.downvotes, downvotes) &&
        other.commentCount == commentCount &&
        other.username == username &&
        other.uid == uid &&
        other.type == type &&
        other.createdAt == createdAt &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        link.hashCode ^
        description.hashCode ^
        communityName.hashCode ^
        communityProfilePic.hashCode ^
        upvotes.hashCode ^
        downvotes.hashCode ^
        commentCount.hashCode ^
        username.hashCode ^
        uid.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        awards.hashCode;
  }
}
