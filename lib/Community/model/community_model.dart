import 'package:flutter/foundation.dart';

class Community {
  final String id;
  final String name;
  final String banner;
  final String avatar;
  final String description;
  final List<String> topics;
  final List<String> members;
  final List<String> mods;

  Community({
    required this.id,
    required this.name,
    required this.banner,
    required this.avatar,
    required this.description,
    required List<String> topics,
    required this.members,
    required this.mods,
  }) : topics = topics.length > 3 ? topics.sublist(0, 3) : topics;

  Community copyWith({
    String? id,
    String? name,
    String? banner,
    String? avatar,
    String? description,
    List<String>? topics,
    List<String>? members,
    List<String>? mods,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      banner: banner ?? this.banner,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      topics: topics != null
          ? (topics.length > 3 ? topics.sublist(0, 3) : topics)
          : this.topics,
      members: members ?? this.members,
      mods: mods ?? this.mods,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'banner': banner,
      'avatar': avatar,
      'description': description,
      'topics': topics,
      'members': members,
      'mods': mods,
    };
  }

  factory Community.fromMap(Map<String, dynamic> map) {
    List<String> topicsList = List<String>.from(map['topics'] ?? []);
    return Community(
      id: map['id'] as String,
      name: map['name'] as String,
      banner: map['banner'] as String,
      avatar: map['avatar'] as String,
      description: map['description'] as String,
      topics: topicsList.length > 3 ? topicsList.sublist(0, 3) : topicsList,
      members: List<String>.from(map['members']),
      mods: List<String>.from(map['mods']),
    );
  }

  @override
  String toString() {
    return 'Community(id: $id, name: $name, banner: $banner, avatar: $avatar, description: $description, topics: $topics, members: $members, mods: $mods)';
  }

  @override
  bool operator ==(covariant Community other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.banner == banner &&
        other.avatar == avatar &&
        other.description == description &&
        listEquals(other.topics, topics) &&
        listEquals(other.members, members) &&
        listEquals(other.mods, mods);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        banner.hashCode ^
        avatar.hashCode ^
        description.hashCode ^
        topics.hashCode ^
        members.hashCode ^
        mods.hashCode;
  }
}
