import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class AvaliarPage extends StatefulWidget {
  final int prestadorId;
  final String prestadorNome;
  final int? servicoId;
  final String? servicoNome;

  const AvaliarPage({
    super.key,
    required this.prestadorId,
    required this.prestadorNome,
    this.servicoId,
    this.servicoNome,
  });

  @override
  State<AvaliarPage> createState() => _AvaliarPageState();
}

class _AvaliarPageState extends State<AvaliarPage> {
  int _nota = 0;
  final TextEditingController _comentarioController = TextEditingController();
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviarAvaliacao() async {
    if (_nota == 0) {
      setState(() => _erro = 'Selecione uma nota');
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
    });

    try {
      await DuckHatApi.instance.criarAvaliacao(
        prestadorId: widget.prestadorId,
        nota: _nota,
        comentario: _comentarioController.text,
        servicoId: widget.servicoId,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avaliação enviada! Obrigado pelo feedback.'),
          backgroundColor: AppColors.accent,
        ),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _enviando = false;
        _erro = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppColors.textBold),
        ),
        title: const Text(
          'Avaliar',
          style: TextStyle(
            color: AppColors.textBold,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.prestadorNome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBold,
                ),
              ),
              if (widget.servicoNome != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.servicoNome!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textRegular,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'Como foi sua experiência?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => _nota = value),
                    icon: Icon(
                      value <= _nota ? Icons.star : Icons.star_border,
                      color: AppColors.star,
                      size: 40,
                    ),
                  );
                }),
              ),
              if (_nota > 0) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _nota == 1
                        ? 'Ruim'
                        : _nota == 2
                        ? 'Regular'
                        : _nota == 3
                        ? 'Bom'
                        : _nota == 4
                        ? 'Muito bom'
                        : 'Excelente',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textRegular,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'Deixe um comentário (opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _comentarioController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Conte sua experiência...',
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 16),
                Text(
                  _erro!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _enviando ? null : _enviarAvaliacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _enviando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enviar avaliação',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
