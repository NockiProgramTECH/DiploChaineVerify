import 'package:flutter/material.dart';
import 'package:recruteur/theme/app_theme.dart';

class DetailDocScreen extends StatelessWidget {
  final Map<String, dynamic> diploma;
  final Map<String, dynamic>? university;
  final Map<String, dynamic>? blockchain;

  const DetailDocScreen({
    super.key,
    required this.diploma,
    this.university,
    this.blockchain,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails du document"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Informations détaillées"),
            const SizedBox(height: 16),
            _buildDetailCard([
              _buildDetailRow("Titulaire", diploma['student'] ?? "---"),
              _buildDetailRow("Date de naissance", "12 Mars 2001"), // Example
              _buildDetailRow("Diplôme", diploma['degree'] ?? "---"),
              _buildDetailRow("Spécialité", diploma['field'] ?? "---"),
              _buildDetailRow("Mention", diploma['mention']?.toUpperCase() ?? "---"),
              _buildDetailRow("Émetteur", university?['name'] ?? "Université Polytechnique"),
              _buildDetailRow("Date d'émission", "15 Juillet 2023"),
              _buildDetailRow("Numéro de série", "UO1-LICINFO-2023-4587"),
              _buildDetailRow("Hash (ID)", diploma['id'] ?? "---", isLong: true),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader("Preuve sur la blockchain"),
            const SizedBox(height: 16),
            _buildDetailCard([
              Row(
                children: [
                   const Icon(Icons.link, color: AppColors.primaryGreen, size: 20),
                   const SizedBox(width: 8),
                   Expanded(
                     child: Text(
                       blockchain?['tx_hash'] ?? "0x7d3f...9a8b7c6d5e4f3a2b1c0d9e8f7",
                       style: AppTheme.bodyText.copyWith(fontSize: 12, color: AppColors.grey),
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                ],
              ),
              const Divider(height: 24),
              _buildDetailRow("Bloc", "185,732"),
              _buildDetailRow("Date d'ancrage", "16 Juillet 2023 à 14:32 UTC"),
            ]),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.open_in_new, size: 18),
                label: const Text("Voir sur l'explorateur"),
                style: TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.heading2.copyWith(fontSize: 18),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
