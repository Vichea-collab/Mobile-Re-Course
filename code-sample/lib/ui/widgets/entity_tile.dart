import 'package:flutter/material.dart';

class EntityTile<T> extends StatelessWidget {
  final T data;
  final String Function(T data) title;
  final String Function(T data) subtitle;

  const EntityTile({
    super.key,
    required this.data,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(title(data)), subtitle: Text(subtitle(data))),
    );
  }
}
