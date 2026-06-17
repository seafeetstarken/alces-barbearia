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
  Phone,
  AlertTriangle,
  Ban,
  UserCheck,
  Loader2,
  Users,
} from "lucide-react";
import { Input } from "@/components/ui/input";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs";
import { useClients } from "@/hooks/useClients";
import { useStore } from "@/hooks/useStore";
import { useCampaigns } from "@/hooks/useCampaigns";
import type { Client } from "@/lib/supabase/types";

const ClientCard = ({ client, onStatusChange }: {
  client: Client;
  onStatusChange: (id: string, status: string) => void;
}) => {
  const initials = client.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);

  return (
    <Card className="border hover:shadow-md transition-all">
      <CardContent className="p-5">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-center gap-3">
            <Avatar className="w-12 h-12">
              <AvatarFallback className="bg-primary/10 text-primary font-medium">
                {initials}
              </AvatarFallback>
            </Avatar>
            <div>
              <div className="flex items-center gap-2">
                <h3 className="font-semibold text-foreground">{client.name}</h3>
                {client.status === "blacklist" && (
                  <Badge variant="destructive" className="text-xs">
                    <Ban className="w-3 h-3 mr-1" />
                    Bloqueado
                  </Badge>
                )}
                {client.status === "inactive" && (
                  <Badge variant="secondary" className="text-xs">
                    <AlertTriangle className="w-3 h-3 mr-1" />
                    Inativo
                  </Badge>
                )}
              </div>
              {client.phone && (
                <div className="flex items-center gap-1 text-sm text-muted-foreground">
                  <Phone className="w-3.5 h-3.5" />
                  <span>{client.phone}</span>
                </div>
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
              <DropdownMenuItem>Ver histórico</DropdownMenuItem>
              <DropdownMenuItem>Editar</DropdownMenuItem>
              <DropdownMenuItem>Enviar mensagem</DropdownMenuItem>
              {client.status !== "blacklist" ? (
                <DropdownMenuItem
                  className="text-destructive"
                  onClick={() => onStatusChange(client.id, 'blacklist')}
                >
                  Bloquear
                </DropdownMenuItem>
              ) : (
                <DropdownMenuItem onClick={() => onStatusChange(client.id, 'active')}>
                  Desbloquear
                </DropdownMenuItem>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        </div>

        <div className="grid grid-cols-2 gap-2 mb-4">
          <div className="text-center p-2 rounded-lg bg-muted/50">
            <p className="text-lg font-bold text-foreground">{client.total_visits || 0}</p>
            <p className="text-xs text-muted-foreground">Visitas</p>
          </div>
          <div className="text-center p-2 rounded-lg bg-muted/50">
            <p className="text-lg font-bold text-foreground">
              {client.last_visit_at ? new Date(client.last_visit_at).toLocaleDateString('pt-BR') : '-'}
            </p>
            <p className="text-xs text-muted-foreground">Última visita</p>
          </div>
        </div>

        {client.notes && (
          <div className="mt-3 p-2 rounded-lg bg-amber-50 dark:bg-amber-900/20 text-sm text-amber-700 dark:text-amber-400">
            {client.notes}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

const Clients = () => {
  const { store } = useStore();
  const {
    clients,
    activeClients,
    inactiveClients,
    blacklistClients,
    isLoading,
    updateClient
  } = useClients(store?.id);
  const { campaigns, isLoading: isCampaignsLoading } = useCampaigns(store?.id);
  const [searchTerm, setSearchTerm] = useState("");

  const handleStatusChange = (id: string, status: string) => {
    updateClient({ id, status: status as Client['status'] });
  };

  const filterClients = (clientList: Client[]) => {
    return clientList.filter(c =>
      c.name.toLowerCase().includes(searchTerm.toLowerCase())
    );
  };

  if (isLoading) {
    return (
      <DashboardLayout title="Clientes" subtitle="Gerencie sua base de clientes">
        <div className="flex items-center justify-center h-64">
          <Loader2 className="w-8 h-8 animate-spin text-primary" />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout
      title="Clientes"
      subtitle="Gerencie sua base de clientes"
    >
      {/* Header Actions */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="Buscar cliente..."
            className="pl-9"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <Button variant="premium">
          <Plus className="w-4 h-4 mr-2" />
          Novo Cliente
        </Button>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
              <UserCheck className="w-6 h-6 text-green-600 dark:text-green-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Ativos</p>
              <p className="text-2xl font-bold text-foreground">{activeClients.length}</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
              <AlertTriangle className="w-6 h-6 text-amber-600 dark:text-amber-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Inativos</p>
              <p className="text-2xl font-bold text-foreground">{inactiveClients.length}</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
              <Ban className="w-6 h-6 text-destructive" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Bloqueados</p>
              <p className="text-2xl font-bold text-foreground">{blacklistClients.length}</p>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card className="border mb-6">
        <CardContent className="p-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-semibold uppercase tracking-wider text-muted-foreground">
              CRM e Campanhas
            </h3>
            <Badge variant="outline">{campaigns.length} campanhas</Badge>
          </div>
          {isCampaignsLoading ? (
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <Loader2 className="w-4 h-4 animate-spin" />
              Carregando resultados de campanhas...
            </div>
          ) : campaigns.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              Nenhuma campanha cadastrada para esta loja.
            </p>
          ) : (
            <div className="space-y-3">
              {campaigns.slice(0, 4).map((campaign) => (
                <div
                  key={campaign.id}
                  className="rounded-lg border border-border p-3 flex items-center justify-between gap-3"
                >
                  <div>
                    <p className="font-medium text-sm">{campaign.name}</p>
                    <p className="text-xs text-muted-foreground">
                      {campaign.channel} • {campaign.objective}
                    </p>
                  </div>
                  <div className="text-right">
                    <Badge variant="secondary" className="mb-1 capitalize">
                      {campaign.status}
                    </Badge>
                    <p className="text-xs text-muted-foreground">
                      {campaign.converted} conv. • R$ {campaign.revenue_amount.toFixed(2)}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Tabs */}
      <Tabs defaultValue="active" className="w-full">
        <TabsList className="mb-4">
          <TabsTrigger value="active">
            Ativos ({activeClients.length})
          </TabsTrigger>
          <TabsTrigger value="inactive">
            Inativos ({inactiveClients.length})
          </TabsTrigger>
          <TabsTrigger value="blacklist">
            Bloqueados ({blacklistClients.length})
          </TabsTrigger>
        </TabsList>

        <TabsContent value="active">
          {filterClients(activeClients).length === 0 ? (
            <Card className="border">
              <CardContent className="p-12 text-center">
                <Users className="w-12 h-12 mx-auto text-muted-foreground mb-4" />
                <h3 className="text-lg font-semibold mb-2">Nenhum cliente cadastrado</h3>
                <p className="text-muted-foreground mb-4">
                  Adicione clientes para acompanhar suas visitas
                </p>
                <Button variant="premium">
                  <Plus className="w-4 h-4 mr-2" />
                  Novo Cliente
                </Button>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filterClients(activeClients).map((client) => (
                <ClientCard key={client.id} client={client} onStatusChange={handleStatusChange} />
              ))}
            </div>
          )}
        </TabsContent>

        <TabsContent value="inactive">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filterClients(inactiveClients).map((client) => (
              <ClientCard key={client.id} client={client} onStatusChange={handleStatusChange} />
            ))}
          </div>
        </TabsContent>

        <TabsContent value="blacklist">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {filterClients(blacklistClients).map((client) => (
              <ClientCard key={client.id} client={client} onStatusChange={handleStatusChange} />
            ))}
          </div>
        </TabsContent>
      </Tabs>
    </DashboardLayout>
  );
};

export default Clients;
