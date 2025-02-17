import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:skardubazar/provider/generalstore_product.dart';
import 'package:skardubazar/services/session_manager.dart';
import 'package:skardubazar/views/New/search_screen.dart';

import '../../../provider/Garment/garment_product.dart';
import '../../../provider/phmarcy_shop_provider.dart';
import '../../../provider/product_details_provider.dart';
import '../../../provider/stationary/stationry_product.dart';

class StationaryProductDetails extends StatefulWidget {
  final String? Id;
  final String? title;
  final String? imagePath;

  StationaryProductDetails({
    Key? key,
    this.title,
    this.imagePath,
    this.Id,
  }) : super(key: key);

  @override
  State<StationaryProductDetails> createState() =>
      _StationaryProductDetailsState();
}

class _StationaryProductDetailsState extends State<StationaryProductDetails> {
  double? _userRating;
  final TextEditingController _commentController = TextEditingController();
  final SessionController _sessionController = SessionController();
  @override
  void initState() {
    super.initState();
    final shop = Provider.of<StationaryProdcut>(context, listen: false);
    if (shop.productData.isEmpty) {
      shop.fetchData();
    }
    _loadRating();
  }

  // Future<void> _loadRating() async {
  //   final shop = Provider.of<StationaryProdcut>(context, listen: false);
  //   final rating = await shop.fetchRating(widget.Id!);
  //   setState(() {
  //     _userRating = rating;
  //   });
  // }
  Future<void> _loadRating() async {
    final shop = Provider.of<StationaryProdcut>(context, listen: false);
    if (widget.Id != null && widget.Id!.isNotEmpty) {
      final rating = await shop.fetchAverageRating(widget.Id!);
      setState(() {
        _userRating = rating;
      });
    } else {
      print('Invalid Id: It is null or empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController controller_ = ScrollController();
    final shop = Provider.of<StationaryProdcut>(context);

    final Detailspackage = shop.productData.firstWhere(
      (product) => product['id'].toString() == widget.Id,
      orElse: () => <String, dynamic>{},
    );

    if (Detailspackage.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Product Details'),
        ),
        body: const Center(
          child: Text('Product not found.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: controller_,
              padding: const EdgeInsets.symmetric(horizontal: 4.75),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.75),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: Detailspackage['imagePath'] != null &&
                                Detailspackage['imagePath']
                                    .toString()
                                    .trim()
                                    .isNotEmpty
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                  Detailspackage['imagePath'].toString(),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Detailspackage['description'].toString(),
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Text(
                        Detailspackage['price'].toString(),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: shop.fetchAllRatings(widget.Id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No ratings yet.');
                      }
                      final ratings = snapshot.data!;
                      return Column(
                        children: ratings.map((rating) {
                          String ratingStars = '*' * rating['rating'].round();
                          return ListTile(
                            title: Text('${rating['username']}'),
                            subtitle: Text(
                              '$ratingStars',
                              style:
                                  TextStyle(fontSize: 30, color: Colors.amber),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your Rating:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  RatingBar.builder(
                    initialRating: _userRating ?? 0.0,
                    minRating: 0,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) async {
                      setState(() {
                        _userRating = rating;
                      });
                      //final userId = _sessionController.userId;
                      final username = _sessionController.userName;
                      await shop.updateRating(widget.Id!, rating, username!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Your rating is: $rating')),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding:
            //       const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
            //   child: Row(
            //     children: [
            //       RatingBar.builder(
            //         initialRating: _userRating ?? 0,
            //         minRating: 1,
            //         itemSize: 16,
            //         direction: Axis.horizontal,
            //         allowHalfRating: true,
            //         itemCount: 5,
            //         itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            //         itemBuilder: (context, _) => const Icon(
            //           Icons.star,
            //           color: Colors.amber,
            //         ),
            //         onRatingUpdate: (rating) {
            //           setState(() {
            //             _userRating = rating;
            //           });
            //           shop.updateRating(widget.Id!, rating);
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: widget.Id != null && widget.Id!.isNotEmpty
                        ? shop.fetchComments(widget.Id!)
                        : Stream.value([]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No comments yet.');
                      }
                      final comments = snapshot.data!;
                      return Column(
                        children: comments.map((comment) {
                          return ListTile(
                            title: Text(comment['username']),
                            subtitle: Text(comment['comment']),
                            trailing: Text(comment['timestamp']
                                .toString()), // Display timestamp
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Write a Comment:',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your comment',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (_commentController.text.isNotEmpty) {
                        if (widget.Id != null && widget.Id!.isNotEmpty) {
                          await shop.addComment(
                            widget.Id!,
                            _commentController.text,
                            _sessionController.userName.toString(),
                          );
                          _commentController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Comment submitted!')),
                          );
                        } else {
                          print('Invalid Id: It is null or empty');
                        }
                      }
                    },
                    child: const Text('Submit Comment'),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding:
            //       const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text(
            //         'comment',
            //         style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            //       ),
            //       StreamBuilder<List<Map<String, dynamic>>>(
            //         stream: widget.Id != null && widget.Id!.isNotEmpty
            //             ? shop.fetchComments(widget.Id!)
            //             : Stream.value([]),
            //         builder: (context, snapshot) {
            //           if (snapshot.connectionState == ConnectionState.waiting) {
            //             return const Center(child: CircularProgressIndicator());
            //           }
            //           if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //             return const Text('No comments yet.');
            //           }
            //           final comments = snapshot.data!;
            //           return Column(
            //             children: comments.map((comment) {
            //               return ListTile(
            //                 // leading:
            //                 //     Text(_sessionController.userName.toString()),
            //                 title: Text(comment['username']),
            //                 subtitle: Text(comment['comment']
            //                 //  Text(
            //                 //   comment['timestamp']
            //                 //       .toString(), // Display timestamp
            //                 ),
            //               );
            //             }).toList(),
            //           );
            //         },
            //       ),
            //       const SizedBox(
            //         height: 20,
            //       ),
            //       const Text(
            //         'Write a Comment:',
            //         style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            //       ),
            //       TextField(
            //         controller: _commentController,
            //         decoration: const InputDecoration(
            //           hintText: 'Enter your comment',
            //         ),
            //       ),
            //       const SizedBox(height: 10),
            //       ElevatedButton(
            //         onPressed: () async {
            //           if (_commentController.text.isNotEmpty) {
            //             if (widget.Id != null && widget.Id!.isNotEmpty) {
            //               await shop.addComment(
            //                   widget.Id!, _commentController.text,_sessionController.userName.toString());
            //               _commentController.clear();
            //               ScaffoldMessenger.of(context).showSnackBar(
            //                 const SnackBar(content: Text('Comment submitted!')),
            //               );
            //             } else {
            //               print('Invalid Id: It is null or empty');
            //             }
            //           }
            //         },
            //         child: const Text('Submit Comment'),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
