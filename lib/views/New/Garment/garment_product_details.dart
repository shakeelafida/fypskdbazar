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

// //3
class GarmentProductDetails extends StatefulWidget {
  final String? Id;
  final String? title;
  final String? imagePath;

  GarmentProductDetails({
    Key? key,
    this.title,
    this.imagePath,
    this.Id,
  }) : super(key: key);

  @override
  State<GarmentProductDetails> createState() => _GarmentProductDetailsState();
}

class _GarmentProductDetailsState extends State<GarmentProductDetails> {
  double? _userRating;
  final TextEditingController _commentController = TextEditingController();
  final SessionController _sessionController = SessionController();

  @override
  void initState() {
    super.initState();
    final shop = Provider.of<GarmentProdcut>(context, listen: false);
    if (shop.productData.isEmpty) {
      shop.fetchData();
    }
    _loadRating();
  }

  Future<void> _loadRating() async {
    final shop = Provider.of<GarmentProdcut>(context, listen: false);
    final rating = await shop.fetchAverageRating(widget.Id!);
    setState(() {
      _userRating = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController controller_ = ScrollController();
    final shop = Provider.of<GarmentProdcut>(context);

    final Detailspackage = shop.productData.firstWhere(
      (product) => product['id'].toString() == widget.Id,
      orElse: () => <String, dynamic>{},
    );

    if (Detailspackage.isEmpty) {
      return Scaffold(
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
            // Image and Description Section
            _buildImageSection(Detailspackage),
            _buildDescriptionSection(Detailspackage),
            _buildPriceSection(Detailspackage),
            _buildRatingSection(shop),
            _buildCommentSection(shop),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Map<String, dynamic> product) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
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
                image: product['imagePath'] != null &&
                        product['imagePath'].toString().trim().isNotEmpty
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                          product['imagePath'].toString(),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
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
                  product['description'].toString(),
                  style: const TextStyle(fontSize: 15),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
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
                product['price'].toString(),
                style: const TextStyle(fontSize: 15),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(GarmentProdcut shop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
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
                      style: TextStyle(fontSize: 30, color: Colors.amber),
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
    );
  }
//2
  // Widget _buildRatingSection(GarmentProdcut shop) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Rating:',
  //           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
  //         ),
  //         StreamBuilder<List<Map<String, dynamic>>>(
  //           stream: shop.fetchAllRatings(widget.Id!),
  //           builder: (context, snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return const Center(child: CircularProgressIndicator());
  //             }
  //             if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //               return const Text('No ratings yet.');
  //             }
  //             final ratings = snapshot.data!;
  //             return Column(
  //               children: ratings.map((rating) {
  //                 return ListTile(
  //                   title: Text('User: ${rating['userId']}'),
  //                   subtitle: Text('Rating: ${rating['rating']}'),
  //                 );
  //               }).toList(),
  //             );
  //           },
  //         ),
  //         const SizedBox(height: 20),
  //         const Text(
  //           'Your Rating:',
  //           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
  //         ),
  //         RatingBar.builder(
  //           initialRating: _userRating ?? 0.0,
  //           minRating: 0,
  //           direction: Axis.horizontal,
  //           allowHalfRating: true,
  //           itemCount: 5,
  //           itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
  //           itemBuilder: (context, _) => const Icon(
  //             Icons.star,
  //             color: Colors.amber,
  //           ),
  //           onRatingUpdate: (rating) async {
  //             setState(() {
  //               _userRating = rating;
  //             });
  //             final userId = _sessionController.userId;
  //             await shop.updateRating(widget.Id!, userId!, rating);
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text('Your rating is: $rating')),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //1
  // Widget _buildRatingSection(GarmentProdcut shop) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Rating:',
  //           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
  //         ),
  //         StreamBuilder<List<Map<String, dynamic>>>(
  //           stream: shop.fetchAllRatings(widget.Id!),
  //           builder: (context, snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return const Center(child: CircularProgressIndicator());
  //             }
  //             if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //               return const Text('No ratings yet.');
  //             }
  //             final ratings = snapshot.data!;
  //             return Column(
  //               children: ratings.map((rating) {
  //                 return ListTile(
  //                   title: Text('User: ${rating['userId']}'),
  //                   subtitle: Text('Rating: ${rating['rating']}'),
  //                 );
  //               }).toList(),
  //             );
  //           },
  //         ),
  //         const SizedBox(height: 20),
  //         const Text(
  //           'Your Rating:',
  //           style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
  //         ),
  //         Slider(
  //           value: _userRating ?? 0.0,
  //           min: 0.0,
  //           max: 5.0,
  //           divisions: 5,
  //           label: _userRating?.toString() ?? '0.0',
  //           onChanged: (value) {
  //             setState(() {
  //               _userRating = value;
  //             });
  //           },
  //           onChangeEnd: (value) async {
  //             final userId = _sessionController.userId;
  //             await shop.updateRating(widget.Id!, userId!, value);
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text('Your rating is: $value')),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCommentSection(GarmentProdcut shop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments:',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: shop.fetchComments(widget.Id!),
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
                    trailing: Text(comment['timestamp'].toString()),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
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
                final userId = _sessionController.userId;
                final username = _sessionController.userName;
                await shop.addComment(
                  widget.Id!,
                  _commentController.text,
                  username!,
                );
                _commentController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment submitted!')),
                );
              }
            },
            child: const Text('Submit Comment'),
          ),
        ],
      ),
    );
  }
}
// class GarmentProductDetails extends StatefulWidget {
//   final String? Id;
//   final String? title;
//   final String? imagePath;

