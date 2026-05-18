class UserModel {
  String name;
  String email;
  String password;
  int age;
  double weight;
  double height;
  String goal;

  UserModel({
    this.name = '',
    this.email = '',
    this.password = '',
    this.age = 0,
    this.weight = 0,
    this.height = 0,
    this.goal = '',
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'age': age,
    'weight': weight,
    'height': height,
    'goal': goal,
  };
}
