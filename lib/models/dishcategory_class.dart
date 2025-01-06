import 'package:restaurants/models/dish_class.dart';

class DishCategoryDto {
  final int dishCategoryID;
  final String categoryName;
  final List<DishDto>? dishes;

  DishCategoryDto({required this.dishCategoryID,required this.categoryName, required this.dishes});

  factory DishCategoryDto.fromJson(Map<String, dynamic> json) {
    return DishCategoryDto(
      dishCategoryID:json['dishCategoryID'],
      categoryName: json['name'],
      dishes: (json['dishes'] as List)
          .map((dishJson) => DishDto.fromJson(dishJson))
          .toList(),
    );
  }
}