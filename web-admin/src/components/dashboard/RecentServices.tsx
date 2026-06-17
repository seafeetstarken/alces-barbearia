import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Scissors, Clock } from "lucide-react";
import { Button } from "@/components/ui/button";
import { DataState } from "@/components/ui/data-state";

interface Service {
  id: string;
  clientName: string;
  barberName: string;
  serviceName: string;
  price: number;
  points: number;
  time: string;
  paymentMethod: "pix" | "card" | "cash";
}

const paymentLabels = {
  pix: "PIX",
  card: "Cartão",
  cash: "Dinheiro",
};

interface RecentServicesProps {
  services: Service[];
  isLoading?: boolean;
  onViewAll?: () => void;
}

const RecentServices = ({ services, isLoading, onViewAll }: RecentServicesProps) => {
  return (
    <Card className="border">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg font-semibold">Últimos Atendimentos</CardTitle>
          <Button variant="link" className="h-auto p-0 text-sm" onClick={onViewAll}>
            Ver todos
          </Button>
        </div>
      </CardHeader>
      <CardContent className="p-0">
        {isLoading ? (
          <div className="p-6">
            <DataState
              variant="loading"
              title="Carregando atendimentos"
              description="Estamos atualizando os últimos registros."
            />
          </div>
        ) : services.length === 0 ? (
          <div className="p-6">
            <DataState
              variant="empty"
              title="Nenhum atendimento hoje"
              description="Assim que um serviço for registrado, ele aparece aqui."
            />
          </div>
        ) : (
          <div className="divide-y divide-border">
            {services.map((service) => (
              <div
                key={service.id}
                className="flex items-center gap-4 px-6 py-4 hover:bg-muted/50 transition-colors"
              >
                <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center shrink-0">
                  <Scissors className="w-5 h-5 text-primary" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2">
                    <p className="font-medium text-foreground truncate">{service.clientName}</p>
                    <Badge variant="secondary" className="text-xs">
                      {service.points} pt{service.points > 1 ? "s" : ""}
                    </Badge>
                  </div>
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <span>{service.serviceName}</span>
                    <span>•</span>
                    <span>{service.barberName}</span>
                  </div>
                </div>
                <div className="text-right shrink-0">
                  <p className="font-semibold text-foreground">R$ {service.price.toFixed(2)}</p>
                  <div className="flex items-center gap-1 justify-end text-sm text-muted-foreground">
                    <Clock className="w-3 h-3" />
                    <span>{service.time}</span>
                    <span>•</span>
                    <span>{paymentLabels[service.paymentMethod]}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

export default RecentServices;
