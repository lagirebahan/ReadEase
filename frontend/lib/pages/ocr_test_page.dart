import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class OCRTestPage extends StatefulWidget {
  const OCRTestPage({super.key});

  @override
  State<OCRTestPage> createState() => _OCRTestPageState();
}

class _OCRTestPageState extends State<OCRTestPage> {

  File? imageFile;
  String extractedText = '';

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<void> uploadImage() async {

    if (imageFile == null) return;

    final uri = Uri.parse('http://192.168.1.4:3001/upload');

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile!.path,
      ),
    );

    request.fields['title'] = 'Test OCR';

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();

    final data = jsonDecode(responseBody);

    setState(() {
      extractedText = data['note']['extracted_text'] ?? 'No text';
    });

    print(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Pick Image'),
            ),

            const SizedBox(height: 20),

            if (imageFile != null)
              Image.file(
                imageFile!,
                height: 200,
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: uploadImage,
              child: const Text('Upload & OCR'),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                child: Text(extractedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}