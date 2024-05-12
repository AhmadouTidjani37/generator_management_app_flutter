import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gge/screen/auth/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gge/screen/liste_agent.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController posteController = TextEditingController();
  bool _isLoading = false;
  Future<void> _signUpWithEmailAndPassword(
  String name, String email, String password, String poste) async {
  try {
    bool isEmailRegistered = await _checkIfEmailRegistered(email);
          
    if (isEmailRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Vous avez déjà un compte. Veuillez vous connecter.'),
        ),
      );
      return;
    }

    UserCredential authResult = await _auth.createUserWithEmailAndPassword(
      email: email, password: password);

    String userId = authResult.user!.uid;

    await _firestore.collection('users').doc(userId).set({
     
      'email': email,
      'name': name,
      'poste': poste, 
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ListAgent()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Erreur lors de la création du compte. Veuillez réessayer.'),
      ),
    );
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
  Future<bool> _checkIfEmailRegistered(String email) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                 image: DecorationImage(
                  image: AssetImage("assets/images/bg.png"),
                  fit: BoxFit.cover,
                 ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
              SizedBox(
                height: 12,
              ),
              Container(
                padding: EdgeInsets.only(left: 15),
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 0.8,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Nom",
                    hintStyle: TextStyle(
                      fontFamily: "Times New Roman",
                      color:Colors.white,
                    ),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.only(left: 15),
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 0.8,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Matricule",
                    hintStyle: TextStyle(
                      fontFamily: "Times New Roman",
                     color: Colors.white,
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30,),
               Container(
                padding: EdgeInsets.only(left: 15),
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 0.8,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: posteController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Poste",
                    hintStyle: TextStyle(
                      fontFamily: "Times New Roman",
                     color: Colors.white,
                    ),
                    prefixIcon: Icon(
                      Icons.work,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.only(left: 15),
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 0.8,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Mot de passe",
                    hintStyle: TextStyle(
                      fontFamily: "Times New Roman",
                      color: Colors.white,
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                padding: EdgeInsets.only(top: 6),
                width: MediaQuery.of(context).size.width,
                height: 60,
                decoration: BoxDecoration(
                color: Colors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () async {
                                    String name = nameController.text;
                    String email = emailController.text + '@gmail.com';
                    String poste = posteController.text; // Récupérer la valeur de poste
                    String password = passwordController.text;

                    try {
                      setState(() {
                        _isLoading = true;
                      });
                      await _signUpWithEmailAndPassword(name, email, password, poste); 
                    } catch (e) {
                 
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
},
                  child: _isLoading
                      ? Column(
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ],
                        )
                      : Center(
                          child: Text('Ajouter un Agent',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              )),
                        ),
                ),
              ),
              SizedBox(
                height: 30,
              ),

                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(top: 15),
        width: MediaQuery.of(context).size.width,
        height: 50,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          ),
        ),
        child: Text("SODECOTON | 2024",textAlign: TextAlign.center,style: TextStyle(
        color: Colors.white,
        ),),
      ),
    );
  }
}
