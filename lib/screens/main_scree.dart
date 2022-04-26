import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocrengin/providers/ocr_provider.dart';
import 'package:ocrengin/utils/constants.dart';
import 'package:ocrengin/utils/dimens.dart';
import 'package:permission_handler/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? _imagePath;
  String? _ocrResult;

  var _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  OCRProvider? ocrEngine;

  @override
  void initState() {
    super.initState();

    ocrEngine = OCRProvider(
      apiKey: Platform.isAndroid ? apiKeyAndroid : apiKeyIOS,
      licenseKey: Platform.isAndroid ? licenseKeyAndroid : licenseKeyIOS,
    );

    _getEvent();
  }

  void _getEvent() {
    ocrEngine!.getOCR((result) {
      setState(() {
        _isLoading = false;
        _ocrResult = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OCR Engine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              children: [
                const Text('Selected Image'),
                const SizedBox(
                  height: 16.0,
                ),
                Container(
                  width: double.infinity,
                  height: kImageHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    // ignore: prefer_const_literals_to_create_immutables
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0.0, 2.0),
                        spreadRadius: 2.0,
                        blurRadius: 3.0,
                      )
                    ],
                  ),
                  child: _imagePath == null
                      ? InkWell(
                          onTap: () => _pickImage(),
                          child: const Center(
                            child: Text(
                              'Please choose a image\n(Tap here)',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: kImageHeight,
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () => _removeImage(),
                                    child: const Icon(Icons.close),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Text(
                        _ocrResult ?? 'Ocr Data',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              const Positioned.fill(
                child: Center(
                  child: SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    await [
      Permission.photos,
      Permission.camera,
      Permission.storage,
    ].request();
    var statusPhoto = await Permission.photos.status;
    if (!statusPhoto.isGranted) {
      return;
    }
    var statusCamera = await Permission.camera.status;
    if (!statusCamera.isGranted) {
      return;
    }
    var statusStorage = await Permission.storage.status;
    if (!statusStorage.isGranted) {
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 32.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => _onClickGallery(),
                      child: const Text('From Gallery'),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    InkWell(
                      onTap: () => _onClickCamera(),
                      child: const Text('From Camera'),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void _onClickGallery() async {
    Navigator.of(context).pop();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    _imagePath = image!.path;
    _progressOCR();
  }

  void _onClickCamera() async {
    Navigator.of(context).pop();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    _imagePath = image!.path;
    _progressOCR();
  }

  void _progressOCR() async {
    _isLoading = true;
    setState(() {});
    if (kDebugMode) {
      print('[Image Picker] path : $_imagePath');
    }
    ocrEngine!.ocr(_imagePath!);
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
  }
}
