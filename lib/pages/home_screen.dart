import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ingredient_detector/pages/setting_screen.dart';
import 'package:ingredient_detector/services/gallery.dart';
import 'package:ingredient_detector/services/preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  RecognizedText? _recognizedText;
  double? _imageWidth; // original image width (from decoding)
  double? _imageHeight; // original image height (from decoding)
  double? imageWidgetWidth; // displayed image width
  double? imageWidgetHeight; // displayed image height

  final GlobalKey _imageKey = GlobalKey();

  final MyGalleryService _galleryService = MyGalleryService();
  final PreferencesService _preferencesService = PreferencesService();
  final FlutterTts flutterTts = FlutterTts();
  
  List<String> blacklist = [];
  List<String> matchingItems = [];
  bool contains = false;
  List<dynamic> langs = [];

  @override
  void initState() {
    super.initState();
    updateBlacklist();
    getLanguages();
    initTts();
  }

  void initTts() async {
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.defaultToSpeaker],
    );
  }

  void getLanguages() async {
    final List<dynamic> currLang = await flutterTts.getLanguages;
    setState(() {
      langs = currLang;
    });
  }

  void updateBlacklist() async {
    final List<String> newList = await _preferencesService.readPreferences();
    
    setState(() {
      blacklist = newList;
    });
  }

  // !Implement a good tts
  // ! PLEASE REMOVE THIS
  Future<void> _speak() async {
    if (langs.contains("nl-BE")){
      await flutterTts.setLanguage("nl-BE");
      await flutterTts.setPitch(2.0);
      await flutterTts.setVolume(1.0);
      await flutterTts.speak(
        """Kanker hoer jij! Je bent echt een neger jij kleine motjo daghu beest!
        Ik verkracht je vanavond en je gaat schreeuwen als een kleine hoer dat je bent.
        Mijn penis gaat throbben en jij gaat het in je voelen.
        HAHAHAHAHHHAHHAHHAHHAHHHHAAAAA ik geef je ook HIV en AIDS erbij. Geniet ervan boeler!
        Okay nu even serieus, jou geselecteerde items zijn als volg: 
        ${formatList(blacklist)}"""
      );
    }
  }

  String formatList(List<String> list) {
    if (list.isEmpty) { 
      return """
        Je hebt geen geselecteerde items.
        Ga naar de instellingen, die aan de rechterzijde aan de top van het scherm staat
        met een "instellingen" icon, als je het nog niet ziet ben je best dom want het is
        vlak daar en makkelijk te zien. Druk gewoon erop en je zal dan ernaar gestuurd worden.
        Ik ga lekker door in je oren blijven praten, maar als je uiteindelijk niet meer zo dom
        bent kan je dan eindelijk drukken op "Add item" en voeg dan wat woorden toe.
      """;
    }
    if (list.length == 1) return list[0];
    if (list.length == 2) return '${list[0]} and ${list[1]}';

    final allButLast = list.sublist(0, list.length - 1).join(', ');
    final last = list.last;
    return '$allButLast en $last';
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void _handleImagePick(String type) async {
    await Future.delayed(Duration(milliseconds: 300));
    File? pickedImage;

    try {
      pickedImage = await _galleryService.pickImageAndDetectText(type);
    } catch (e) {
      debugPrint('No image picked!');
    }
    

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);

      setState(() {
        updateBlacklist();
        matchingItems = blacklist
            .where((item) => _galleryService.detectedText.contains(item))
            .toList();

        _image = pickedImage;
        _recognizedText = _galleryService.recognizedText;
        _imageWidth = decodedImage.width.toDouble();
        _imageHeight = decodedImage.height.toDouble();
      });

      // Get the information from the image
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 100), () {
          final RenderBox? box =
              _imageKey.currentContext?.findRenderObject() as RenderBox?;
          if (box != null) {
            setState(() {
              imageWidgetWidth = box.size.width;
              imageWidgetHeight = box.size.height;
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Text(
              "Homescreen",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingScreen(),
                    ),
                  );
                  // This runs whether user taps back
                  if (result == 'updated' || result == null) {
                    setState(() {
                      updateBlacklist();
                    });
                  }
                },
                icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _image == null
                ? Center(
                    child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      GestureDetector(
                        onTap: _speak,
                        child: Text(
                            "Please select an image from gallery or take a photo!"),
                      ),
                      SizedBox(height: 20),
                      Text(
                          "Currently selected items: ${blacklist.isEmpty ? "None" : ""}"),
                      ...blacklist.map((item) => Text(
                          "- $item",
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        )),
                    ],
                  ))
                : Column(
                    children: [
                      matchingItems.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Contains the following items:"),
                                ...matchingItems.map((item) => Text(
                                      "- $item",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                              ],
                            )
                          : Text("No matching items found"),
                      Row(
                        children: [
                          Spacer(),
                          IconButton(
                            onPressed: () => setState(() {
                              _image = null;
                            }),
                            icon: Icon(Icons.close),
                            color: Colors.red,
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 580,
                            child: Image.file(
                              _image!,
                              key: _imageKey,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (_recognizedText != null &&
                              _imageWidth != null &&
                              _imageHeight != null &&
                              imageWidgetWidth != null &&
                              imageWidgetHeight != null)
                            ..._recognizedText!.blocks.map((block) {
                              final rect = block.boundingBox;

                              final imgRatio = _imageWidth! / _imageHeight!;
                              final widgetRatio =
                                  imageWidgetWidth! / imageWidgetHeight!;

                              double renderWidth, renderHeight;
                              double dx = 0, dy = 0;

                              if (widgetRatio > imgRatio) {
                                // Container is wider than image: vertical bars
                                renderHeight = imageWidgetHeight!;
                                renderWidth = renderHeight * imgRatio;
                                dx = (imageWidgetWidth! - renderWidth) / 2;
                                dy = 0;
                              } else {
                                // Container is taller than image: horizontal bars
                                renderWidth = imageWidgetWidth!;
                                renderHeight = renderWidth / imgRatio;
                                dx = 0;
                                dy = (imageWidgetHeight! - renderHeight) / 2;
                              }

                              final scaleX = renderWidth / _imageWidth!;
                              final scaleY = renderHeight / _imageHeight!;

                              return Positioned(
                                left: dx - 3 + rect.left * scaleX,
                                top: dy - 3 + rect.top * scaleY,
                                width: 5 + rect.width * scaleX,
                                height: 5 + rect.height * scaleY,
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.red, width: 1),
                                      color: Colors.black54),
                                ),
                              );
                            }),
                        ],
                      )
                    ],
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        elevation: 8,
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Select from gallery
              GestureDetector(
                onTap: () => _handleImagePick("gallery"),
                child: Icon(Icons.image),
              ),

              // Vertical divider
              Container(
                width: 1,
                color: Colors.black,
              ),

              // Select from camera
              GestureDetector(
                onTap: () => _handleImagePick("camera"),
                child: Icon(Icons.camera_alt),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
