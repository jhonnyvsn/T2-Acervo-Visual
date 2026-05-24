import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/item_acervo.dart';

class SalvarScreen extends StatefulWidget {
  final String imagemPath;
  final String rotuloPrincipal;

  const SalvarScreen({super.key, required this.imagemPath, required this.rotuloPrincipal});

  @override
  State<SalvarScreen> createState() => _SalvarScreenState();
}

class _SalvarScreenState extends State<SalvarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _obsController = TextEditingController();
  bool _isUploading = false;

  Future<void> _salvarItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      
      // Compactação da imagem para garantir que ela caiba no limite gratuito de 1MB do Firestore
      final result = await FlutterImageCompress.compressWithFile(
        widget.imagemPath,
        minWidth: 800,
        minHeight: 800,
        quality: 30, // Reduz o peso da imagem sem destruir o visual
      );

      if (result == null) {
        throw Exception("Falha ao processar e compactar a imagem");
      }
      
      // Convertendo o resultado compactado para texto (Base64)
      String base64Image = base64Encode(result);

      // Salvar tudo no Firestore
      final item = ItemAcervo(
        id: '', // O Firestore irá gerar o ID do documento automaticamente
        uid: uid,
        nome: _nomeController.text.trim(),
        rotuloML: widget.rotuloPrincipal,
        imagemBase64: base64Image,
        observacoes: _obsController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('acervo').add(item.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item salvo com sucesso!'))
        );
        // Retorna até a tela de Acervo principal
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar: Imagem muito grande ou falha de rede.'))
        );
      }
      print("Erro detalhado ao salvar: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salvar no Acervo')),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Compactando e salvando dados...')
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.file(File(widget.imagemPath), height: 150, fit: BoxFit.cover),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: widget.rotuloPrincipal,
                      decoration: const InputDecoration(labelText: 'Categoria Detectada (ML)'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: 'Nome do Item *'),
                      validator: (val) => val != null && val.length >= 3 ? null : 'Mínimo de 3 caracteres',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _obsController,
                      decoration: const InputDecoration(labelText: 'Observações (Opcional)'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      onPressed: _salvarItem,
                      child: const Text('Confirmar e Salvar'),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}