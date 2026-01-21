import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String thumbUrl;
  final String description;

  const Category({
    required this.id,
    required this.name,
    required this.thumbUrl,
    required this.description,
  });

  @override
  List<Object> get props => [id, name, thumbUrl, description];
}

class Area extends Equatable {
  final String name;

  const Area({required this.name});

  @override
  List<Object> get props => [name];
}
