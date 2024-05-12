import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgentHome extends StatefulWidget {
  const AgentHome({super.key});

  @override
  State<AgentHome> createState() => _AgentHomeState();
}

class _AgentHomeState extends State<AgentHome> {

  final idConttroller = TextEditingController();
  final numFlotConttroller = TextEditingController();
  final villeConttroller = TextEditingController();
  final indexEnergieDebutConttroller = TextEditingController();
  final indexEnergieFinalConttroller = TextEditingController();
  final energieConsoConttroller = TextEditingController();

Future<void> saveGroupData() async {
  try {
    // Récupérer les valeurs des champs de texte
    String id = idConttroller.text;
    String numFlot = numFlotConttroller.text;
    int indexEnergieDebut = int.parse(indexEnergieDebutConttroller.text);
    int indexEnergieFinal = int.parse(indexEnergieFinalConttroller.text);
    int energieConso = int.parse(energieConsoConttroller.text);

    // Enregistrer les données dans Firestore
    await FirebaseFirestore.instance.collection('groups').add({
      'id': id,
      'numFlot': numFlot,
      'indexEnergieDebut': indexEnergieDebut,
      'indexEnergieFinal': indexEnergieFinal,
      'energieConso': energieConso,
    });

    // Réinitialiser les champs de texte après l'enregistrement
    idConttroller.clear();
    numFlotConttroller.clear();
    indexEnergieDebutConttroller.clear();
    indexEnergieFinalConttroller.clear();
    energieConsoConttroller.clear();

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Les informations du groupe ont été enregistrées avec succès.'),
      ),
    );
  } catch (e) {
    // Gérer les erreurs éventuelles
    print('Erreur lors de l\'enregistrement des informations du groupe : $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur lors de l\'enregistrement. Veuillez réessayer.'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 30,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
           TextField(
           controller: idConttroller,
      style: TextStyle(
        fontSize: 22,
        color:Colors.teal,
      ),
      decoration: InputDecoration(
        labelText: "id",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        ),
        
      ),
        SizedBox(height: 20,),
        TextField(
         controller: numFlotConttroller,
      style: TextStyle(
        fontSize: 22,
        color:Colors.teal,
      ),
      decoration: InputDecoration(
        labelText: "Numéro de Flot",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        ),
        
      ),
      SizedBox(height: 20,),
       TextField(
       controller: indexEnergieDebutConttroller,
      style: TextStyle(
        fontSize: 22,
        color:Colors.teal,
      ),
      decoration: InputDecoration(
        labelText: "Index Energie Début",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        ),
        
      ),
       SizedBox(height: 20,),
       TextField(
       controller: villeConttroller,
      style: TextStyle(
        fontSize: 22,
        color:Colors.teal,
      ),
      decoration: InputDecoration(
        labelText: "Ville",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        ),
        
      ),
       SizedBox(height: 20,),
       TextField(
       controller: indexEnergieFinalConttroller,
      style: TextStyle(
        fontSize: 22,
        color:Colors.teal,
      ),
      decoration: InputDecoration(
        labelText: "Index Energie Final",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        ),
        
      ),
       SizedBox(height: 20,),
       TextField(
       controller: energieConsoConttroller,
      style: TextStyle(
        fontSize: 22,
        color:Colors.teal,
      ),
      decoration: InputDecoration(
        labelText: "Energie Consommé",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        ),
        
      ),
       SizedBox(height: 20,),
          ElevatedButton(
        onPressed: saveGroupData,
        child: Text("Enregistrer"),
      ),

          ],
        ),
       ),
    );
  }
}