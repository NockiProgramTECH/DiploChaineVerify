import 'package:flutter/material.dart';
import 'package:recruteur/screens/historique.dart';
import 'package:recruteur/screens/scanns_screen.dart';
import 'package:recruteur/theme/app_theme.dart';
import 'package:recruteur/widgets/custom_card.dart';

class Acceuil extends StatefulWidget {
  const Acceuil({super.key});

  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenContent(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryRed,
        unselectedItemColor: AppColors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: "Historique",
          ),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the state to switch tabs
    final acceuilState = context.findAncestorStateOfType<_AcceuilState>();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          ActionCard(
            title: "Scanner un document",
            subtitle: "Vérifiez l'authenticité d'un\ndiplôme en quelques secondes",
            icon: Icons.qr_code_scanner,
            backgroundColor: AppColors.primaryGreen,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanScreen()),
              );
            },
          ),
          ActionCard(
            title: "Historique",
            subtitle: "Consultez vos précédentes\nvérifications enregistrées",
            icon: Icons.history,
            backgroundColor: Colors.white,
            iconBackgroundColor: AppColors.primaryGreen.withOpacity(0.1),
            textColor: AppColors.textDark,
            onTap: () {
              acceuilState?.setState(() {
                acceuilState._currentIndex = 1;
              });
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 380,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.primaryRed,
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Image.asset(
              "assets/img.png",
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_user, color: AppColors.accentGold, size: 30),
                            const SizedBox(width: 8),
                            Text(
                              "DiploChain",
                              style: AppTheme.heading2.copyWith(color: Colors.white, fontSize: 24),
                            ),
                          ],
                        ),
                        Text(
                          "Vérification intelligente\ndes documents",
                          style: AppTheme.subtitle.copyWith(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Text(
                  "Bienvenue !",
                  style: AppTheme.heading1.copyWith(fontSize: 32),
                ),
                Text(
                  "Recruteur",
                  style: AppTheme.heading1.copyWith(fontSize: 32, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 10),
                Text(
                  "Scannez et vérifiez l'authenticité\ndes diplômes et documents.",
                  style: AppTheme.bodyText.copyWith(color: Colors.white.withOpacity(0.9), fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Image.asset(
            "assets/img.png",
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