//   GarmentProductDetails({
//     Key? key,
//     this.title,
//     this.imagePath,
//     this.Id,
//   }) : super(key: key);

//   @override
//   State<GarmentProductDetails> createState() => _GarmentProductDetailsState();
// }

// class _GarmentProductDetailsState extends State<GarmentProductDetails> {
//   double? _userRating;
//   final TextEditingController _commentController = TextEditingController();
//   final SessionController _sessionController = SessionController();
//   @override
//   void initState() {
//     super.initState();
//     final shop = Provider.of<GarmentProdcut>(context, listen: false);
//     if (shop.productData.isEmpty) {
//       shop.fetchData();
//     }
//     _loadRating();
//   }

//   Future<void> _loadRating() async {
//     final shop = Provider.of<GarmentProdcut>(context, listen: false);
//     final rating = await shop.fetchAverageRating(widget.Id!);
//     setState(() {
//       _userRating = rating;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ScrollController controller_ = ScrollController();
//     final shop = Provider.of<GarmentProdcut>(context);

//     final Detailspackage = shop.productData.firstWhere(
//       (product) => product['id'].toString() == widget.Id,
//       orElse: () => <String, dynamic>{},
//     );

//     if (Detailspackage.isEmpty) {
//       return Scaffold(
//         // appBar: AppBar(
//         //   title: Text(widget.title ?? 'Product Details'),
//         // ),
//         body: const Center(
//           child: Text('Product not found.'),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title ?? 'Product Details'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               controller: controller_,
//               padding: const EdgeInsets.symmetric(horizontal: 4.75),
//               child: Row(
//                 children: <Widget>[
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 4.75),
//                     child: Container(
//                       width: 200,
//                       height: 200,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         image: Detailspackage['imagePath'] != null &&
//                                 Detailspackage['imagePath']
//                                     .toString()
//                                     .trim()
//                                     .isNotEmpty
//                             ? DecorationImage(
//                                 fit: BoxFit.cover,
//                                 image: CachedNetworkImageProvider(
//                                   Detailspackage['imagePath'].toString(),
//                                 ),
//                               )
//                             : null,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Description:',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           Detailspackage['description'].toString(),
//                           style: const TextStyle(
//                             fontSize: 15,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Price',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   ),
//                   Row(
//                     children: [
//                       Text(
//                         Detailspackage['price'].toString(),
//                         style: const TextStyle(
//                           fontSize: 15,
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'rating',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 10.252, vertical: 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'comment',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   ),
//                   StreamBuilder<List<Map<String, dynamic>>>(
//                     stream: shop.fetchComments(widget.Id!),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                         return const Text('No comments yet.');
//                       }
//                       final comments = snapshot.data!;
//                       return Column(
//                         children: comments.map((comment) {
//                           return ListTile(
//                             title: Text(comment['username']),
//                             subtitle: Text(comment['comment']),
//                             trailing: Text(comment['timestamp'].toString()),
//                           );
//                         }).toList(),
//                       );
//                     },
//                   ),
//                   const SizedBox(
//                     height: 20,
//                   ),
//                   const Text(
//                     'Write a Comment:',
//                     style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                   ),
//                   TextField(
//                     controller: _commentController,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter your comment',
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (_commentController.text.isNotEmpty) {
//                         await shop.addComment(
//                           widget.Id!,
//                           _commentController.text,
//                           _sessionController.userName.toString(),
//                         );
//                         _commentController.clear();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Comment submitted!')),
//                         );
//                       }
//                     },
//                     child: const Text('Submit Comment'),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
