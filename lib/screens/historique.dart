import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recruteur/service/database_helper.dart';
import 'package:recruteur/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = DatabaseHelper.instance.getAllRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des vérifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearAllDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<ScanRecord>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final record = history[index];
              return _buildHistoryItem(record);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: AppColors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            "Aucun historique",
            style: AppTheme.heading2.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            "Vos scans apparaîtront ici.",
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ScanRecord record) {
    bool? isValid = record.isValidTristate;
    Color statusColor = isValid == true
        ? AppColors.primaryGreen
        : (isValid == false ? AppColors.errorRed : AppColors.accentGold);

    DateTime? date;
    try {
      date = DateTime.parse(record.scannedAt);
    } catch (_) {}
    final formattedDate = date != null
        ? DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(date)
        : record.scannedAt;

    return Dismissible(
      key: Key(record.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.errorRed,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        if (record.id != null) {
          DatabaseHelper.instance.deleteRecord(record.id!);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
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
                isValid == true
                    ? Icons.verified
                    : (isValid == false ? Icons.error_outline : Icons.help_outline),
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
                    record.studentName ?? "ID: ${record.diplomaId.substring(0, 8)}...",
                    style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    record.degree ?? "Document inconnu",
                    style: AppTheme.subtitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
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
                _getStatusLabel(record.status),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'authentic':
        return "Authentique";
      case 'revoked':
        return "Révoqué";
      case 'not_found':
        return "Faux / Inconnu";
      case 'name_mismatch':
        return "Incohérence";
      default:
        return "Erreur";
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Effacer l'historique"),
        content: const Text("Voulez-vous vraiment effacer tout votre historique de scan ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.clearAll();
              if (mounted) {
                Navigator.pop(context);
                _refreshHistory();
              }
            },
            child: const Text("Effacer tout", style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }
}
