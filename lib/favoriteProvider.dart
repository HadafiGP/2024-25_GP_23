import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _favoriteOpps = [];
  bool _isLoading = true;
  String? _currentUserId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> get favOpportunities => _favoriteOpps;
  bool get isLoading => _isLoading;

  FavoriteProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _isLoading = true;
        notifyListeners();
        loadFavorites();
      } else {
        _favoriteOpps.clear();
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {
      _favoriteOpps.clear();
      _isLoading = false;
      Future.delayed(Duration.zero, () {
        notifyListeners();
      });
      return;
    }

    _currentUserId = user.uid;
    _isLoading = true;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });

    try {
      final snapshot = await _firestore
          .collection('Student')
          .doc(_currentUserId)
          .collection('favorites')
          .get();

      _favoriteOpps = snapshot.docs.map((doc) {
        final data = doc.data();
        data['documentId'] = doc.id; 
        return data;
      }).toList();
    } catch (e) {
      print("Error loading favorites: $e");
    }

    _isLoading = false;
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });
  }

  Future<void> toggleFavorite(Map<String, dynamic> opportunity) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final collectionRef =
        _firestore.collection('Student').doc(user.uid).collection('favorites');

    int existingIndex = -1;

    final oppId = opportunity['id'];
    final oppUrl = opportunity['Job LinkedIn URL'] ??
        opportunity['Company Apply link'] ??
        opportunity['Apply url'] ??
        opportunity['companyLink'] ??
        '';

    if (oppId != null) {
      existingIndex = _favoriteOpps
          .indexWhere((opp) => opp['id'] != null && opp['id'] == oppId);
    } else {
      existingIndex = _favoriteOpps.indexWhere((opp) {
        final savedUrl = opp['Job LinkedIn URL'] ??
            opp['Company Apply link'] ??
            opp['Apply url'] ??
            opp['companyLink'] ??
            '';
        return savedUrl == oppUrl;
      });
    }

    if (existingIndex != -1) {
      final docId = _favoriteOpps[existingIndex]['documentId'];
      if (docId != null) {
        await collectionRef.doc(docId).delete();
      }
      _favoriteOpps.removeAt(existingIndex);
    } else {
      final docRef = await collectionRef.add(opportunity);
      final newOpportunity = {
        ...opportunity,
        'documentId': docRef.id,
      };
      _favoriteOpps.add(newOpportunity);
    }

    notifyListeners();
  }
}

final favoriteProvider = ChangeNotifierProvider<FavoriteProvider>((ref) {
  return FavoriteProvider();
});
