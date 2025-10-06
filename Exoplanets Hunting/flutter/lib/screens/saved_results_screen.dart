import 'package:flutter/material.dart';
import '../models/saved_result.dart';
import '../services/storage_service.dart';

class SavedResultsScreen extends StatefulWidget {
  const SavedResultsScreen({super.key});

  @override
  State<SavedResultsScreen> createState() => _SavedResultsScreenState();
}

class _SavedResultsScreenState extends State<SavedResultsScreen> {
  List<SavedResult> _savedResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedResults();
  }

  Future<void> _loadSavedResults() async {
    final results = await StorageService.getSavedResults();
    setState(() {
      _savedResults = results;
      _isLoading = false;
    });
  }

  Future<void> _deleteResult(String id) async {
    await StorageService.deleteResult(id);
    await _loadSavedResults();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🗑️ Sonuç silindi"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllResults() async {
    await StorageService.clearAllResults();
    await _loadSavedResults();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🗑️ Tüm sonuçlar silindi"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kaydedilen Sonuçlar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_savedResults.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Tüm Sonuçları Sil"),
                    content: const Text("Tüm kaydedilen sonuçları silmek istediğinizden emin misiniz?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("İptal"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearAllResults();
                        },
                        child: const Text("Sil", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savedResults.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Henüz kaydedilen sonuç yok',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Gezegen tarama sonuçlarını kaydedin',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _savedResults.length,
                    itemBuilder: (context, index) {
                      final result = _savedResults[index];
                      return _buildResultCard(result);
                    },
                  ),
      ),
    );
  }

  Widget _buildResultCard(SavedResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getResultIcon(result.prediction),
                  color: _getResultColor(result.prediction),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getResultTitle(result.prediction),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteResult(result.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              result.message,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isNarrowScreen = screenWidth < 400;
                
                if (isNarrowScreen) {
                  // Dar ekranlarda dikey düzenleme
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoChip("Güven", "${(result.confidence * 100).toStringAsFixed(1)}%"),
                      const SizedBox(height: 8),
                      _buildInfoChip("Tip", result.planetType),
                      const SizedBox(height: 8),
                      _buildInfoChip("Tarih", _formatDate(result.timestamp)),
                    ],
                  );
                } else {
                  // Geniş ekranlarda yatay düzenleme
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip("Güven", "${(result.confidence * 100).toStringAsFixed(1)}%"),
                      _buildInfoChip("Tip", result.planetType),
                      _buildInfoChip("Tarih", _formatDate(result.timestamp)),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 12),
            Text(
              "⭐ ${result.starInfo['type'] ?? 'Bilinmiyor'}",
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          fontSize: 12,
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}";
  }

  Color _getResultColor(String prediction) {
    switch (prediction.toUpperCase()) {
      case 'CONFIRMED_PLANET':
        return Colors.green;
      case 'CANDIDATE':
        return Colors.orange;
      case 'FALSE_POSITIVE':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getResultIcon(String prediction) {
    switch (prediction.toUpperCase()) {
      case 'CONFIRMED_PLANET':
        return Icons.public;
      case 'CANDIDATE':
        return Icons.visibility;
      case 'FALSE_POSITIVE':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getResultTitle(String prediction) {
    switch (prediction.toUpperCase()) {
      case 'CONFIRMED_PLANET':
        return 'Gezegen Tespit Edildi!';
      case 'CANDIDATE':
        return 'Aday Gezegen';
      case 'FALSE_POSITIVE':
        return 'Yanlış Pozitif';
      default:
        return 'Bilinmeyen Sonuç';
    }
  }
}

