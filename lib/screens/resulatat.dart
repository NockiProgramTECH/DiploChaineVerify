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
    Map<String, dynamic>? university = result['university'];
    Map<String, dynamic>? blockchain = result['blockchain'];
    bool isAnchored = blockchain?['anchored'] ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Résultat de vérification"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusHeader(isValid, isAnchored),
            const SizedBox(height: 24),
            if (isValid) _buildBlockchainBadge(isAnchored),
            const SizedBox(height: 24),
            _buildInfoSection(diploma, university, isValid),
            const SizedBox(height: 32),
            _buildActionButtons(context, diploma, university, blockchain),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool isValid, bool isAnchored) {
    Color headerColor = isValid 
        ? (isAnchored ? AppColors.primaryGreen : AppColors.accentGold)
        : AppColors.errorRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: headerColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isValid ? (isAnchored ? Icons.verified : Icons.check_circle_outline) : Icons.gpp_bad,
              color: Colors.white,
              size: 64,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isValid 
                ? (isAnchored ? "DOCUMENT AUTHENTIQUE" : "DOCUMENT VALIDE")
                : "DOCUMENT NON AUTHENTIQUE",
            textAlign: TextAlign.center,
            style: AppTheme.heading2.copyWith(
              color: Colors.white,
              letterSpacing: 1.2,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isValid
                ? (isAnchored 
                    ? "Ce diplôme a été vérifié et certifié sur la blockchain."
                    : "Diplôme authentifié, en attente d'ancrage blockchain.")
                : result['message'] ?? "L'authenticité de ce document n'a pu être établie.",
            textAlign: TextAlign.center,
            style: AppTheme.bodyText.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainBadge(bool isAnchored) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (isAnchored ? AppColors.accentGold : AppColors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (isAnchored ? AppColors.accentGold : AppColors.grey).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.link, color: isAnchored ? AppColors.accentGold : AppColors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAnchored ? "Preuve Blockchain active" : "Blockchain en attente",
                  style: AppTheme.labelBold.copyWith(
                    color: isAnchored ? AppColors.accentGold : AppColors.textMedium, 
                    fontSize: 14
                  ),
                ),
                Text(
                  isAnchored ? "Ancrage sécurisé certifié" : "Non encore inscrit sur le registre",
                  style: AppTheme.subtitle.copyWith(
                    color: (isAnchored ? AppColors.accentGold : AppColors.grey).withOpacity(0.8)
                  ),
                ),
              ],
            ),
          ),
          if (isAnchored) const Icon(Icons.verified, color: AppColors.primaryGreen, size: 20),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Map<String, dynamic>? diploma, Map<String, dynamic>? university, bool isValid) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Détails du Document", style: AppTheme.heading2.copyWith(fontSize: 16)),
              if (isValid) const Icon(Icons.info_outline, color: AppColors.grey, size: 20),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow("Titulaire", diploma?['student'] ?? "Inconnu"),
          _buildInfoRow("Diplôme", diploma?['degree'] ?? "Non spécifié"),
          _buildInfoRow("Spécialité", diploma?['field'] ?? "---"),
          _buildInfoRow("Émetteur", university?['name'] ?? "Non spécifié"),
          _buildInfoRow("Année", (diploma?['year'] ?? "---").toString()),
          _buildInfoRow("Mention", (diploma?['mention'] ?? "---").toString().replaceAll('_', ' ').toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTheme.subtitle.copyWith(fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyText.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic>? diploma, Map<String, dynamic>? university, Map<String, dynamic>? blockchain) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (diploma != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DetailDocScreen(
                              diploma: diploma,
                              university: university,
                              blockchain: blockchain,
                            )),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("Voir le certificat complet", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Nouveau scan"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textMedium,
                    side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: AppColors.primaryRed),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
