import 'package:flutter/material.dart';
import '../models/star_data.dart';

class AddDataDialog extends StatefulWidget {
  final Function(StarData) onDataAdded;

  const AddDataDialog({
    super.key,
    required this.onDataAdded,
  });

  @override
  State<AddDataDialog> createState() => _AddDataDialogState();
}

class _AddDataDialogState extends State<AddDataDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brightnessController = TextEditingController();
  final _analysisController = TextEditingController();
  bool _hasTransit = false;
  final List<double> _lightCurve = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0];

  @override
  void dispose() {
    _nameController.dispose();
    _brightnessController.dispose();
    _analysisController.dispose();
    super.dispose();
  }

  void _addDataPoint() {
    setState(() {
      _lightCurve.add(1.0);
    });
  }

  void _removeDataPoint() {
    if (_lightCurve.length > 2) {
      setState(() {
        _lightCurve.removeLast();
      });
    }
  }

  void _updateDataPoint(int index, double value) {
    setState(() {
      _lightCurve[index] = value;
    });
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final starData = StarData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        brightness: double.parse(_brightnessController.text),
        timestamp: DateTime.now(),
        lightCurve: List.from(_lightCurve),
        analysis: _analysisController.text.isEmpty ? null : _analysisController.text,
        hasTransit: _hasTransit,
      );

      widget.onDataAdded(starData);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Yeni Veri Ekle',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Yıldız Adı',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Yıldız adı gerekli';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _brightnessController,
                          decoration: const InputDecoration(
                            labelText: 'Parlaklık',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Parlaklık değeri gerekli';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Geçerli bir sayı girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _hasTransit,
                              onChanged: (value) {
                                setState(() {
                                  _hasTransit = value ?? false;
                                });
                              },
                            ),
                            const Text('Geçiş tespit edildi'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _analysisController,
                          decoration: const InputDecoration(
                            labelText: 'Analiz (İsteğe bağlı)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Işık Eğrisi Verileri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _addDataPoint,
                              icon: const Icon(Icons.add),
                              label: const Text('Veri Ekle'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _removeDataPoint,
                              icon: const Icon(Icons.remove),
                              label: const Text('Veri Çıkar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.builder(
                            itemCount: _lightCurve.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Text('Nokta ${index + 1}:'),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Slider(
                                        value: _lightCurve[index],
                                        min: 0.0,
                                        max: 1.0,
                                        divisions: 100,
                                        onChanged: (value) {
                                          _updateDataPoint(index, value);
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: Text(
                                        _lightCurve[index].toStringAsFixed(3),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitData,
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}