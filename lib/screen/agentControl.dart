import 'dart:io' as io;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gge/screen/agentHome.dart';
import 'package:gge/screen/auth/signup.dart';
import 'package:gge/screen/groupList.dart';
import 'package:gge/screen/liste_agent.dart';
import 'package:gge/screen/propos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gge/screen/auth/signin.dart';
import 'package:gge/screen/image_to_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:gge/apiServices/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class AgentControl extends StatefulWidget {
  const AgentControl({Key? key}) : super(key: key);
  @override
  State<AgentControl> createState() => _AgentControlState();
}

class _AgentControlState extends State<AgentControl> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _advancedDrawerController = AdvancedDrawerController();
  TextEditingController textController = TextEditingController();
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  String result = "";
  late OpenAIService openAIService;
  String? generatedContent;
  String? generatedImageUrl;
  bool isProcessing = false;
  int start = 200;
  int delay = 200;
  bool isAudioEnabled = false;
   List<String> searchHistory = [];
   bool showSearchHistory = false;
  @override
  void initState() {
    super.initState();
    openAIService = OpenAIService();
    initSpeechToText();
    initTextToSpeech();
    checkConnectivity();
    imagePicker = ImagePicker();
    loadSearchHistory();
    fetchUserData().then((_) {
    });
    
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion à DJANI AI'),
        ),
      );
    }
  }
  
  Future<void> processQuestion(String question) async {
  setState(() {
    generatedImageUrl = null;
    generatedContent = 'Réponse en cours...';
    textController.clear();
    isProcessing = true;
  });

  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    // Handle no internet connection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erreur de connexion à DJANI AI'),
      ),
    );
    if (question.isNotEmpty) {
    updateUserSearchHistory(question);
  }
  }

  if (question.toLowerCase().contains("comment tu t'appelle ?") ||
      question.toLowerCase().contains("quel est ton nom ?")||question.toLowerCase().contains("Quel est ton nom ?")
      ||question.toLowerCase().contains("Quel est ton nom")||question.toLowerCase().contains("Comment tu t'appelle ?")
      ||question.toLowerCase().contains("Comment tu t'appelle")) {
    // Response specufique
    final nameResponse =
        "Je suis DJANI AI, une des meilleures créations de Monsieur Ahmadou Tidjani.";
    
    setState(() {
      generatedImageUrl = null;
      generatedContent = nameResponse;
      isProcessing = false;
    });

    await systemSpeak(nameResponse);
  } else {
    final speech = await openAIService.chatGPTAPI(question);

    setState(() {
        generatedImageUrl = null;
        generatedContent = speech;
        isProcessing = false;
    });

    if (isProcessing) {
      await systemSpeak(speech);
    }
  }
}

  void copyToClipboard() {
    if (generatedContent != null) {
      Clipboard.setData(ClipboardData(text: generatedContent!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Résultat copié')),
      );
    }
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
  }

  Future<void> stopListening() async {
    await speechToText.stop();
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  Future<void> _signOut() async {
    try {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Déconnexion"),
            content: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Annuler"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the dialog
                  await _auth.signOut();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setBool('isLoggedIn', false);
                  prefs.remove('email');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                child: Text("Confirmer"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Erreur de déconnexion: $e");
    }
  }

 late String userName = 'Admin';
late String userEmail = 'Admin';

Future<void> fetchUserData() async {
  try {
    var userId = _auth.currentUser?.uid;
    if (userId != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userData.exists) {
        setState(() {
          userName = userData.get('name') ?? 'Admin';
          userEmail = userData.get('email') ?? 'Admin';
        });
      }
    } else {
      setState(() {
        userName = '';
        userEmail = '';
      });
    }
  } catch (e) {
    print("Error fetching user data: $e");
  }
}


 Future<void> generatePdf(String content) async {
  bool confirmed = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirmation"),
        content: Text("Êtes-vous sûr de vouloir enregistrer le fichier dans le dossier 'DJANI AI'?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text("Confirmer"),
          ),
        ],
      );
    },
  );

  if (confirmed) {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (context) {
        return pw.Center(
          child: pw.Text(content),
        );
      },
    ));

    final dir = await getApplicationDocumentsDirectory();
    final folder = io.Directory('${dir.path}/DJANI AI');
    await folder.create(recursive: true);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = io.File('${folder.path}/resultat_assis_$timestamp.pdf');
    await path.writeAsBytes(await pdf.save());

  }
}

