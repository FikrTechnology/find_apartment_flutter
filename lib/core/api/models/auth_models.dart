class RegisterRequest {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String password;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'password': password,
    };
  }
}

class RegisterResponse {
  final Meta meta;
  final RegisterData data;

  RegisterResponse({
    required this.meta,
    required this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      meta: Meta.fromJson(json['meta']),
      data: RegisterData.fromJson(json['data']),
    );
  }
}

class RegisterData {
  final User user;
  final String accessToken;
  final String tokenType;

  RegisterData({
    required this.user,
    required this.accessToken,
    required this.tokenType,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      user: User.fromJson(json['user']),
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Meta {
  final int code;
  final String status;
  final String message;

  Meta({
    required this.code,
    required this.status,
    required this.message,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      code: json['code'],
      status: json['status'],
      message: json['message'],
    );
  }
}
