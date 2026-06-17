import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { Progress } from "@/components/ui/progress";
import { Button } from "@/components/ui/button";
import { DataState } from "@/components/ui/data-state";

interface Barber {
  id: string;
  name: string;
  initials: string;
  points: number;
  maxPoints: number;
  services: number;
  revenue: number;
}

interface BarberPerformanceProps {
  barbers: Barber[];
  isLoading?: boolean;
  onViewDetails?: () => void;
}

const BarberPerformance = ({ barbers, isLoading, onViewDetails }: BarberPerformanceProps) => {
  return (
    <Card className="border">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg font-semibold">Desempenho do Time</CardTitle>
          <Button variant="link" className="h-auto p-0 text-sm" onClick={onViewDetails}>
            Ver detalhes
          </Button>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        {isLoading ? (
          <DataState
            variant="loading"
            title="Carregando desempenho"
            description="Aguarde enquanto calculamos os pontos do time."
          />
        ) : barbers.length === 0 ? (
          <DataState
            variant="empty"
            title="Sem pontuação no período"
            description="Os pontos aparecem após os primeiros atendimentos."
          />
        ) : (
          barbers.map((barber) => (
            <div key={barber.id} className="space-y-2">
              <div className="flex items-center gap-3">
                <Avatar className="w-8 h-8">
                  <AvatarFallback className="bg-primary/10 text-primary text-xs font-medium">
                    {barber.initials}
                  </AvatarFallback>
                </Avatar>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <p className="font-medium text-foreground text-sm truncate">{barber.name}</p>
                    <p className="text-sm font-semibold text-foreground">{barber.points} pts</p>
                  </div>
                  <div className="flex items-center justify-between text-xs text-muted-foreground">
                    <span>{barber.services} atendimentos</span>
                    <span>R$ {barber.revenue.toFixed(2)}</span>
                  </div>
                </div>
              </div>
              <Progress value={(barber.points / barber.maxPoints) * 100} className="h-1.5" />
            </div>
          ))
        )}
      </CardContent>
    </Card>
  );
};

export default BarberPerformance;
