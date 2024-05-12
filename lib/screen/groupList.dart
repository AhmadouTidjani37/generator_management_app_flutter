import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gge/model/group_model.dart';

class GroupList extends StatefulWidget {
  const GroupList({Key? key});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  late List<GroupModel> allGroups;
   Future<void> deleteUser(String userId) async {
  try {
    await FirebaseFirestore.instance.collection('groups').doc(userId).delete();
    // Supprimer l'utilisateur de la liste
    setState(() {
      allGroups.removeWhere((user) => user.id == userId);
    });
  } catch (e) {
    // Gérer les erreurs éventuelles
    print("Erreur lors de la suppression de l'utilisateur : $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').orderBy('numFlot').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Erreur");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.teal));
          }

          // Effacez la liste actuelle des groupes
          allGroups = [];

          // Remplissez la liste avec les nouveaux groupes à partir du snapshot
          snapshot.data!.docs.forEach((doc) {
            allGroups.add(GroupModel.fromJson(doc.data() as Map<String, dynamic>));
          });

          return ListView.builder(
            itemCount: allGroups.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Card(
                  color: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    title: Text(
                      allGroups[index].numFlot.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ville:"+" " +allGroups[index].ville,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          "Index Energie Début: ${allGroups[index].indexEnergieDebut}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          "Index Energie Finale: ${allGroups[index].indexEnergieFinal}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          "Energie Consommé: ${allGroups[index].energieConso}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    
                       
                      ],
                    ),
                     trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.orange),
                          onPressed: () {
                             deleteUser(allGroups[index].id);
                            // Mettre en œuvre la logique de suppression
                          },
                        ),
                      ],
                  ),
                ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
