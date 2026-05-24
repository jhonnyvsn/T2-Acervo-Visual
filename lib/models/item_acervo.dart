import 'package:cloud_firestore/cloud_firestore.dart';

class ItemAcervo {
  final String id;
  final String uid;
  final String nome;
  final String rotuloML;
  final String observacoes;
  final String imagemBase64; // <- Agora guarda o texto da imagem

  ItemAcervo({
    required this.id,
    required this.uid,
    required this.nome,
    required this.rotuloML,
    required this.imagemBase64,
    this.observacoes = '',
  });

  factory ItemAcervo.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemAcervo(
      id: doc.id,
      uid: data['uid'] as String,
      nome: data['nome'] as String,
      rotuloML: data['rotuloML'] as String,
      imagemBase64: data['imagemBase64'] as String,
      observacoes: data['observacoes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nome': nome,
    'rotuloML': rotuloML,
    'imagemBase64': imagemBase64,
    'observacoes': observacoes,
  };
}