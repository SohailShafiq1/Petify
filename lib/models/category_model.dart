class CategoryModel {
  final String id;
  final String name;
  final String icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  static List<CategoryModel> getDummyCategories() {
    return [
      CategoryModel(id: '1', name: 'Dogs', icon: '🐕'),
      CategoryModel(id: '2', name: 'Cats', icon: '🐈'),
      CategoryModel(id: '3', name: 'Birds', icon: '🦜'),
      CategoryModel(id: '4', name: 'Fish', icon: '🐠'),
      CategoryModel(id: '5', name: 'Rabbits', icon: '🐰'),
      CategoryModel(id: '6', name: 'Hamsters', icon: '🐹'),
    ];
  }
}
