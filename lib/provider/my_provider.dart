
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:skardubazar/models/categories_details_model.dart';

import '../models/categories_modle.dart';

class MyProvider extends ChangeNotifier {
  List<CategoriesModle> gesthouseList = [];
  late CategoriesModle gesthouseModle;
  Future<void> getGestHouseCategory() async {
    List<CategoriesModle> newGestHouseList = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .doc('HD8Wq5aCKXQbX3Vs2b3y')
        .collection('GeneralStore')
        .get();
    querySnapshot.docs.forEach((element) {
      gesthouseModle = CategoriesModle(
        image: (element.data() as dynamic)['image'],
        name: (element.data() as dynamic)['name'],
        // image: element.data()['image'],
//name: element.data()['name'],
      );
      newGestHouseList.add(gesthouseModle);
      gesthouseList = newGestHouseList;
    });
    notifyListeners();
  }

  get throwGestHouseList {
    return gesthouseList;
  }

  /////////////////// 2nd category ////////////////
  List<CategoriesModle> hotelList = [];
  late CategoriesModle hotelModle;
  Future<void> getHotelCategory() async {
    List<CategoriesModle> newHotelList = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .doc('HD8Wq5aCKXQbX3Vs2b3y')
        .collection('Pharmacy')
        .get();
    querySnapshot.docs.forEach((element) {
      hotelModle = CategoriesModle(
        image: (element.data() as dynamic)['image'],
        name: (element.data() as dynamic)['name'],
        //name: element.data()['name'],
      );
      newHotelList.add(hotelModle);
      hotelList = newHotelList;
    });
    notifyListeners();
  }

  get throwHotelList {
    return hotelList;
  }

  /////////////// 3nd Category///////////////////////
  List<CategoriesModle> placeList = [];
  late CategoriesModle placeModle;
  Future<void> getGermentCategory() async {
    List<CategoriesModle> newPlaceList = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .doc('HD8Wq5aCKXQbX3Vs2b3y')
        .collection('Garment')
        .get();
    querySnapshot.docs.forEach((element) {
      placeModle = CategoriesModle(
        image: (element.data() as dynamic)['image'],
        name: (element.data() as dynamic)['name'],
        // image: element.data()['image'],
        //  name: element.data()['name'],
      );
      newPlaceList.add(placeModle);
      placeList = newPlaceList;
    });
    notifyListeners();
  }

  get throwPlaceList {
    return placeList;
  }

// /////////////////4th category /////////////
//   List<CategoriesModle> carbookList = [];
//   late CategoriesModle carbookModle;
//   Future<void> getCarBookCategory() async {
//     List<CategoriesModle> newCarBookList = [];
//     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//         .collection('categories')
//         .doc('zlWt2LSAfYtGzoPX5vZ6')
//         .collection('CarBook')
//         .get();
//     querySnapshot.docs.forEach((element) {
//       carbookModle = CategoriesModle(
//         image: (element.data() as dynamic)['image'],
//         name: (element.data() as dynamic)['name'],
//         // image: element.data()['image'],
//         // name: element.data()['name'],
//       );
//       newCarBookList.add(carbookModle);
//       carbookList = newCarBookList;
//     });
//     notifyListeners();
//   }

//   get throwCarBookList {
//     return carbookList;
//   }

  /////////////////////  Single place  Item     //////////////////////////
  // List<PlaceModle> placeModleList = [];
  // late PlaceModle newplaceModle;
  // Future<void> getplaceList() async {
  //   List<PlaceModle> newAllPlaceList = [];
  //   QuerySnapshot querySnapshot =
  //       await FirebaseFirestore.instance.collection('Places').get();
  //   querySnapshot.docs.forEach(
  //     (element) {
  //       newplaceModle = PlaceModle(
  //         image: (element.data() as dynamic)['image'],
  //         name: (element.data() as dynamic)['name'],
  //         number: (element.data() as dynamic)['number'],
  //         address: (element.data() as dynamic)['address'],
  //         description: (element.data() as dynamic)['description'],

  //         // name: element.data()['name'],
  //         // image: element.data()['image'],
  //         // price: element.data()['price'],
  //       );
  //       newAllPlaceList.add(newplaceModle);
  //     },
  //   );

  //   placeModleList = newAllPlaceList;
  //   notifyListeners();
  // }

  // get throwSinglePlaceModleList {
  //   return placeModleList;
  // }

