import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { ArrowLeft, Calendar, Clock, User, X } from "lucide-react";
import { useClients } from "@/hooks/useClients";
import { useAppointments } from "@/hooks/useAppointments";
import { DataState } from "@/components/ui/data-state";
import { useToast } from "@/hooks/use-toast";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";

const ClientAppointments = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [activeTab, setActiveTab] = useState("upcoming");
  const storeId = typeof window !== "undefined" ? localStorage.getItem("active_store_id") ?? undefined : undefined;
  const { activeClients, isLoading: isClientsLoading } = useClients(storeId);
  const clientId = activeClients[0]?.id;
  const { appointments, isLoading, error, updateAppointmentStatus, isUpdatingStatus } = useAppointments(storeId, clientId);

  const getStatusBadge = (status: string) => {
    const statusMap: Record<string, { label: string; variant: "default" | "secondary" | "destructive" | "outline" }> = {
      confirmed: { label: "Confirmado", variant: "secondary" },
      scheduled: { label: "Agendado", variant: "secondary" },
      checked_in: { label: "Em atendimento", variant: "secondary" },
      completed: { label: "Concluído", variant: "default" },
      canceled: { label: "Cancelado", variant: "destructive" },
      no_show: { label: "Não compareceu", variant: "destructive" },
    };
    const config = statusMap[status] ?? { label: status, variant: "outline" as const };

    return <Badge variant={config.variant}>{config.label}</Badge>;
  };

  const formatDate = (date: string) =>
    new Date(date).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "short",
      year: "numeric",
    });

  const formatTime = (date: string) =>
    new Date(date).toLocaleTimeString("pt-BR", {
      hour: "2-digit",
      minute: "2-digit",
    });

  const now = new Date();
  const upcomingAppointments = appointments.filter((appointment) => {
    const startsAt = new Date(appointment.starts_at);
    return startsAt >= now && appointment.status !== "canceled" && appointment.status !== "completed";
  });
  const pastAppointments = appointments.filter((appointment) => {
    const startsAt = new Date(appointment.starts_at);
    return startsAt < now || appointment.status === "completed" || appointment.status === "canceled";
  });

  if (!storeId) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState
          variant="empty"
          title="Loja não selecionada"
          description="Selecione uma loja no painel administrativo para ver os horários."
          action={
            <Button variant="outline" onClick={() => navigate("/stores")}>
              Ir para lojas
            </Button>
          }
        />
      </div>
    );
  }

  if (isLoading || isClientsLoading) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState variant="loading" title="Carregando horários" description="Buscando seus agendamentos mais recentes." />
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState variant="error" title="Falha ao carregar horários" description="Tente novamente em alguns instantes." />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <header className="bg-card border-b border-border sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4 flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => navigate("/client")}>
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <h1 className="font-semibold">Meus Agendamentos</h1>
        </div>
      </header>

      <main className="container mx-auto px-4 py-6">
        <Tabs value={activeTab} onValueChange={setActiveTab}>
          <TabsList className="grid w-full grid-cols-2 mb-6">
            <TabsTrigger value="upcoming">Próximos ({upcomingAppointments.length})</TabsTrigger>
            <TabsTrigger value="past">Histórico ({pastAppointments.length})</TabsTrigger>
          </TabsList>

          <TabsContent value="upcoming" className="space-y-4">
            {upcomingAppointments.map((appointment) => (
                <Card key={appointment.id}>
                  <CardContent className="p-4">
                    <div className="flex justify-between items-start mb-3">
                      <div>
                        <h3 className="font-medium">{appointment.services[0]?.service?.name ?? "Serviço"}</h3>
                        {getStatusBadge(appointment.status)}
                      </div>
                      <span className="font-semibold">R$ {(appointment.services[0]?.unit_price ?? 0).toFixed(2)}</span>
                    </div>

                    <div className="space-y-2 text-sm text-muted-foreground mb-4">
                      <div className="flex items-center gap-2">
                        <User className="w-4 h-4" />
                        <span>{appointment.barber?.name ?? "Barbeiro não informado"}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Calendar className="w-4 h-4" />
                        <span>{formatDate(appointment.starts_at)}</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Clock className="w-4 h-4" />
                        <span>{formatTime(appointment.starts_at)}</span>
                      </div>
                    </div>

                    <div className="flex gap-2">
                      <Button variant="outline" className="flex-1" onClick={() => navigate("/client/booking")}>
                        Remarcar
                      </Button>
                      <AlertDialog>
                        <AlertDialogTrigger asChild>
                          <Button variant="destructive" size="icon">
                            <X className="w-4 h-4" />
                          </Button>
                        </AlertDialogTrigger>
                        <AlertDialogContent>
                          <AlertDialogHeader>
                            <AlertDialogTitle>Cancelar agendamento?</AlertDialogTitle>
                            <AlertDialogDescription>
                              Tem certeza que deseja cancelar este agendamento?
                            </AlertDialogDescription>
                          </AlertDialogHeader>
                          <AlertDialogFooter>
                            <AlertDialogCancel>Voltar</AlertDialogCancel>
                            <AlertDialogAction
                              onClick={() =>
                                updateAppointmentStatus(
                                  { id: appointment.id, status: "canceled" },
                                  {
                                    onSuccess: () =>
                                      toast({
                                        title: "Agendamento cancelado",
                                        description: "O horário foi cancelado com sucesso.",
                                      }),
                                    onError: () =>
                                      toast({
                                        title: "Falha ao cancelar",
                                        description: "Não foi possível cancelar agora.",
                                        variant: "destructive",
                                      }),
                                  },
                                )
                              }
                              disabled={isUpdatingStatus}
                            >
                              Confirmar Cancelamento
                            </AlertDialogAction>
                          </AlertDialogFooter>
                        </AlertDialogContent>
                      </AlertDialog>
                    </div>
                  </CardContent>
                </Card>
              ))}
            {upcomingAppointments.length === 0 && (
              <DataState
                variant="empty"
                title="Sem próximos horários"
                description="Você ainda não possui agendamentos futuros."
                action={
                  <Button onClick={() => navigate("/client/booking")}>
                    Agendar horário
                  </Button>
                }
              />
            )}
          </TabsContent>

          <TabsContent value="past" className="space-y-4">
            {pastAppointments.map((appointment) => (
              <Card key={appointment.id} className="opacity-80">
                <CardContent className="p-4">
                  <div className="flex justify-between items-start mb-3">
                    <div>
                      <h3 className="font-medium">{appointment.services[0]?.service?.name ?? "Serviço"}</h3>
                      {getStatusBadge(appointment.status)}
                    </div>
                    <span className="font-semibold">R$ {(appointment.services[0]?.unit_price ?? 0).toFixed(2)}</span>
                  </div>

                  <div className="space-y-2 text-sm text-muted-foreground">
                    <div className="flex items-center gap-2">
                      <User className="w-4 h-4" />
                      <span>{appointment.barber?.name ?? "Barbeiro não informado"}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Calendar className="w-4 h-4" />
                      <span>{formatDate(appointment.starts_at)} às {formatTime(appointment.starts_at)}</span>
                    </div>
                  </div>

                  {appointment.status === "completed" && (
                    <Button variant="outline" className="w-full mt-4" onClick={() => navigate("/client/booking")}>
                      Agendar Novamente
                    </Button>
                  )}
                </CardContent>
              </Card>
            ))}
            {pastAppointments.length === 0 && (
              <DataState
                variant="empty"
                title="Sem histórico"
                description="Seus atendimentos concluídos aparecerão aqui."
              />
            )}
          </TabsContent>
        </Tabs>
      </main>
    </div>
  );
};

export default ClientAppointments;
