import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class MyGalleryService {
  String detectedText = '';
  RecognizedText? recognizedText;

  Future<File?> pickImageAndDetectText(String type) async {
    final picker = ImagePicker();
    // final dynamic pickedImage;
    final XFile? pickedImage;

    if(type == "gallery"){
      // pickedImage = await picker.pickImage(source: ImageSource.gallery);
      pickedImage = await picker.pickMedia();
    }
    else{
      pickedImage = await picker.pickImage(source: ImageSource.camera);
    }
    

    // Fix image rotation
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final rotatedBytes = await FlutterImageCompress.compressAndGetFile(
      pickedImage!.path,
      targetPath,
      quality: 100,
      rotate: 0, // auto-fix based on EXIF
      autoCorrectionAngle: true,
    );

    if (rotatedBytes == null) return null;

    final imageFile = File(rotatedBytes.path);
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();

    recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    detectedText = recognizedText!.text.toLowerCase();
    return imageFile;
  }


}