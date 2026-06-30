import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { 
  TrendingUp, 
  Calendar, 
  Info, 
  ChevronRight,
  Coins,
  Target,
  Award,
  Calculator
} from "lucide-react";
import {
  Tooltip,
  TooltipContent,
  TooltipTrigger,
} from "@/components/ui/tooltip";

interface PointsBreakdown {
  service: string;
  count: number;
  pointsPerService: number;
  totalPoints: number;
}

const pointsBreakdown: PointsBreakdown[] = [];

interface DailyCommission {
  date: string;
  dayName: string;
  points: number;
  services: number;
  value: number;
}

const weeklyData: DailyCommission[] = [];

const Commissions = () => {
  const totalPoints = 0;
  const goalPoints = 30;
  const multiplier = 1.0;
  const baseValue = 15.75;
  const estimatedValue = 0;
  const weeklyTotal = 0;
  const weeklyPoints = 0;

  return (
    <DashboardLayout
      title="Minhas Comissões"
      subtitle="Acompanhe seus pontos e ganhos"
    >
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {/* Today's Points */}
        <Card className="border bg-primary/5 border-primary/20">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Pontos Hoje</p>
                <p className="text-3xl font-bold text-foreground">{totalPoints}</p>
                <div className="flex items-center gap-2">
                  <Progress value={(totalPoints / goalPoints) * 100} className="h-2 w-20" />
                  <span className="text-xs text-muted-foreground">de {goalPoints}</span>
                </div>
              </div>
              <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
                <Coins className="w-5 h-5 text-primary" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Estimated Today */}
        <Card className="border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <div className="flex items-center gap-1">
                  <p className="text-sm font-medium text-muted-foreground">Estimado Hoje</p>
                  <Tooltip>
                    <TooltipTrigger>
                      <Info className="w-3.5 h-3.5 text-muted-foreground" />
                    </TooltipTrigger>
                    <TooltipContent className="max-w-xs">
                      <p className="text-sm">
                        <strong>Cálculo:</strong><br />
                        {totalPoints} pontos × R$ {baseValue.toFixed(2)} × {multiplier}x<br />
                        = R$ {estimatedValue.toFixed(2)}
                      </p>
                    </TooltipContent>
                  </Tooltip>
                </div>
                <p className="text-3xl font-bold text-foreground">
                  R$ {estimatedValue.toFixed(2)}
                </p>
                <p className="text-xs text-muted-foreground">
                  Base: R$ {baseValue.toFixed(2)}/pt
                </p>
              </div>
              <div className="w-10 h-10 rounded-lg bg-muted flex items-center justify-center">
                <Calculator className="w-5 h-5 text-muted-foreground" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Multiplier */}
        <Card className="border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Multiplicador</p>
                <p className="text-3xl font-bold text-foreground">{multiplier.toFixed(1)}x</p>
                <Badge variant="secondary" className="text-xs">
                  Nível Profissional
                </Badge>
              </div>
              <div className="w-10 h-10 rounded-lg bg-muted flex items-center justify-center">
                <TrendingUp className="w-5 h-5 text-muted-foreground" />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Weekly Total */}
        <Card className="border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Esta Semana</p>
                <p className="text-3xl font-bold text-foreground">
                  R$ {weeklyTotal.toFixed(2)}
                </p>
                <p className="text-xs text-muted-foreground">
                  {weeklyPoints} pontos acumulados
                </p>
              </div>
              <div className="w-10 h-10 rounded-lg bg-muted flex items-center justify-center">
                <Calendar className="w-5 h-5 text-muted-foreground" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Points Breakdown */}
        <Card className="border lg:col-span-2">
          <CardHeader className="pb-3">
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg font-semibold">Detalhamento de Hoje</CardTitle>
              <Badge variant="outline">{totalPoints} pontos</Badge>
            </div>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {pointsBreakdown.map((item) => (
                <div key={item.service} className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
                      <span className="text-lg font-bold text-primary">{item.count}</span>
                    </div>
                    <div>
                      <p className="font-medium text-foreground">{item.service}</p>
                      <p className="text-sm text-muted-foreground">
                        {item.pointsPerService} pt por serviço
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold text-foreground">{item.totalPoints} pts</p>
                    <p className="text-sm text-muted-foreground">
                      R$ {(item.totalPoints * baseValue).toFixed(2)}
                    </p>
                  </div>
                </div>
              ))}
            </div>

            {/* Formula Explanation */}
            <div className="mt-6 p-4 rounded-lg bg-accent/50 border border-accent">
              <div className="flex items-start gap-3">
                <Info className="w-5 h-5 text-primary mt-0.5" />
                <div>
                  <p className="font-medium text-foreground mb-1">Como sua comissão é calculada</p>
                  <p className="text-sm text-muted-foreground">
                    <strong>Pontos × Valor Base × Multiplicador</strong><br />
                    O valor base é de R$ 15,75 por ponto. Seu multiplicador atual é {multiplier}x 
                    baseado no seu nível de carreira.
                  </p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Weekly History */}
        <Card className="border">
          <CardHeader className="pb-3">
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg font-semibold">Últimos 7 Dias</CardTitle>
              <button className="text-sm text-primary hover:underline">Ver mais</button>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <div className="divide-y divide-border">
              {weeklyData.map((day) => (
                <div
                  key={day.date}
                  className={`flex items-center justify-between px-6 py-3 ${
                    day.points === 0 ? "opacity-50" : ""
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-lg bg-muted flex items-center justify-center">
                      <span className="text-sm font-medium text-muted-foreground">
                        {day.dayName}
                      </span>
                    </div>
                    <div>
                      <p className="font-medium text-foreground">{day.date}</p>
                      <p className="text-sm text-muted-foreground">
                        {day.services > 0 ? `${day.services} serviços` : "Folga"}
                      </p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold text-foreground">
                      {day.points > 0 ? `${day.points} pts` : "-"}
                    </p>
                    <p className="text-sm text-muted-foreground">
                      {day.value > 0 ? `R$ ${day.value.toFixed(2)}` : "-"}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Goals Section */}
      <div className="mt-6">
        <Card className="border">
          <CardHeader className="pb-3">
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg font-semibold flex items-center gap-2">
                <Target className="w-5 h-5 text-primary" />
                Metas e Bônus
              </CardTitle>
              <Button variant="ghost" size="sm">
                Ver detalhes
                <ChevronRight className="w-4 h-4 ml-1" />
              </Button>
            </div>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Daily Goal */}
              <div className="p-4 rounded-lg bg-muted/50">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-muted-foreground">Meta Diária</span>
                  <Badge variant={totalPoints >= goalPoints ? "default" : "outline"}>
                    {totalPoints >= goalPoints ? "Alcançada!" : `${goalPoints - totalPoints} pts faltam`}
                  </Badge>
                </div>
                <Progress value={(totalPoints / goalPoints) * 100} className="h-2 mb-2" />
                <p className="text-sm text-muted-foreground">
                  {totalPoints}/{goalPoints} pontos · Bônus: R$ 20,00
                </p>
              </div>

              {/* Weekly Goal */}
              <div className="p-4 rounded-lg bg-muted/50">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-muted-foreground">Meta Semanal</span>
                  <Badge variant="outline">62% concluída</Badge>
                </div>
                <Progress value={62} className="h-2 mb-2" />
                <p className="text-sm text-muted-foreground">
                  122/200 pontos · Bônus: R$ 100,00
                </p>
              </div>

              {/* Monthly Goal */}
              <div className="p-4 rounded-lg bg-muted/50">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-muted-foreground">Meta Mensal</span>
                  <Badge variant="outline">45% concluída</Badge>
                </div>
                <Progress value={45} className="h-2 mb-2" />
                <p className="text-sm text-muted-foreground">
                  360/800 pontos · Bônus: R$ 300,00
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default Commissions;
