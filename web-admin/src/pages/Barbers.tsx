import { useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  Plus,
  Search,
  MoreVertical,
  Star,
  TrendingUp,
  Phone,
  Users,
  Award,
  Loader2,
} from "lucide-react";
import { Input } from "@/components/ui/input";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useBarbers } from "@/hooks/useBarbers";
import { useStore } from "@/hooks/useStore";
import { CreateUserDialog } from "@/components/auth/CreateUserDialog";

const levelConfig: Record<string, { label: string; color: string }> = {
  junior: { label: "Júnior", color: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400" },
  professional: { label: "Profissional", color: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" },
  senior: { label: "Sênior", color: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400" },
  master: { label: "Master", color: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400" },
};

const Barbers = () => {
  const { store } = useStore();
  const { barbers, activeBarbers, leaders, isLoading, updateBarber } = useBarbers(store?.id);
  const [searchTerm, setSearchTerm] = useState("");

  const filteredBarbers = barbers.filter(b =>
    b.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (isLoading) {
    return (
      <DashboardLayout title="Barbeiros" subtitle="Gerencie sua equipe">
        <div className="flex items-center justify-center h-64">
          <Loader2 className="w-8 h-8 animate-spin text-primary" />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout
      title="Barbeiros"
      subtitle="Gerencie sua equipe"
    >
      {/* Header Actions */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="Buscar barbeiro..."
            className="pl-9"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <CreateUserDialog storeId={store?.id} />
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
              <Users className="w-6 h-6 text-primary" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Ativos</p>
              <p className="text-2xl font-bold text-foreground">{activeBarbers.length}</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
              <TrendingUp className="w-6 h-6 text-green-600 dark:text-green-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Total Equipe</p>
              <p className="text-2xl font-bold text-foreground">{barbers.length}</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
              <Star className="w-6 h-6 text-amber-600 dark:text-amber-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Líderes</p>
              <p className="text-2xl font-bold text-foreground">{leaders.length}</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-muted flex items-center justify-center">
              <Award className="w-6 h-6 text-muted-foreground" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Multi. Médio</p>
              <p className="text-2xl font-bold text-foreground">
                {barbers.length > 0
                  ? (barbers.reduce((sum, b) => sum + b.level_multiplier, 0) / barbers.length).toFixed(2)
                  : "0"}x
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Barbers Grid */}
      {filteredBarbers.length === 0 ? (
        <Card className="border">
          <CardContent className="p-12 text-center">
            <Users className="w-12 h-12 mx-auto text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">Nenhum barbeiro cadastrado</h3>
            <p className="text-muted-foreground mb-4">
              Adicione os profissionais da sua equipe
            </p>
            <CreateUserDialog storeId={store?.id} />
          </CardContent>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {filteredBarbers.map((barber) => (
            <Card key={barber.id} className="border hover:shadow-md transition-all">
              <CardContent className="p-5">
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-4">
                    <Avatar className="w-14 h-14">
                      <AvatarFallback className="bg-primary/10 text-primary text-lg font-semibold">
                        {barber.initials || barber.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <div className="flex items-center gap-2">
                        <h3 className="font-semibold text-foreground">{barber.name}</h3>
                        {barber.is_leader && (
                          <Badge variant="outline" className="text-amber-500 border-amber-500">
                            Líder
                          </Badge>
                        )}
                      </div>
                      <div className="flex items-center gap-2 mt-1">
                        <Badge className={levelConfig[barber.level]?.color || levelConfig.junior.color}>
                          {levelConfig[barber.level]?.label || barber.level}
                        </Badge>
                        <span className="text-sm text-muted-foreground">
                          {barber.level_multiplier}x multiplicador
                        </span>
                      </div>
                    </div>
                  </div>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon">
                        <MoreVertical className="w-4 h-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end" className="bg-popover">
                      <DropdownMenuItem>Ver perfil</DropdownMenuItem>
                      <DropdownMenuItem>Editar</DropdownMenuItem>
                      <DropdownMenuItem>Ver comissões</DropdownMenuItem>
                      <DropdownMenuItem
                        className="text-destructive"
                        onClick={() => updateBarber({ id: barber.id, is_active: false })}
                      >
                        Desativar
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>

                {/* Info */}
                <div className="grid grid-cols-2 gap-4 text-sm mb-4">
                  <div className="p-3 rounded-lg bg-muted/50">
                    <p className="text-muted-foreground mb-1">Nível</p>
                    <p className="font-semibold text-foreground capitalize">
                      {levelConfig[barber.level]?.label || barber.level}
                    </p>
                  </div>
                  <div className="p-3 rounded-lg bg-muted/50">
                    <p className="text-muted-foreground mb-1">Status</p>
                    <p className="font-semibold text-foreground">
                      {barber.is_active ? (
                        <span className="text-green-500">Ativo</span>
                      ) : (
                        <span className="text-red-500">Inativo</span>
                      )}
                    </p>
                  </div>
                </div>

                {/* Contact */}
                {barber.phone && (
                  <div className="flex items-center gap-4 pt-4 border-t text-sm text-muted-foreground">
                    <div className="flex items-center gap-1">
                      <Phone className="w-3.5 h-3.5" />
                      <span>{barber.phone}</span>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </DashboardLayout>
  );
};

export default Barbers;
