import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { 
  Target,
  Trophy,
  Star,
  TrendingUp,
  Award,
  Gift,
  Calendar,
  Users,
} from "lucide-react";

interface GoalProgress {
  id: string;
  title: string;
  description: string;
  type: "individual" | "team";
  period: "daily" | "weekly" | "monthly";
  current: number;
  target: number;
  bonus: number;
  unit: string;
}

const goals: GoalProgress[] = [
  {
    id: "1",
    title: "Meta Diária de Pontos",
    description: "Alcançar 30 pontos por dia",
    type: "individual",
    period: "daily",
    current: 0,
    target: 30,
    bonus: 20,
    unit: "pontos",
  },
  {
    id: "2",
    title: "Meta Semanal de Pontos",
    description: "Alcançar 200 pontos na semana",
    type: "individual",
    period: "weekly",
    current: 0,
    target: 200,
    bonus: 100,
    unit: "pontos",
  },
  {
    id: "3",
    title: "Meta Mensal de Pontos",
    description: "Alcançar 800 pontos no mês",
    type: "individual",
    period: "monthly",
    current: 0,
    target: 800,
    bonus: 300,
    unit: "pontos",
  },
  {
    id: "4",
    title: "Faturamento da Equipe",
    description: "Faturamento total da loja no mês",
    type: "team",
    period: "monthly",
    current: 0,
    target: 35000,
    bonus: 500,
    unit: "R$",
  },
];

interface Ranking {
  position: number;
  name: string;
  initials: string;
  points: number;
  bonus: number;
}

const rankings: Ranking[] = [];

const Goals = () => {
  const totalBonusEarned = 0;
  const potentialBonus = 920;

  return (
    <DashboardLayout
      title="Metas e Bônus"
      subtitle="Acompanhe suas metas e conquistas"
    >
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <Card className="border bg-primary/5 border-primary/20">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Bônus Acumulado</p>
                <p className="text-3xl font-bold text-foreground">
                  R$ {totalBonusEarned.toFixed(2)}
                </p>
                <p className="text-xs text-muted-foreground">Este mês</p>
              </div>
              <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
                <Gift className="w-6 h-6 text-primary" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Potencial Restante</p>
                <p className="text-3xl font-bold text-foreground">
                  R$ {potentialBonus.toFixed(2)}
                </p>
                <p className="text-xs text-muted-foreground">Se bater todas as metas</p>
              </div>
              <div className="w-12 h-12 rounded-lg bg-muted flex items-center justify-center">
                <Target className="w-6 h-6 text-muted-foreground" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Sua Posição</p>
                <div className="flex items-center gap-2">
                  <Trophy className="w-8 h-8 text-amber-500" />
                  <p className="text-3xl font-bold text-foreground">1º</p>
                </div>
                <p className="text-xs text-muted-foreground">Ranking do mês</p>
              </div>
              <div className="w-12 h-12 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
                <Star className="w-6 h-6 text-amber-600 dark:text-amber-400" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Goals Progress */}
        <div className="lg:col-span-2 space-y-4">
          <h2 className="text-lg font-semibold text-foreground">Suas Metas</h2>
          
          {goals.map((goal) => {
            const percentage = (goal.current / goal.target) * 100;
            const isAchieved = percentage >= 100;
            
            return (
              <Card key={goal.id} className={`border ${isAchieved ? "bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800" : ""}`}>
                <CardContent className="p-5">
                  <div className="flex items-start justify-between mb-4">
                    <div className="flex items-center gap-3">
                      <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                        goal.type === "team" 
                          ? "bg-purple-100 dark:bg-purple-900/30" 
                          : "bg-primary/10"
                      }`}>
                        {goal.type === "team" ? (
                          <Users className="w-5 h-5 text-purple-600 dark:text-purple-400" />
                        ) : (
                          <Target className="w-5 h-5 text-primary" />
                        )}
                      </div>
                      <div>
                        <div className="flex items-center gap-2">
                          <h3 className="font-semibold text-foreground">{goal.title}</h3>
                          {isAchieved && (
                            <Badge className="bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400">
                              <Trophy className="w-3 h-3 mr-1" />
                              Alcançada!
                            </Badge>
                          )}
                        </div>
                        <p className="text-sm text-muted-foreground">{goal.description}</p>
                      </div>
                    </div>
                    <Badge variant="outline" className="capitalize">
                      {goal.period === "daily" ? "Diária" : goal.period === "weekly" ? "Semanal" : "Mensal"}
                    </Badge>
                  </div>

                  <div className="space-y-2">
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">Progresso</span>
                      <span className="font-medium text-foreground">
                        {goal.unit === "R$" ? "R$ " : ""}{goal.current.toLocaleString()} / {goal.unit === "R$" ? "R$ " : ""}{goal.target.toLocaleString()} {goal.unit !== "R$" ? goal.unit : ""}
                      </span>
                    </div>
                    <Progress value={Math.min(percentage, 100)} className="h-2" />
                    <div className="flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">{percentage.toFixed(0)}% concluído</span>
                      <span className="font-medium text-primary">
                        Bônus: R$ {goal.bonus.toFixed(2)}
                      </span>
                    </div>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>

        {/* Ranking */}
        <Card className="border h-fit">
          <CardHeader className="pb-3">
            <div className="flex items-center gap-2">
              <Trophy className="w-5 h-5 text-amber-500" />
              <CardTitle className="text-lg font-semibold">Ranking do Mês</CardTitle>
            </div>
          </CardHeader>
          <CardContent className="space-y-3">
            {rankings.length === 0 ? (
              <p className="text-sm text-muted-foreground text-center py-4">
                Nenhum barbeiro pontuou neste período ainda.
              </p>
            ) : (
              rankings.map((barber) => (
                <div
                  key={barber.position}
                  className={`flex items-center gap-3 p-3 rounded-lg ${
                    barber.position === 1 
                      ? "bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800" 
                      : "bg-muted/50"
                  }`}
                >
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-sm ${
                    barber.position === 1 
                      ? "bg-amber-500 text-primary-foreground" 
                      : barber.position === 2 
                      ? "bg-gray-400 text-primary-foreground"
                      : barber.position === 3
                      ? "bg-amber-700 text-primary-foreground"
                      : "bg-muted text-muted-foreground"
                  }`}>
                    {barber.position}
                  </div>
                  <Avatar className="w-10 h-10">
                    <AvatarFallback className="bg-primary/10 text-primary text-sm font-medium">
                      {barber.initials}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1">
                    <p className="font-medium text-foreground text-sm">{barber.name}</p>
                    <p className="text-xs text-muted-foreground">{barber.points} pontos</p>
                  </div>
                  {barber.bonus > 0 && (
                    <Badge variant="secondary" className="text-xs">
                      +R$ {barber.bonus}
                    </Badge>
                  )}
                </div>
              ))
            )}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default Goals;
