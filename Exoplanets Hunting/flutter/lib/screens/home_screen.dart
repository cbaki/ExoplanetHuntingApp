import 'package:flutter/material.dart';
import '../models/star_data.dart';
import '../widgets/star_card.dart';
import '../widgets/light_curve_chart.dart';
import '../widgets/add_data_dialog.dart';
import '../widgets/space_background.dart';
import '../theme/app_theme.dart';
import 'galaxy_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StarData> starDataList = [];
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Planets', 'Comets', 'Solar System'];

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    setState(() {
      starDataList = [
        StarData(
          id: '1',
          name: 'HD 209458',
          brightness: 7.65,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          lightCurve: [1.0, 0.98, 0.96, 0.94, 0.96, 0.98, 1.0],
          analysis: 'Gezegen geçişi tespit edildi',
          hasTransit: true,
        ),
        StarData(
          id: '2',
          name: 'Kepler-452',
          brightness: 13.8,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          lightCurve: [1.0, 1.0, 0.99, 0.99, 1.0, 1.0, 1.0],
          analysis: 'Normal yıldız parlaklığı',
          hasTransit: false,
        ),
        StarData(
          id: '3',
          name: 'TRAPPIST-1',
          brightness: 18.8,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          lightCurve: [1.0, 0.97, 0.95, 0.93, 0.95, 0.97, 1.0],
          analysis: 'Çoklu gezegen sistemi tespit edildi',
          hasTransit: true,
        ),
      ];
    });
  }

  void _showAddDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AddDataDialog(
        onDataAdded: (StarData newData) {
          setState(() {
            starDataList.insert(0, newData);
          });
        },
      ),
    );
  }

  List<StarData> get filteredStarData {
    if (selectedFilter == 'All') {
      return starDataList;
    }
    return starDataList.where((star) {
      if (selectedFilter == 'Planets') {
        return star.hasTransit;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Gezegen Avı',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: AppTheme.textWhite),
              onPressed: () {
                // Ayarlar sayfası
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Galaksi Haritası Butonu - En üstte
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 16 : 12,
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GalaxyMapScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: AppTheme.textWhite,
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 18 : 14,
                    horizontal: isTablet ? 32 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.explore, size: 28),
                label: Text(
                  'GALAKSİ HARİTASI',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            // Filtre butonları - responsive
            Container(
              height: isTablet ? 60 : 50,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 8 : 4,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: EdgeInsets.only(right: isTablet ? 12 : 8),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                      // ignore: deprecated_member_use
                      backgroundColor: AppTheme.secondaryDark.withOpacity(0.7),
                      // ignore: deprecated_member_use
                      selectedColor: AppTheme.accentBlue.withOpacity(0.8),
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.textWhite : AppTheme.textGray,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.accentBlue : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  );
                },
              ),
            ),
          
            // Ana içerik - responsive
            Expanded(
              child: filteredStarData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_border,
                            size: isTablet ? 80 : 64,
                            color: AppTheme.textGray,
                          ),
                          SizedBox(height: isTablet ? 24 : 16),
                          Text(
                            'Henüz veri yok',
                            style: TextStyle(
                              fontSize: isTablet ? 22 : 18,
                              color: AppTheme.textGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isTablet ? 12 : 8),
                          Text(
                            'Yeni veri eklemek için + butonuna basın',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              // ignore: deprecated_member_use
                              color: AppTheme.textGray.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : isTablet
                      ? GridView.builder(
                          padding: EdgeInsets.all(isTablet ? 24 : 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredStarData.length,
                          itemBuilder: (context, index) {
                            final starData = filteredStarData[index];
                            return StarCard(
                              starData: starData,
                              onTap: () {
                                _showStarDetails(starData);
                              },
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredStarData.length,
                          itemBuilder: (context, index) {
                            final starData = filteredStarData[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: StarCard(
                                starData: starData,
                                onTap: () {
                                  _showStarDetails(starData);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDataDialog,
          backgroundColor: AppTheme.accentBlue,
          child: const Icon(Icons.add, color: AppTheme.textWhite),
        ),
      ),
    );
  }

  void _showStarDetails(StarData starData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
                  Text(
                    starData.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Parlaklık: ${starData.brightness.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Işık Eğrisi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: SimpleLightCurveChart(
                      data: starData.lightCurve,
                    ),
                  ),
                  if (starData.analysis != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Analiz',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: starData.hasTransit ? Colors.green[900] : Colors.blue[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        starData.analysis!,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}