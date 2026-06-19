import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/alces_ui.dart';

class GamificationInfoScreen extends StatelessWidget {
  const GamificationInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Gamificação Alce\'s', style: TextStyle(color: AppTheme.primaryGold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image / Icon
            const Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white10,
                child: Icon(Icons.emoji_events, size: 56, color: AppTheme.primaryGold),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Como funciona?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Na Alce\'s Barbearia sua fidelidade vale prêmios! Agende seus serviços, acumule XP e Alce Coins para subir de nível e resgatar vantagens.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Níveis e Cargos
            const Text(
              'Níveis e Cargos',
              style: TextStyle(color: AppTheme.primaryGold, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Do Level 1 ao 50',
              description: 'A cada 500 XP você sobe 1 Level. Conforme você evolui, seu "Cargo" dentro da barbearia também sobe de patente, trazendo ainda mais respeito e status.',
              icon: Icons.shield,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'XP (Experiência)',
              description: 'Você ganha XP cortando o cabelo, fazendo a barba e completando o seu perfil. O XP nunca expira e serve para definir seu Level e o seu Ranking.',
              icon: Icons.star,
            ),
            const SizedBox(height: 32),

            // Moedas e Prêmios
            const Text(
              'Alce Coins',
              style: TextStyle(color: AppTheme.primaryGold, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Moeda de Troca',
              description: 'Diferente do XP, as Alce Coins podem ser gastas! Use suas moedas para trocar por produtos da nossa vitrine, descontos e bebidas.',
              icon: Icons.monetization_on,
            ),
            const SizedBox(height: 32),

            // Ranking Mensal
            const Text(
              'Ranking Mensal',
              style: TextStyle(color: AppTheme.primaryGold, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Os Melhores do Mês (Em breve)',
              description: 'Todo mês, os clientes que mais acumularem XP entrarão no nosso Ranking Mensal. Os 3 primeiros colocados ganharão prêmios exclusivos e itens da loja!',
              icon: Icons.leaderboard,
            ),
            const SizedBox(height: 40),
            
            AlcesButton(
              text: 'BORA SUBIR DE NÍVEL!',
              isPrimary: true,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String description, required IconData icon}) {
    return AlcesCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
