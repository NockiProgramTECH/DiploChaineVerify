import 'package:flutter/material.dart';
import 'package:recruteur/screens/resulatat.dart';
import 'package:recruteur/service/api_service.dart';
import 'package:recruteur/service/database_helper.dart';
import 'package:recruteur/theme/app_theme.dart';

class VerificationScreen extends StatefulWidget {
  final String diplomaId;

  const VerificationScreen({super.key, required this.diplomaId});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  int _currentStep = 0;


  late AnimationController _rotateController;
  late AnimationController _stepFadeController;
  late Animation<double> _stepFadeAnim;

  static const _steps = [
    _Step(icon: Icons.document_scanner_outlined, label: "Document scanné"),
    _Step(icon: Icons.data_object_outlined, label: "Extraction des données"),
    _Step(icon: Icons.verified_user_outlined, label: "Vérification de l'authenticité"),
    _Step(icon: Icons.link, label: "Recherche sur la blockchain"),
  ];

  @override
  void initState() {
    super.initState();

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _stepFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _stepFadeAnim = CurvedAnimation(
        parent: _stepFadeController, curve: Curves.easeIn);

    _runVerification();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _stepFadeController.dispose();
    super.dispose();
  }

  Future<void> _runVerification() async {
    // Steps 0 and 1 are purely cosmetic (simulate fast processing)
    for (int i = 0; i < 2; i++) {
      await _advanceTo(i);
    }

    // Step 2: real API call
    await _advanceTo(2);
    Map<String, dynamic> result;
    try {
      result = await _apiService.verifyDiploma(diplomaId: widget.diplomaId);
    } catch (e) {
      result = {
        "valid": false,
        "reason": "error",
        "message": "Erreur réseau. Vérifiez votre connexion.",
      };
    }

    // Step 3: blockchain lookup (cosmetic)
    await _advanceTo(3);
    await Future.delayed(const Duration(milliseconds: 800));

    // Persist to SQLite
    try {
      final record = ScanRecord.fromApiResponse(
        diplomaId: widget.diplomaId,
        response: result,
      );
      await DatabaseHelper.instance.insertRecord(record);
    } catch (_) {
      // Non-blocking: history save failure should not block the user
    }

    if (!mounted) return;

    _rotateController.stop();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => ResultScreen(result: result),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  Future<void> _advanceTo(int step) async {
    setState(() => _currentStep = step);
    _stepFadeController.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 900));
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _steps.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Vérification en cours"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Circular progress with shield icon
            _CircularProgressWidget(
              progress: progress,
              rotateController: _rotateController,
            ),

            const SizedBox(height: 32),
            Text("Analyse et vérification…", style: AppTheme.heading2),
            const SizedBox(height: 8),
            Text(
              "Veuillez patienter pendant que nous\nvérifions l'authenticité du document.",
              textAlign: TextAlign.center,
              style: AppTheme.bodyText,
            ),

            const SizedBox(height: 40),

            // Steps list
            ...List.generate(_steps.length, (i) {
              return _StepTile(
                step: _steps[i],
                index: i,
                currentStep: _currentStep,
              );
            }),

            const Spacer(),

            // Diploma ID chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code, size: 16, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "ID : ${widget.diplomaId}",
                      style: AppTheme.subtitle.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final String label;
  const _Step({required this.icon, required this.label});
}

// ---------------------------------------------------------------------------

class _CircularProgressWidget extends StatelessWidget {
  final double progress;
  final AnimationController rotateController;

  const _CircularProgressWidget({
    required this.progress,
    required this.rotateController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing ring
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Rotating gradient ring
          AnimatedBuilder(
            animation: rotateController,
            builder: (_, __) => Transform.rotate(
              angle: rotateController.value * 2 * 3.14159,
              child: SizedBox(
                width: 180,
                height: 180,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: AppColors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(AppColors.primaryGreen, AppColors.accentGold,
                        progress)!,
                  ),
                ),
              ),
            ),
          ),
          // Inner shield
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  AppColors.lightGrey,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.shield,
              color: Color.lerp(AppColors.primaryGreen, AppColors.accentGold, progress),
              size: 64,
            ),
          ),
          // Success check icon (only at 100%)
          if (progress >= 1.0)
            const Positioned(
              right: 25,
              bottom: 25,
              child: CircleAvatar(
                backgroundColor: AppColors.primaryGreen,
                radius: 18,
                child: Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final _Step step;
  final int index;
  final int currentStep;

  const _StepTile({
    required this.step,
    required this.index,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = index < currentStep;
    final isActive = index == currentStep;
    final isPending = index > currentStep;

    final color = isDone
        ? AppColors.primaryGreen
        : isActive
            ? AppColors.primaryGreen
            : AppColors.grey.withOpacity(0.4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryGreen.withOpacity(0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.primaryGreen.withOpacity(0.2)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Step indicator
          SizedBox(
            width: 28,
            height: 28,
            child: isDone
                ? Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  )
                : isActive
                    ? const SizedBox(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primaryGreen,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                      ),
          ),
          const SizedBox(width: 16),
          Icon(step.icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              step.label,
              style: AppTheme.bodyText.copyWith(
                color: isPending ? AppColors.grey : AppColors.textDark,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (isDone)
            const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 18),
        ],
      ),
    );
  }
}