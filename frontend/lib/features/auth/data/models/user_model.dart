class UserModel {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? password;
  final String? location;
  final String? photo;
  final List<String?>? favorites;
  final String? token;


  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.password,
    this.location,
    this.photo,
    this.favorites,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      password: json['password'] ?? '',
      location: json['location'] ?? '',
      photo: json['photo'] ?? '',
      favorites: json['favorites'] != null
          ? List<String?>.from(json['favorites'].map((x) => x))
          : [], 
      token: json['token']?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'location': location,
      'photo': photo,
      'favorites': favorites != null
          ? List<dynamic>.from(favorites!.map((x) => x))
          : [],
      'token': token,
    };
  }
}
