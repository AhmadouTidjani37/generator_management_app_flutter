import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gge/model/model.dart';

class ListAgent extends StatefulWidget {
  const ListAgent({super.key});

  @override
  State<ListAgent> createState() => _ListAgentState();
}

class _ListAgentState extends State<ListAgent> {
    List<UserModel> allUsers = [];
    final _ctrupdatename = TextEditingController();
    final _ctrupdateposte = TextEditingController();
    Future<void> deleteUser(String userId) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    // Supprimer l'utilisateur de la liste
    setState(() {
      allUsers.removeWhere((user) => user.email == userId);
    });
  } catch (e) {
    // Gérer les erreurs éventuelles
    print("Erreur lors de la suppression de l'utilisateur : $e");
  }
}

Future<void> updateUser(UserModel userModel) async {
  try {
    final docUser = FirebaseFirestore.instance.collection('users').doc(userModel.email);
    await docUser.update(userModel.toJson());
  } catch (e) {
    // Gérer les erreurs éventuelles
    print("Erreur lors de la mise à jour de l'utilisateur : $e");
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance.collection('users').orderBy('name').snapshots(),
        builder: (context, snp){
          if(snp.hasError){
            return Text("Erreur");
          }
          if(snp.hasData){
           allUsers = snp.data!.docs

           .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>)).toList();

           return ListView.builder(
            itemCount: allUsers.length,
            itemBuilder:((context, index){
              return Padding(
                padding:EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Card(
                  color: Colors.teal,
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                   title: Text(allUsers[index].name.toUpperCase(),style: TextStyle(
                     fontWeight: FontWeight.bold,
                     color: Colors.white,
                     fontSize: 18,
                   ),),
                   subtitle: Text(allUsers[index].poste,style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                   ),),
                   trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: (){
                         showDialog(context: context, 
                         builder: (context)=>AlertDialog(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          title: Text("Mise à jour: ${allUsers[index].name}"),

                          content: SingleChildScrollView(
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                               children: [
                                TextField(
                                  controller: _ctrupdatename,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color:Colors.teal,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Nom",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    ),
                                    
                                  ),
                                  SizedBox(height: 20,),
                                   TextField(
                                    controller: _ctrupdateposte,
                                  style: TextStyle(
                                    fontSize: 22,
                                    color:Colors.teal,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Poste",
                                     border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    ),
                                    
                                  ),
                                   SizedBox(height: 20,),
                                ElevatedButton(
                                  onPressed: () {
                                    final user = UserModel(
                                      name: _ctrupdatename.text, 
                                      email: allUsers[index].email, 
                                      poste: _ctrupdateposte.text
                                    );
                                    updateUser(user);
                                  }, 
                                  child: Text("Enregistrer"),
                                ),

                               ],
                              ),
                            ),
                          ),
                             actions: [
                             ElevatedButton(
                                    onPressed:(){
                                       Navigator.pop(context, 'Annuler');
                                    } , child: Text("Annuler"),
                                    ),
                             ],
                         ));
                        }, 
                        child: Icon(Icons.edit,color: Colors.white,)),
                                                      TextButton(
                                onPressed: () {
                                  deleteUser(allUsers[index].email);
                                },
                                child: Icon(Icons.delete, color: Colors.orange),
                              ),

                    ],
                   ),
                  ),
                ),
              );
            })
            
            );
          }
          else{
            return Center(child: CircularProgressIndicator(
              color: Colors.teal,
            ));
          }
        },
      ),
    );
  }
}