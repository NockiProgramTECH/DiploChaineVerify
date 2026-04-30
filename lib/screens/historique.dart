import 'package:flutter/material.dart';
import 'package:recruteur/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> history = [
      {
        "name": "Mahamadou ILBOUDO",
        "degree": "Licence en Informatique",
        "date": "16 Juil. 2023 à 14:32",
        "status": "Authentique",
        "isValid": true,
      },
      {
        "name": "Awa TRAORÉ",
        "degree": "Master en Gestion",
        "date": "15 Juil. 2023 à 10:15",
        "status": "Non authentique",
        "isValid": false,
      },
      {
        "name": "Idrissa CONGO",
        "degree": "Licence en Droit",
        "date": "14 Juil. 2023 à 09:45",
        "status": "Non vérifié",
        "isValid": null,
      },
      {
        "name": "Fatoumata SAWADOGO",
        "degree": "Licence en Économie",
        "date": "13 Juil. 2023 à 16:20",
        "status": "Authentique",
        "isValid": true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des vérifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return _buildHistoryItem(item);
        },
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    bool? isValid = item['isValid'];
    Color statusColor = isValid == true 
        ? AppColors.primaryGreen 
        : (isValid == false ? AppColors.errorRed : AppColors.accentGold);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isValid == true ? Icons.star : (isValid == false ? Icons.close : Icons.priority_high),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  item['degree'],
                  style: AppTheme.subtitle,
                ),
                const SizedBox(height: 4),
                Text(
                  item['date'],
                  style: AppTheme.subtitle.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item['status'],
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
