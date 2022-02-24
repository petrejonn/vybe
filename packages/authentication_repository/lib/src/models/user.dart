import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    this.displayName,
  });

  final String id;
  final String? displayName;

  @override
  List<Object?> get props => [id, displayName];

  static const empty = User(id: '');

  bool get isEmpty => this == User.empty;

  bool get isNotEmpty => this != User.empty;
}
