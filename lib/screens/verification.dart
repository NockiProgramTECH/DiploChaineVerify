import 'package:flutter/material.dart';
import 'package:recruteur/screens/resulatat.dart';
import 'package:recruteur/service/api_service.dart';
import 'package:recruteur/theme/app_theme.dart';

class VerificationScreen extends StatefulWidget {
  final String diplomaId;

  const VerificationScreen({super.key, required this.diplomaId});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final ApiService _apiService = ApiService();
  int currentStep = 0;
  final List<String> steps = [
    "Document scanné",
    "Extraction des données",
    "Vérification de l'authenticité",
    "Recherche sur la blockchain",
  ];

  @override
  void initState() {
    super.initState();
    _startVerification();
  }

  Future<void> _startVerification() async {
    // Simulate steps for UI feedback
    for (int i = 0; i < steps.length; i++) {
      setState(() {
        currentStep = i;
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // At step 2 (Vérification de l'authenticité), we can call the real API
      if (i == 2) {
         try {
           final result = await _apiService.verifyDiploma(diplomaId: widget.diplomaId);
           // After last step, go to result screen
           if (i == steps.length - 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ResultScreen(result: result)),
              );
           }
         } catch (e) {
            // Handle error (e.g., 404 or network error)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ResultScreen(result: {"valid": false, "reason": "not_found", "message": "Erreur lors de la vérification"})),
            );
            return;
         }
      }
    }

    // Final navigation if not already handled in the loop
    if (mounted) {
      // Re-fetching or using the previous result if available
      final result = await _apiService.verifyDiploma(diplomaId: widget.diplomaId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(result: result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification en cours"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildCircularProgress(),
            const SizedBox(height: 40),
            Text(
              "Analyse et vérification...",
              style: AppTheme.heading2,
            ),
            const SizedBox(height: 10),
            Text(
              "Veuillez patienter pendant que nous\nvérifions l'authenticité du document.",
              textAlign: TextAlign.center,
              style: AppTheme.bodyText.copyWith(color: AppColors.grey),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return _buildStepItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CircularProgressIndicator(
            value: (currentStep + 1) / steps.length,
            strokeWidth: 8,
            backgroundColor: AppColors.grey.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.star,
            color: AppColors.accentGold,
            size: 60,
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem(int index) {
    bool isCompleted = index < currentStep;
    bool isLoading = index == currentStep;
    bool isPending = index > currentStep;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isPending ? AppColors.grey : AppColors.primaryGreen,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: AppColors.primaryGreen)
                : isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen)),
                      )
                    : null,
          ),
          const SizedBox(width: 16),
          Text(
            steps[index],
            style: AppTheme.bodyText.copyWith(
              color: isPending ? AppColors.grey : AppColors.textDark,
              fontWeight: isLoading ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (isCompleted)
            const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen)),
            ),
        ],
      ),
    );
  }
}
