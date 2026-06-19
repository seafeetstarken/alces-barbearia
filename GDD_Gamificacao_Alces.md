# 🎯 Game Design Document (GDD): O Caminho do Alce

Para transformar o app da barbearia em um ecossistema viciante, não faremos um simples "clube de pontos". Nós vamos construir um sistema onde o cliente evolui, compete, e é recompensado pelo engajamento.

A gamificação será ancorada em 4 pilares: **Níveis de EXP**, **AlceCoins (Moeda)**, **Conquistas (Badges)** e **Ranking (O Mural do Bando)**.

---

## 1. Níveis de Experiência (EXP)
O cliente ganha EXP por qualquer interação positiva com a barbearia. O nível máximo é 50. A dificuldade escala exponencialmente (fácil subir no começo, muito difícil chegar no topo).

**Como ganhar EXP?**
- **Agendar e Comparecer:** +100 EXP
- **Comprar Produto:** +50 EXP
- **Avaliar o Barbeiro (5 estrelas):** +20 EXP
- **Assinar Clube VIP:** +500 EXP (Boost mensal)

**Os Títulos de Prestígio (Tiers):**
- **Nível 1 a 10: Forasteiro** (Ícone: Uma bota de caminhada)
- **Nível 11 a 25: Lenhador** (Ícone: Um machado cruzado)
- **Nível 26 a 40: Membro do Bando** (Ícone: Uma pegada de Alce)
- **Nível 41 a 49: Predador** (Ícone: Olhos na noite)
- **Nível 50: O Alce Alfa** (Ícone: Galhadas Douradas brilhantes) - Apenas a elite atinge.

*Benefício do Nível:* Além de ostentação, clientes acima do nível 25 podem ganhar multiplicadores (ex: ganham 1.2x AlceCoins a cada compra).

---

## 2. A Economia: AlceCoins 🦌🪙
Enquanto o EXP serve para mostrar "status", a **AlceCoin** é a moeda de troca.
*Regra base:* R$ 1,00 gasto na barbearia = 1 AlceCoin.

**A Loja de Recompensas (O que fazer com as AlceCoins?):**
- **300 AlceCoins:** "A Caneca do Lenhador" - 1 Cerveja ou Drink Especial Cortesia.
- **800 AlceCoins:** "Tapa no Visual" - Upgrade: Adiciona Sobrancelha ou Lavagem grátis ao Corte.
- **1500 AlceCoins:** "O Toque Fino" - Resgate de 1 Pomada Modeladora.
- **3000 AlceCoins:** "Realeza" - 1 Serviço Completo (Barba + Cabelo) 100% Grátis.

---

## 3. Conquistas (Badges / Troféus)
O cliente terá uma vitrine virtual no perfil para exibir suas medalhas. Algumas serão secretas até ele desbloquear.

- 🔥 **Combo de Fogo:** Fazer Barba, Cabelo e comprar um Produto no mesmo dia. (Prêmio: +200 AlceCoins)
- 🦉 **Coruja:** Agendar o último horário disponível da barbearia.
- 🌞 **Galo da Manhã:** Agendar o primeiro horário (09:00).
- 🏆 **Fiel Escudeiro:** Ser atendido pelo mesmo barbeiro 5 vezes seguidas.
- 💈 **O Clássico:** Assinar o Plano Essencial do Clube.

---

## 4. O Ranking (Mural do Bando)
Uma tela dentro do app chamada "O Bando" (Leaderboard).
- Mostrará o Top 10 Clientes com mais EXP ganha **no mês atual**.
- **Premiação de Fim de Mês:** O cliente que fechar o mês em **#1 no Ranking (O Top 1 Mensal)** ganha um prêmio de destaque, como um Kit de Produtos premium ou 1 mês do plano VIP de graça. (Nota: Ele não vira o "Alce Alfa" apenas por vencer o mês, pois o título de Alce Alfa é exclusivo de quem atinge o dificílimo Nível 50).
- Isso gera uma rivalidade saudável. Homens são naturalmente competitivos; eles vão agendar serviços extras no fim do mês só para não perder o 1º lugar para um amigo.

---

## Estrutura Técnica de Banco de Dados
Para implementar a base sólida do MVP:
- **`gamification_profiles`**: `user_id`, `total_exp`, `level`, `alce_coins`.
- **`achievements`**: Lista fixa de todas as conquistas e suas descrições.
- **`user_achievements`**: Relacionamento N:N de quem desbloqueou o quê.
