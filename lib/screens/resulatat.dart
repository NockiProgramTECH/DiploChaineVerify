import 'package:flutter/material.dart';
import 'package:recruteur/screens/detaildoc.dart';
import 'package:recruteur/theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    bool isValid = result['valid'] ?? false;
    Map<String, dynamic>? diploma = result['diploma'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Résultat de la vérification"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildStatusBadge(isValid),
            const SizedBox(height: 30),
            _buildInfoCard(diploma, isValid),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                 if (diploma != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailDocScreen(diploma: diploma, university: result['university'], blockchain: result['blockchain'])),
                    );
                 }
              },
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryGreen),
              label: Text(
                "Voir plus de détails",
                style: AppTheme.bodyText.copyWith(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            _buildActionButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isValid) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isValid ? AppColors.primaryGreen : AppColors.errorRed,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isValid ? Icons.star : Icons.close,
              color: isValid ? AppColors.accentGold : Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isValid ? "Authentique" : "Non authentique",
            style: AppTheme.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            isValid 
              ? "Ce document est authentique et valide."
              : "Ce document n'a pas pu être vérifié ou est invalide.",
            textAlign: TextAlign.center,
            style: AppTheme.bodyText.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic>? diploma, bool isValid) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Informations du document",
            style: AppTheme.heading2.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Titulaire", diploma?['student'] ?? "---"),
          _buildInfoRow("Diplôme", diploma?['degree'] ?? "---"),
          _buildInfoRow("Émetteur", "Université Polytechnique"), // Example
          _buildInfoRow("Date d'émission", "15 Juillet 2023"), // Example
          _buildInfoRow("Numéro de série", diploma?['id']?.toString().substring(0, 10).toUpperCase() ?? "---"),
          _buildInfoRow("Hash (ID)", diploma?['id'] ?? "---", isLong: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTheme.bodyText.copyWith(color: AppColors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isLong ? 12 : 14,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: isLong ? 2 : 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text("Télécharger le rapport"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share, color: AppColors.primaryGreen),
              label: const Text("Partager"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
