import { useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Plus,
  Search,
  MoreVertical,
  Clock,
  Coins,
  Scissors,
  Edit,
  Trash2,
  Loader2,
} from "lucide-react";
import { Input } from "@/components/ui/input";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Switch } from "@/components/ui/switch";
import { useServices } from "@/hooks/useServices";
import { useStore } from "@/hooks/useStore";
import { useToast } from "@/hooks/use-toast";

const categoryConfig: Record<string, { label: string; color: string }> = {
  corte: { label: "Corte", color: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400" },
  barba: { label: "Barba", color: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400" },
  tratamento: { label: "Tratamento", color: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400" },
  combo: { label: "Combo", color: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" },
};

const Services = () => {
  const { store } = useStore();
  const { services, activeServices, isLoading, updateService, deleteService } = useServices(store?.id);
  const { toast } = useToast();
  const [searchTerm, setSearchTerm] = useState("");

  const filteredServices = services.filter(s =>
    s.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleToggleActive = (id: string, currentStatus: boolean) => {
    updateService({ id, is_active: !currentStatus });
    toast({
      title: currentStatus ? "Serviço desativado" : "Serviço ativado",
      description: `O serviço foi ${currentStatus ? 'desativado' : 'ativado'} com sucesso.`,
    });
  };

  const handleDelete = (id: string, name: string) => {
    deleteService(id);
    toast({
      title: "Serviço excluído",
      description: `${name} foi removido.`,
    });
  };

  if (isLoading) {
    return (
      <DashboardLayout title="Serviços" subtitle="Gerencie os serviços oferecidos">
        <div className="flex items-center justify-center h-64">
          <Loader2 className="w-8 h-8 animate-spin text-primary" />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout
      title="Serviços"
      subtitle="Gerencie os serviços oferecidos"
    >
      {/* Header Actions */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="Buscar serviço..."
            className="pl-9"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <Button variant="premium">
          <Plus className="w-4 h-4 mr-2" />
          Novo Serviço
        </Button>
      </div>

      {/* Summary */}
      <div className="flex items-center gap-4 mb-6">
        <Badge variant="outline" className="px-3 py-1">
          {activeServices.length} serviços ativos
        </Badge>
        <Badge variant="outline" className="px-3 py-1">
          {services.length - activeServices.length} inativos
        </Badge>
      </div>

      {/* Services Grid */}
      {filteredServices.length === 0 ? (
        <Card className="border">
          <CardContent className="p-12 text-center">
            <Scissors className="w-12 h-12 mx-auto text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">Nenhum serviço cadastrado</h3>
            <p className="text-muted-foreground mb-4">
              Adicione os serviços oferecidos na barbearia
            </p>
            <Button variant="premium">
              <Plus className="w-4 h-4 mr-2" />
              Novo Serviço
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredServices.map((service) => (
            <Card
              key={service.id}
              className={`border hover:shadow-md transition-all ${!service.is_active ? "opacity-60" : ""
                }`}
            >
              <CardContent className="p-5">
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
                      <Scissors className="w-6 h-6 text-primary" />
                    </div>
                    <div>
                      <h3 className="font-semibold text-foreground">{service.name}</h3>
                      {service.category && (
                        <Badge className={categoryConfig[service.category]?.color || categoryConfig.corte.color}>
                          {categoryConfig[service.category]?.label || service.category}
                        </Badge>
                      )}
                    </div>
                  </div>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon">
                        <MoreVertical className="w-4 h-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="bg-popover">
                      <DropdownMenuItem>
                        <Edit className="w-4 h-4 mr-2" />
                        Editar
                      </DropdownMenuItem>
                      <DropdownMenuItem
                        className="text-destructive"
                        onClick={() => handleDelete(service.id, service.name)}
                      >
                        <Trash2 className="w-4 h-4 mr-2" />
                        Excluir
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>

                {service.description && (
                  <p className="text-sm text-muted-foreground mb-4">{service.description}</p>
                )}

                <div className="grid grid-cols-3 gap-2 mb-4">
                  <div className="text-center p-2 rounded-lg bg-muted/50">
                    <p className="text-lg font-bold text-foreground">
                      R$ {service.price.toFixed(0)}
                    </p>
                    <p className="text-xs text-muted-foreground">Preço</p>
                  </div>
                  <div className="text-center p-2 rounded-lg bg-muted/50">
                    <div className="flex items-center justify-center gap-1">
                      <Clock className="w-4 h-4 text-muted-foreground" />
                      <span className="font-bold text-foreground">{service.duration_minutes}</span>
                    </div>
                    <p className="text-xs text-muted-foreground">Minutos</p>
                  </div>
                  <div className="text-center p-2 rounded-lg bg-muted/50">
                    <div className="flex items-center justify-center gap-1">
                      <Coins className="w-4 h-4 text-primary" />
                      <span className="font-bold text-foreground">{service.points}</span>
                    </div>
                    <p className="text-xs text-muted-foreground">Pontos</p>
                  </div>
                </div>

                <div className="flex items-center justify-between pt-3 border-t">
                  <div className="flex items-center gap-2">
                    <Switch
                      checked={service.is_active}
                      onCheckedChange={() => handleToggleActive(service.id, service.is_active)}
                    />
                    <span className="text-sm text-muted-foreground">
                      {service.is_active ? "Ativo" : "Inativo"}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </DashboardLayout>
  );
};

export default Services;
