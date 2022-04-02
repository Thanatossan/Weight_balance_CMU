import 'dart:ffi';

final String tableUser = 'user';

class UserFields {
  static final List<String> values = [
    /// Add all fields
    id, name, surname , gender, age ,createAt
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String surname = 'surname';
  static final String gender = 'gender';
  static final String age = 'age';
  static final String createAt = 'createAt';
}

class User {
  final int? id;
  final String name;
  final String surname;
  final String gender;
  final int age;
  final DateTime createAt;

  const User({
    this.id,
    required this.name,
    required this.surname,
    required this.gender,
    required this.age,
    required this.createAt,

  });

  User copy({
    int? id,
    String? name,
    String? surname,
    String? gender,
    int? age,
    DateTime? createAt,

  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        surname: surname ?? this.surname,
        gender : gender ?? this.gender,
        age: age?? this.age,
        createAt: createAt ?? this.createAt,

      );

  static User fromJson(Map<String, Object?> json) => User(
    id: json[UserFields.id] as int?,
    name: json[UserFields.name] as String,
    surname: json[UserFields.surname] as String,
    gender: json[UserFields.gender] as String,
    age: json[UserFields.age] as int,
    createAt: DateTime.parse(json[UserFields.createAt] as String),

  );

  Map<String, Object?> toJson() => {
    UserFields.id: id,
    UserFields.name: name,
    UserFields.surname: surname,
    UserFields.gender : gender,
    UserFields.age : age,
    UserFields.createAt: createAt.toIso8601String(),

  };
}
