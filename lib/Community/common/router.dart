import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:hadafi_application/Community/user_profile/screens/user_profile_screen.dart';
import 'package:hadafi_application/Community/CommunityProfile.dart';
import 'package:hadafi_application/Community/post/screens/comments_screen.dart';

final routes = RouteMap(
  routes: {
    '/r/:communityName': (route) => MaterialPage(
          child: Communityprofile(name: route.pathParameters['name']!),
        ),
    '/user/:uid': (route) => MaterialPage(
          child: UserProfileScreen(uid: route.pathParameters['uid']!),
        ),
    '/post/:postId/comments': (route) => MaterialPage(
          child: CommentsScreen(postId: route.pathParameters['postId']!),
        ),
  },
);