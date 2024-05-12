class UserModel{
  String name;
  String email;
  String poste;
  String password;

  UserModel({
    required this.name,
    required this.email,
    required this.poste,
    this.password='',
  });

  Map<String, dynamic>toJson(){
    return {
      'name':name,
      'email':email,
      'poste':poste,
      'password':password,
    };
  } 

  factory UserModel.fromJson( Map<String, dynamic>json){
    return UserModel(
      name: json['name'],
       email: json['email'],
        poste: json['poste'],
     

        );
    
  }
}