late File image;
late ImagePicker imagePicker;

pickImageFromGallery() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );

  if (result != null) {
    image = File(result.files.single.path!);
    setState(() {});
    performImageLabeling();
  }
}


  performImageLabeling() async {
    final inputImage = InputImage.fromFile(image);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText =
          await textDetector.processImage(inputImage);

      result = recognizedText.text;
      textController.text = result;
    } catch (e) {
      print("Error during text recognition: $e");
    } finally {
      textDetector.close();
    }

    setState(() {});
  }

Future<void> updateUserSearchHistory(String question) async {
  try {
    var userId = _auth.currentUser?.uid;
    if (userId != null) {
      var userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      var userData = await userRef.get();
      List<String>? existingHistory = userData.get('searchHistory')?.cast<String>();
      if (existingHistory == null) {
        existingHistory = [question];
      } else {
        existingHistory.add(question);
      }
      await userRef.update({'searchHistory': existingHistory});
    }
  } catch (e) {
    print("Error updating search history: $e");
  }
}
Future<void> loadSearchHistory() async {
  try {
    var userId = _auth.currentUser?.uid;
    if (userId != null) {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      List<String>? history = userData.get('searchHistory')?.cast<String>();

      if (history != null) {
        setState(() {
          searchHistory = List.from(history.reversed);
        });
      }
    }
  } catch (e) {
    print("Error loading search history: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.cover,
                  ),
        ),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      // openScale: 1.0,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        // NOTICE: Uncomment if you want to add shadow behind the page.
        // Keep in mind that it may cause animation jerks.
        // boxShadow: <BoxShadow>[
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 0.0,
        //   ),
        // ],
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white,
            size:30,
          ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
               image: DecorationImage(
                      image: AssetImage("assets/images/bg.png"),
                      fit: BoxFit.cover,
                    ),
              ),
            ),
            title: Text(
              "GGE Agent Page",
              style: TextStyle(
                fontFamily: "Times New Roman",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
          ),
              ),
            centerTitle: true,
          
           bottom: TabBar(
            labelStyle: TextStyle(
              color: const Color.fromARGB(255, 40, 231, 46),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            indicatorColor: Color.fromARGB(255, 40, 231, 46),
            indicatorWeight: 5,
            unselectedLabelStyle: TextStyle(
              color: Colors.white,
            ),
            tabs: [
              Tab(
                icon: Icon(Icons.edit),
                text: "Relever",
              ),
               Tab(
                icon: Icon(Icons.list),
                text: "Mes Enregistrements",
              ),
            ],
           ),
            leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert,size: 30,),
              onPressed: (){

              },
              ),
          ],
        ),
          body:TabBarView(
            children: [
             AgentHome(),
            GroupList(),
            ],
          ),
          ),
      ),
      drawer: SafeArea(
        child: Container(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 128.0,
                  height: 128.0,
                  margin: const EdgeInsets.only(
                    top: 24.0,
                    bottom: 64.0,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: Lottie.asset("assets/lottie/djani_gpt_typing.json",
              width: 200,
              height:150,
             ),
                ),
                ListTile(
                  onTap: () {},
                  leading:
                      Icon(Icons.account_circle_rounded, color: Colors.white,),
                  title: Text(userName),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(Icons.email, color: Colors.white,),
                  title: Text(userEmail),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Propos()));
                  },
                  leading: Icon(
                    Icons.info,
                    color: Colors.white,
                  ),
                  title: Text('Propos'),
                ),
                ListTile(
                  onTap: () {
                    _signOut();
                  },
                  leading: Icon(
                    Icons.logout,
                    color: Colors.white,
                  ),
                  title: Text('Se déconnecter'),
                ),
                ExpansionTile(
        leading: Icon(
          Icons.history,
          color: Colors.white,
        ),
        title: Text('Historique de recherche',style: TextStyle(color: Colors.white),),
        onExpansionChanged: (expanded) {
          setState(() {
            showSearchHistory = expanded;
          });
        },
        children: [
          for (var search in searchHistory)
            ListTile(
              title: Text(search),
          
            ),
        ],
      ),
        Spacer(),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                    child: Text(
                      'SODECOTON | 2024',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }
}
