import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:skardubazar/auth/login_screen.dart';
import 'package:skardubazar/provider/newRegistershop.dart';
import 'package:skardubazar/provider/tosellproduct.dart';
import 'package:skardubazar/services/session_manager.dart';
import 'package:skardubazar/utils/flutter_toast.dart';
import 'package:skardubazar/views/New/Garment/garment_shop.dart';
import 'package:skardubazar/views/New/pharmacy/pharmacy_shop.dart';
import 'package:skardubazar/views/New/profile_screen.dart';
import 'package:skardubazar/views/New/profile_update.dart';
import 'package:skardubazar/views/New/stationary/stattinary_shop.dart';
import 'package:skardubazar/widgets/drawer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/category_provider.dart';
import 'Generalstore/shop_generl store.dart';
import 'Topsellprod/productdetails.dart';
import 'homeslider.dart';

// Import your CategoryProvider

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SessionController sessionController = SessionController();

  void _handleLogout(BuildContext context) {
    _auth.signOut().then((value) {
      sessionController.userId = '';
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    }).catchError((error) {
      Utils().toastMessage(error.toString());
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  final TextEditingController _categorySearchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _categorySearchController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    Provider.of<Topsellprod>(context, listen: false).fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('Home')),
        actions: [],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            FutureBuilder<void>(
              future: sessionController
                  .fetchUserInfo(sessionController.userId.toString()),
              builder: (context, AsyncSnapshot<void> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          'Error loading user info',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            child: sessionController.image != null &&
                                    sessionController.image!.isNotEmpty
                                ? CircleAvatar(
                                    radius: 40,
                                    backgroundImage: CachedNetworkImageProvider(
                                        sessionController.image!),
                                  )
                                : const Icon(Icons.person, size: 40),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              sessionController.userName ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  return const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileUpdateScreen(
                              sessionController: sessionController,
                            )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shop),
              title: const Text('Retailer register form'),
              onTap: () {
                _launchURL('https://forms.gle/ZqvokmNSskQS9EWU9');
              },
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Admin'),
              onTap: () {
                _launchURL('https://accounts.google.com/v3/signin/identifier?continue=https%3A%2F%2Fconsole.firebase.google.com%2Fu%2F0%2F&followup=https%3A%2F%2Fconsole.firebase.google.com%2Fu%2F0%2F&ifkv=AdF4I76apArcbGh2RKAy2GAK9pN8fNpMaLl_9SxvYJk-djGEx4S4ChlLu4U1jAyU-tTxgxmhFBBV-w&osid=1&passive=1209600&flowName=GlifWebSignIn&flowEntry=ServiceLogin&dsh=S1241821562%3A1720595427422384&ddm=0');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                final auth = FirebaseAuth.instance;
                auth.signOut().then((value) {
                  SessionController().userId = '';
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                }).onError((error, stackTrace) {
                  Utils().toastMessage(error.toString());
                });
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeader(),
           
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _categorySearchController,
                decoration: InputDecoration(
                  hintText: 'Search categories',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Category',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildCategoryButtons(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Top Sale Product',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<Topsellprod>(
              builder: (context, shopProvider, _) {
                if (shopProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (shopProvider.productData.isEmpty) {
                  return const Center(
                    child: Text('No products available'),
                  );
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: shopProvider.productData.length,
                    itemBuilder: (context, index) {
                      final item = shopProvider.productData[index];
                      return Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetails(
                                        Id: item['id'].toString(),
                                        title: item['name'],
                                      ),
                                    ));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.network(
                                  item['imagePath'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['name'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

 List<Widget> _buildCategoryButtons() {
    final categories = [
      {'name': 'Pharmacy', 'imageUrl': 'assets/images/pharmcy.jpeg', 'destination': Pharmacyshop()},
      {'name': 'General Store', 'imageUrl': 'assets/images/generlstore.jpg', 'destination': Generlstoreshop()},
      {'name': 'Garments', 'imageUrl': 'assets/images/garment.jpg', 'destination': Garmetnshop()},
      {'name': 'Stationery', 'imageUrl': 'assets/images/stationary.jpg', 'destination': Stationaryshop()},
    ];

    return categories
        .where((category) => (category['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
        .map((category) => _buildCategoryButton(context, category['name'] as String, category['imageUrl'] as String, category['destination'] as Widget))
        .toList();
  }
  Widget _buildCategoryButton(BuildContext context, String name, String imageUrl, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(imageUrl),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// SingleChildScrollView(
//         child: Column(
//           children: [
//             HomeHeader(),
//             // Text(sessionController.userEmail!),
//             // Text(sessionController.userName!),
//             Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               //controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search products',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(25.0),
//                 ),
//               ),
//             ),
//           ),
//             const Padding(
//               padding: EdgeInsets.only(top: 20, left: 20),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Category',
//                   style: TextStyle(fontSize: 20),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildCategoryButton(context, 'Pharmacy',
//                       'assets/images/pharmcy.jpeg', Pharmacyshop()),
//                   _buildCategoryButton(context, 'General Store',
//                       'assets/images/generlstore.jpg', Generlstoreshop()),
//                   _buildCategoryButton(context, 'Garments',
//                       'assets/images/garment.jpg', Garmetnshop()),
//                   _buildCategoryButton(context, 'Stationery',
//                       'assets/images/stationary.jpg', Stationaryshop()),
//                 ],
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.only(top: 20, left: 20),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Top Sale Product',
//                   style: TextStyle(fontSize: 20),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Consumer<Topsellprod>(
//               builder: (context, shopProvider, _) {
//                 if (shopProvider.isLoading) {
//                   return const Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 } else if (shopProvider.productData.isEmpty) {
//                   return const Center(
//                     child: Text('No products available'),
//                   );
//                 } else {
//                   return GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 0.75,
//                     ),
//                     itemCount: shopProvider.productData.length,
//                     itemBuilder: (context, index) {
//                       final item = shopProvider.productData[index];
//                       return Card(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => ProductDetails(
//                                         Id: item['id'].toString(),
//                                         title: item['name'],
//                                       ),
//                                     ));
//                               },
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(5),
//                                 child: Image.network(
//                                   item['imagePath'],
//                                   width: 100,
//                                   height: 100,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               item['name'],
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                             // Row(
//                             //   mainAxisAlignment: MainAxisAlignment.center,
//                             //   children: [
//                             //     Icon(
//                             //       Icons.star,
//                             //       color: Colors.amber,
//                             //     ),
//                             //     SizedBox(width: 10),
//                             //     Text(
//                             //       item['rating'].toString(),
//                             //       style: const TextStyle(fontSize: 16),
//                             //     ),
//                             //   ],
//                             // )
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryButton(
//       BuildContext context, String name, String imageUrl, Widget destination) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => destination),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: AssetImage(imageUrl),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               name,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
