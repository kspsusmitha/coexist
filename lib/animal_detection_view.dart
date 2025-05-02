import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';

class AnimalDetectionView extends StatefulWidget {
  const AnimalDetectionView({super.key});

  @override
  State<AnimalDetectionView> createState() => _AnimalDetectionViewState();
}

class _AnimalDetectionViewState extends State<AnimalDetectionView> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isDetecting = false;
  String _detectedAnimal = '';
  String _animalDetails = '';
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeGemini();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  void _initializeGemini() {
    const apiKey = 'AIzaSyApHNMo6vyWhc2rooOLubtxVpDdQvAEqRo';
    
    _model = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 4096,
      ),
    );
  }

  Future<void> _detectAnimal() async {
    if (_isDetecting) return;

    setState(() {
      _isDetecting = true;
      _detectedAnimal = '';
      _animalDetails = '';
    });

    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final File imageFile = File(image.path);

      // Read the image file
      final bytes = await imageFile.readAsBytes();

      // Create content with the image
      final prompt = TextPart(
        'Please identify this animal and provide the following details in JSON format: common name, scientific name, species, habitat, diet, conservation status, interesting facts, and geographical distribution. Keep responses concise and accurate.'
      );
      final imagePart = DataPart('image/jpeg', bytes);

      // Generate content
      final response = await _model.generateContent([
        Content.multi([prompt, imagePart])
      ]);
      
      // Parse the response
      final responseText = response.text ?? 'No response received';
      setState(() {
        _detectedAnimal = 'Animal Detected';
        _animalDetails = responseText;
        _isDetecting = false;
      });
    } catch (e) {
      debugPrint('Error detecting animal: $e');
      setState(() {
        _detectedAnimal = 'Error detecting animal';
        _animalDetails = 'Please try again';
        _isDetecting = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Detection'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          if (_detectedAnimal.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _detectedAnimal,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _animalDetails,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isDetecting ? null : _detectAnimal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: _isDetecting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Detect Animal',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 