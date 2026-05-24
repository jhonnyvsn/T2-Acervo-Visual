import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'salvar_screen.dart';

class ClassificarScreen extends StatefulWidget {
  const ClassificarScreen({super.key});

  @override
  State<ClassificarScreen> createState() => _ClassificarScreenState();
}

class _ClassificarScreenState extends State<ClassificarScreen> {
  File? _imagem;
  List<ImageLabel> _rotulos = [];
  bool _isLoading = false;

  late ImageLabeler _labeler;

  @override
  void initState() {
    super.initState();
    _labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
  }

  @override
  void dispose() {
    _labeler.close();
    super.dispose();
  }

  Future<void> _capturarImagem(ImageSource fonte) async {
    if (fonte == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissão de câmera negada')));
        return;
      }
    }

    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: fonte);
    if (xFile == null) return;

    setState(() {
      _imagem = File(xFile.path);
      _isLoading = true;
    });

    final inputImage = InputImage.fromFilePath(xFile.path);
    final labels = await _labeler.processImage(inputImage);

    setState(() {
      _rotulos = labels;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identificar Item')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.camera),
                label: const Text('Câmera'),
                onPressed: () => _capturarImagem(ImageSource.camera),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeria'),
                onPressed: () => _capturarImagem(ImageSource.gallery),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_imagem != null) Image.file(_imagem!, height: 200, fit: BoxFit.cover),
          if (_isLoading) const Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()),
          Expanded(
            child: ListView.builder(
              itemCount: _rotulos.length,
              itemBuilder: (context, i) {
                final label = _rotulos[i];
                final confianca = (label.confidence * 100).toStringAsFixed(1);
                return ListTile(
                  title: Text(label.label),
                  trailing: Text('$confianca%'),
                );
              },
            ),
          ),
          if (_imagem != null && _rotulos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SalvarScreen(
                        imagemPath: _imagem!.path,
                        rotuloPrincipal: _rotulos.first.label,
                      ),
                    ),
                  );
                },
                child: const Text('Prosseguir e Salvar'),
              ),
            )
        ],
      ),
    );
  }
}