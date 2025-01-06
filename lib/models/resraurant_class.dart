import 'package:restaurants/models/branch_class.dart';
import 'package:restaurants/models/dishcategory_class.dart';

class Restaurant{
  final int  restaurantID;
  final String restaurantName;
  final String? imageFilePath;
  final List<DishCategoryDto>? dishCategories;
  final List<BranchDto>? branches; 

   Restaurant({
    required this.restaurantID,
    required this.restaurantName,
    this.imageFilePath,
     this.dishCategories, 
     this.branches, 
  });

 factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantID: json['restaurantID'],
      restaurantName: json['restaurantName'],
      imageFilePath: json['imageUrl'],
      dishCategories: (json['dishCategories'] as List?)
          ?.map((categoryJson) => DishCategoryDto.fromJson(categoryJson))
          .toList() ?? [], 
      branches: (json['branches'] as List?)
          ?.map((branchJson) => BranchDto.fromJson(branchJson))
          .toList() ?? [], 
    );
  }

// void logDetails() {
//     log('Restaurant ID: $restaurantID');
//     log('Restaurant Name: $restaurantName');
//     log('Image File Path: $imageFilePath');

//     log('Dish Categories:');
//     for (final category in dishCategories!) {
//       log('  Category ID: ${category.dishCategoryID}');
//       log('  Category Name: ${category.categoryName}');
//       log('  Dishes:');
//       for (final dish in category.dishes!) {
//       //  log('    dish ID: ${dish.dishID}');
//         log('    Dish Name: ${dish.dishName}');
//         log('    Dish Image URL: ${dish.dishImageUrl}');
//         log('    Price: ${dish.price}');
//         log('    Details: ${dish.details}');
//       }
//       log('-----');
//     }

//     log('Branches:');
//     for (final branch in branches!) {
//       log('  Branch ID: ${branch.branchID}');
//       log('  Location Description: ${branch.locationDescription}');
//       log('  Branch Image URL: ${branch.branchImageUrl}');
//       log('  Phone Number: ${branch.phoneNumber}');
//       log('  Open Time: ${branch.openTime}');
//       log('  Close Time: ${branch.closeTime}');
//       log('  Has Indoor Seating: ${branch.hasIndoorSeating}');
//       log('  Has Outdoor Seating: ${branch.hasOutdoorSeating}');
//       log('  Number of Tables: ${branch.numOfTables}');
//       log('-----');
//     }

//     log('\n');
//   }
}