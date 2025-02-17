import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GeneralstoreProductsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _product = [];
  List<Map<String, dynamic>> get productData => _product;
  bool _isLoading = false; // Track loading state
  bool get isLoading => _isLoading;
  final String sheetId = '1j1k6RQIyopHwUba3ki04uLfa1fdYJiM2qXWToKhvUwc';
  final String sheetTitle = 'generalstoreproducts';
  final String sheetRange = 'A2:J';

  Future<void> fetchData() async {
    try {
      _isLoading = true; // Set loading state to true
      notifyListeners();
      final connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        await _loadDataFromCache();
      } else {
        await _fetchDataFromNetwork();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDataFromCache() async {
    try {
      var cacheManager = DefaultCacheManager();
      var fileInfo = await cacheManager.getFileFromCache(
        'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq?sheet=$sheetTitle&range=$sheetRange',
      );
      if (fileInfo != null && fileInfo.file.existsSync()) {
        final jsonString = await fileInfo.file.readAsString();
        final decodedData = json.decode(jsonString);
        final rows = decodedData['table']['rows'] as List<dynamic>;
        _updateData(rows.cast<Map<String, dynamic>>());
      } else {
        throw Exception('No cached data available');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data from cache: $e');
      }
    }
  }

  Future<void> _fetchDataFromNetwork() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq?sheet=$sheetTitle&range=$sheetRange',
        ),
      );
      if (response.statusCode == 200) {
        final String responseBody = response.body;
        final startIndex = responseBody.indexOf('({') + 1;
        final endIndex = responseBody.lastIndexOf('})') + 1;
        final jsonString = responseBody.substring(startIndex, endIndex);
        final decodedData = json.decode(jsonString);
        final rows = decodedData['table']['rows'] as List<dynamic>;
        _updateData(rows.cast<Map<String, dynamic>>());

        final Uint8List bytes = Uint8List.fromList(utf8.encode(jsonString));
        var cacheManager = DefaultCacheManager();
        cacheManager.putFile(
          'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq?sheet=$sheetTitle&range=$sheetRange',
          bytes,
        );
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data from network: $e');
      }
    }
  }

  void _updateData(List<Map<String, dynamic>> rows) {
    _product = rows.map((row) {
      final List<dynamic> cells = row['c'];

      String name = cells.length > 0 ? cells[0]['v'] ?? '' : '';
      String imagePath = cells.length > 1 ? cells[1]['v'] ?? '' : '';
       dynamic price = cells.length > 2 ? cells[2]['v'] ?? '' : '';
      String description = cells.length > 3 ? cells[3]['v'] ?? '' : '';
      // String address =
      //     cells.length > 4 ? cells[4]['v'] ?? 0.0 : 0.0; // Parse as double
      dynamic expredate = cells.length > 4 ? cells[4]['v'] ?? '' : '';
      String munfacture = cells.length > 5 ? cells[5]['v'] ?? '' : '';
      dynamic rating = cells.length > 6 ? cells[6]['v'] ?? '' : '';
      String comment = cells.length > 7 ? cells[7]['v'] ?? '' : '';
      dynamic id = cells.length > 8 ? cells[8]['v'] ?? '' : '';

      return {
        'name': name,
        'imagePath': imagePath,
         'price': price,
        'description': description,
       // 'address': address,
        'expredate': expredate,
        'munfacture': munfacture,
        'rating': rating,
        'comment': comment,
        'id': id
      };
    }).toList();

    notifyListeners();
  }

  Future<void> clearCache() async {
    try {
      var cacheManager = DefaultCacheManager();
      await cacheManager.removeFile(
        'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq?sheet=$sheetTitle&range=$sheetRange',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }
Future<void> updateRating(
      String productId, double rating, String username) async {
    await FirebaseFirestore.instance
        .collection('Generalstore')
        .doc(productId)
        .collection('ratings')
        .doc(username)
        .set({'rating': rating, 'username': username}, SetOptions(merge: true));
  }

  Future<double> fetchAverageRating(String productId) async {
    final ratingsSnapshot = await FirebaseFirestore.instance
        .collection('Generalstore')
        .doc(productId)
        .collection('ratings')
        .get();

    if (ratingsSnapshot.docs.isEmpty) return 0.0;

    final totalRating = ratingsSnapshot.docs.fold<double>(
      0.0,
      (sum, doc) => sum + (doc.data()['rating'] as double),
    );

    return totalRating / ratingsSnapshot.docs.length;
  }

  Stream<List<Map<String, dynamic>>> fetchAllRatings(String productId) {
    return FirebaseFirestore.instance
        .collection('Generalstore')
        .doc(productId)
        .collection('ratings')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'rating': data['rating'] ?? 0.0,
          'username': data['username'] ?? 0.0,
        };
      }).toList();
    });
  }
  // Future<void> updateRating(String productId, double rating) async {
  //   await FirebaseFirestore.instance
  //       .collection('products')
  //       .doc(productId)
  //       .set({'rating': rating}, SetOptions(merge: true));
  //   final product =
  //       _product.firstWhere((product) => product['id'] == productId);
  //   product['rating'] = rating;
  //   notifyListeners();
  // }

  // Future<double> fetchRating(String productId) async {
  //   final doc = await FirebaseFirestore.instance
  //       .collection('products')
  //       .doc(productId)
  //       .get();
  //   if (doc.exists && doc.data() != null && doc.data()!['rating'] != null) {
  //     return doc.data()!['rating'];
  //   }
  //   return 0.0;
  // }

  Future<void> addComment(String productId, String comment,String username) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .collection('comments')
        .add({
      'comment': comment,
        'username': username,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> fetchComments(String productId) {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'comment': data['comment'] ?? '',
          'username': data['username'] ?? '',
          'timestamp': _formatDate(data['timestamp']),
        };
      }).toList();
    });
  }
   String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }
}
