import { useNavigate } from "react-router-dom";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft, Clock, Scissors } from "lucide-react";

const mockServices = [
  { id: 1, name: "Corte Masculino", price: 45, duration: 30, description: "Corte clássico ou moderno" },
  { id: 2, name: "Corte + Barba", price: 70, duration: 50, description: "Combo completo" },
  { id: 3, name: "Barba", price: 35, duration: 25, description: "Barba completa com toalha quente" },
  { id: 4, name: "Degradê", price: 55, duration: 40, description: "Corte com degradê personalizado" },
  { id: 5, name: "Pigmentação", price: 80, duration: 45, description: "Pigmentação para barba ou cabelo" },
  { id: 6, name: "Sobrancelha", price: 20, duration: 15, description: "Design de sobrancelha" },
  { id: 7, name: "Hidratação", price: 40, duration: 30, description: "Tratamento capilar" },
  { id: 8, name: "Relaxamento", price: 90, duration: 60, description: "Relaxamento capilar completo" },
];

const ClientServices = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="bg-card border-b border-border sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4 flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => navigate("/client")}>
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <h1 className="font-semibold">Nossos Serviços</h1>
        </div>
      </header>

      <main className="container mx-auto px-4 py-6">
        <div className="space-y-4">
          {mockServices.map((service) => (
            <Card key={service.id}>
              <CardContent className="p-4">
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-medium">{service.name}</h3>
                    </div>
                    <p className="text-sm text-muted-foreground mb-2">{service.description}</p>
                    <div className="flex items-center gap-3 text-sm text-muted-foreground">
                      <span className="flex items-center gap-1">
                        <Clock className="w-4 h-4" />
                        {service.duration} min
                      </span>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-lg font-bold text-primary">R$ {service.price}</p>
                    <Button 
                      size="sm" 
                      className="mt-2"
                      onClick={() => navigate("/client/booking")}
                    >
                      Agendar
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      </main>
    </div>
  );
};

export default ClientServices;
