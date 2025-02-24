import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Map<String, dynamic>> favoriteOpps = []; 

  List<Map<String, dynamic>> get favOpportunities => favoriteOpps;

  void toggleFavorite(Map<String, dynamic> opportunity) {
    final isExist = favoriteOpps.any((opp) => opp['Job Title'] == opportunity['Job Title']); 
    if (isExist) {
      favoriteOpps.removeWhere((opp) => opp['Job Title'] == opportunity['Job Title']);
    } else {
      favoriteOpps.add(opportunity);
    }
    notifyListeners();
  }

  void clearFavorites() {
    favoriteOpps.clear();
    notifyListeners();
  }
}

final favoriteProvider = ChangeNotifierProvider<FavoriteProvider>((ref) {
  return FavoriteProvider();
});
