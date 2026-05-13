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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Certificat de Vérification"),
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
            _buildSectionHeader("Informations du Titulaire"),
            const SizedBox(height: 16),
            _buildDetailCard([
              _buildDetailRow("Nom Complet", diploma['student'] ?? "---"),
              _buildDetailRow("Type de Diplôme", diploma['degree'] ?? "---"),
              _buildDetailRow("Spécialité", diploma['field'] ?? "---"),
              _buildDetailRow("Mention Obtenue", diploma['mention']?.toUpperCase() ?? "---"),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader("Informations Académiques"),
            const SizedBox(height: 16),
            _buildDetailCard([
              _buildDetailRow("Établissement", university?['name'] ?? "Université Polytechnique"),
              _buildDetailRow("Date d'émission", _formatDate(diploma['issued_at'])),
              _buildDetailRow("Année Académique", (diploma['year'] ?? "---").toString()),
              _buildDetailRow("Identifiant Unique", diploma['id'] ?? "---", isLong: true),
            ]),
            const SizedBox(height: 32),
            _buildSectionHeader("Authentification Blockchain"),
            const SizedBox(height: 16),
            _buildBlockchainCard(),
            const SizedBox(height: 40),
            _buildVerificationBadge(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "---";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTheme.labelBold.copyWith(
          color: AppColors.grey,
          letterSpacing: 1.1,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.subtitle.copyWith(fontSize: 10, color: AppColors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTheme.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              fontSize: isLong ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainCard() {
    bool isAnchored = blockchain?['anchored'] ?? false;
    String txHash = blockchain?['tx_hash'] ?? "Non disponible";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.textDark, AppColors.textDark.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, color: AppColors.accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                "Transaction Hash",
                style: AppTheme.labelBold.copyWith(color: AppColors.accentGold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              txHash,
              style: TextStyle(
                color: isAnchored ? Colors.white70 : Colors.white38,
                fontSize: 11,
                fontFamily: 'monospace',
                fontStyle: isAnchored ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBlockchainStat(
                "Status", 
                isAnchored ? "Confirmé" : "En attente", 
                isAnchored ? Colors.green : AppColors.accentGold
              ),
              _buildBlockchainStat("Réseau", "Mainnet", Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 2),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildVerificationBadge() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.verified_user, color: AppColors.primaryGreen, size: 48),
          const SizedBox(height: 12),
          Text(
            "VÉRIFICATION SÉCURISÉE PAR DIPLOCHAIN",
            textAlign: TextAlign.center,
            style: AppTheme.labelBold.copyWith(
              color: AppColors.primaryGreen,
              letterSpacing: 1.5,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