  // ///////////////  Garment categories list//////////
  List<PlaceCategoriesModle> gesthouseCategoriesList = [];
  late PlaceCategoriesModle gesthouseCategoriesModle;
  Future<void> getGarmentCategoriesList() async {
    List<PlaceCategoriesModle> newGestHouseCategoriesList = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CategoriesDetails')
        .doc('eS0z5l1d1hzahH4h5w6j')
        .collection('Garment')
        .get();
    querySnapshot.docs.forEach((element) {
      gesthouseCategoriesModle = PlaceCategoriesModle(
        image: (element.data() as dynamic)['image'],
        name: (element.data() as dynamic)['name'],
        number: (element.data() as dynamic)['number'],
        address: (element.data() as dynamic)['address'],
        description: (element.data() as dynamic)['description'],
        // image: element.data()['image'],
        // name: element.data()['name'],
        // price: element.data()['price'],
      );
      newGestHouseCategoriesList.add(gesthouseCategoriesModle);
      gesthouseCategoriesList = newGestHouseCategoriesList;
    });
  }

  get throwGetsHouseCategoriesList {
    return gesthouseCategoriesList;
  }

  // /////////////// general store categories list//////////
  List<PlaceCategoriesModle> hotelCategoriesList = [];
  late PlaceCategoriesModle hotelCategoriesModle;
  Future<void> generalStoreCategoriesList() async {
    List<PlaceCategoriesModle> newehotelCategoriesList = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CategoriesDetails')
        .doc('eS0z5l1d1hzahH4h5w6j')
        .collection('GeneralStore')
        .get();
    querySnapshot.docs.forEach((element) {
      hotelCategoriesModle = PlaceCategoriesModle(
        image: (element.data() as dynamic)['image'],
        name: (element.data() as dynamic)['name'],
        number: (element.data() as dynamic)['number'],
        address: (element.data() as dynamic)['address'],
        description: (element.data() as dynamic)['description'],
        // image: element.data()['image'],
        // name: element.data()['name'],
        // price: element.data()['price'],
      );
      newehotelCategoriesList.add(hotelCategoriesModle);
      hotelCategoriesList = newehotelCategoriesList;
    });
  }

  get throwHotelCategoriesList {
    return hotelCategoriesList;
  }

  // // ///////////////  phamrcy categories list//////////
  List<PlaceCategoriesModle> vistplaceCategoriesList = [];
  late PlaceCategoriesModle placeCategoriesModle;
  Future<void> pharmacyCategoriesList() async {
    List<PlaceCategoriesModle> newPlaceCategoriesList = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CategoriesDetails')
        .doc('eS0z5l1d1hzahH4h5w6j')
        .collection('Pharmacy')
        .get();
    querySnapshot.docs.forEach((element) {
      placeCategoriesModle = PlaceCategoriesModle(
        image: (element.data() as dynamic)['image'],
        name: (element.data() as dynamic)['name'],
        number: (element.data() as dynamic)['number'],
        address: (element.data() as dynamic)['address'],
        description: (element.data() as dynamic)['description'],
        // image: element.data()['image'],
        // name: element.data()['name'],
        // price: element.data()['price'],
      );
      newPlaceCategoriesList.add(placeCategoriesModle);
      vistplaceCategoriesList = newPlaceCategoriesList;
    });
  }

  get throwPlaceCategoriesList {
    return vistplaceCategoriesList;
  }

  ///////////////  Transport categories list//////////
  // List<PlaceCategoriesModle> transportCategoriesList = [];
  // late PlaceCategoriesModle transportCategoriesModle;
  // Future<void> getTransportCategoriesList() async {
  //   List<PlaceCategoriesModle> newTransportCategoriesList = [];
  //   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('placecategories')
  //       .doc('dZkiFShhMW8NUZNPxIKW')
  //       .collection('CarBook')
  //       .get();
  //   querySnapshot.docs.forEach((element) {
  //     transportCategoriesModle = PlaceCategoriesModle(
  //       image: (element.data() as dynamic)['image'],
  //       name: (element.data() as dynamic)['name'],
  //       number: (element.data() as dynamic)['number'],
  //       address: (element.data() as dynamic)['address'],
  //       description: (element.data() as dynamic)['description'],
  //     );
  //     newTransportCategoriesList.add(transportCategoriesModle);
  //     transportCategoriesList = newTransportCategoriesList;
  //   });
  // }

  // get throwTransportCategoriesList {
  //   return transportCategoriesList;
  // }

/////////////add to cart ////////////

}
