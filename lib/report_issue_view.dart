import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportIssueView extends StatefulWidget {
  const ReportIssueView({super.key});

  @override
  State<ReportIssueView> createState() => _ReportIssueViewState();
}

class _ReportIssueViewState extends State<ReportIssueView> {
  String? selectedOption = 'Yes';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isUploading = false; // To show loading state

  // **Pick Image**
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      print("Image selected: ${_imageFile!.path}"); // Debugging
    } else {
      print("No image selected.");
    }
  }

  // **Upload Image to Firebase Storage and return URL**
  Future<String?> _uploadImage() async {
    if (_imageFile == null) {
      print("No image file to upload.");
      return null;
    }

    try {
      // Check if the file exists before uploading
      final fileExists = await _imageFile!.exists();
      if (!fileExists) {
        print("File does not exist at path: ${_imageFile!.path}");
        return null;
      }

      // Generate a unique file name for Firebase Storage
      String fileName = "images/${DateTime.now().millisecondsSinceEpoch}.jpg";
      Reference ref = FirebaseStorage.instance.ref().child(fileName);

      // Upload the image file to Firebase Storage
      UploadTask uploadTask = ref.putFile(_imageFile!);

      // Wait for the upload to complete and get the URL
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => {
        print("image cant convert")
      });
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print("Download UR >>========>: $downloadUrl"); // Debugging
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e \n my image: $_imageFile");
      return null;
    }
  }

  // **Save Data to Firestore**
  Future<void> _saveToFirestore({
    required String description,
    required String? imageUrl,
    required String? needHelp,
  }) async {
    try {
      // Ensure the image is uploaded first and get the URL
      // print("my url ===>${ await _uploadImage()}");
      String? imageUrl = await _uploadImage();

      // Save report data to Firestore
      // print("my image url ===>>>${imageUrl}");
      await FirebaseFirestore.instance.collection('uploads_report').add({
        'description': description.trim(),
        'image': imageUrl ?? '',
        'date': DateTime.now().toIso8601String(),
        'need_help': needHelp,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Report submitted successfully!")),
      );

      // **Reset Form**
      setState(() {
        _imageFile = null;
        _descriptionController.clear();
        _isUploading = false;
      });
    } catch (e) {
      print("Error saving to Firestore: $e");
      setState(() {
        _isUploading = false;
      });
    }
  }

  // **Submit Data**
  Future<void> _submitReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a description.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload the image and then save the report to Firestore
      String? imageUrl = await _uploadImage();
      await _saveToFirestore(
        description: _descriptionController.text,
        imageUrl: imageUrl,
        needHelp: selectedOption,
      );
    } catch (e) {
      print("Submission failed: $e");
      setState(() {
        _isUploading = false;
      });
    }
  }

  // **Show Image Picker Dialog**
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose an option"),
          actions: [
            TextButton(
              onPressed: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
              child: Text("Camera"),
            ),
            TextButton(
              onPressed: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
              child: Text("Gallery"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffB1CA54),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new),
        ),
      ),
      backgroundColor: Color(0xffB1CA54),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Report an issue",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.black)),
              SizedBox(height: 20),
              TextField(
                maxLines: 10,
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Type...",
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(width: 1, color: Colors.black),
                  ),
                ),
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              Padding(
                padding: EdgeInsets.only(top: 18.0, bottom: 10),
                child: Text("Upload image",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              InkWell(
                onTap: _showImagePickerDialog,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!,
                      height: 110, width: 150, fit: BoxFit.cover)
                      : Image.asset("assets/images/placeholder.png",
                      height: 110, width: 150, fit: BoxFit.fill),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 18.0, bottom: 8),
                child: Text("Need help",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'Yes',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() => selectedOption = value);
                    },
                  ),
                  Text("Yes"),
                  Radio<String>(
                    value: 'No',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() => selectedOption = value);
                    },
                  ),
                  Text("No"),
                ],
              ),
              SizedBox(height: 20),
              Center(
                child: _isUploading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      maximumSize: Size(
                          MediaQuery.of(context).size.width - 50, 40),
                      minimumSize: Size(
                          MediaQuery.of(context).size.width - 50, 40)),
                  onPressed: _submitReport, // Changed to _submitReport
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
