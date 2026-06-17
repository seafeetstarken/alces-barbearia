import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ArrowLeft, Check, Calendar, Clock, User, Scissors, Loader2 } from "lucide-react";
import { useServices } from "@/hooks/useServices";
import { useBarbers } from "@/hooks/useBarbers";
import { useClients } from "@/hooks/useClients";
import { useAppointments } from "@/hooks/useAppointments";
import { useToast } from "@/hooks/use-toast";
import { DataState } from "@/components/ui/data-state";

const DEFAULT_SLOTS = ["09:00", "10:00", "11:00", "14:00", "15:00", "16:00", "17:00"];

const ClientBooking = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const storeId = typeof window !== "undefined" ? localStorage.getItem("active_store_id") ?? undefined : undefined;
  const { activeServices, isLoading: isServicesLoading, error: servicesError } = useServices(storeId);
  const { activeBarbers, isLoading: isBarbersLoading, error: barbersError } = useBarbers(storeId);
  const { activeClients, isLoading: isClientsLoading, error: clientsError } = useClients(storeId);
  const { createAppointment, isCreating } = useAppointments(storeId);
  const [step, setStep] = useState(1);
  const [selectedClient, setSelectedClient] = useState("");
  const [selectedService, setSelectedService] = useState<string | null>(null);
  const [selectedBarber, setSelectedBarber] = useState<string | null>(null);
  const [selectedDate, setSelectedDate] = useState<string | null>(null);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);

  useEffect(() => {
    if (!selectedClient && activeClients.length > 0) {
      setSelectedClient(activeClients[0].id);
    }
  }, [activeClients, selectedClient]);

  const totalSteps = 5;
  const bookingDates = useMemo(() => {
    return Array.from({ length: 7 }, (_, index) => {
      const date = new Date();
      date.setDate(date.getDate() + index);

      return {
        date: date.toISOString().split("T")[0],
        label:
          index === 0
            ? "Hoje"
            : index === 1
            ? "Amanhã"
            : date.toLocaleDateString("pt-BR", { weekday: "short", day: "2-digit" }),
        slots: DEFAULT_SLOTS,
      };
    });
  }, []);

  const isLoading = isServicesLoading || isBarbersLoading || isClientsLoading;
  const hasError = servicesError || barbersError || clientsError;

  const getSelectedServiceData = () => activeServices.find((service) => service.id === selectedService);
  const getSelectedBarberData = () => activeBarbers.find((barber) => barber.id === selectedBarber);
  const getSelectedDateData = () => bookingDates.find((date) => date.date === selectedDate);
  const getSelectedClientData = () => activeClients.find((client) => client.id === selectedClient);

  const handleConfirm = () => {
    if (!storeId || !selectedClient || !selectedService || !selectedBarber || !selectedDate || !selectedTime) {
      return;
    }

    const service = getSelectedServiceData();
    if (!service) {
      return;
    }

    const startsAt = new Date(`${selectedDate}T${selectedTime}:00`);
    const endsAt = new Date(startsAt.getTime() + service.duration_minutes * 60 * 1000);

    createAppointment(
      {
        appointment: {
          store_id: storeId,
          client_id: selectedClient,
          barber_id: selectedBarber,
          starts_at: startsAt.toISOString(),
          ends_at: endsAt.toISOString(),
          status: "confirmed",
          notes: null,
          source: "client",
          created_by: null,
        },
        services: [
          {
            service_id: service.id,
            quantity: 1,
            unit_price: service.price,
            points: service.points,
          },
        ],
      },
      {
        onSuccess: (createdAppointment) => {
          toast({
            title: "Agendamento confirmado",
            description: "Seu horário foi reservado. Finalize no checkout para concluir.",
          });
          navigate(`/client/checkout?type=service&appointmentId=${createdAppointment.id}`);
        },
        onError: () => {
          toast({
            title: "Falha ao agendar",
            description: "Não foi possível reservar o horário agora.",
            variant: "destructive",
          });
        },
      },
    );
  };

  if (!storeId) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState
          variant="empty"
          title="Loja não selecionada"
          description="Selecione uma loja no painel administrativo para agendar."
          action={
            <Button onClick={() => navigate("/stores")} variant="outline">
              Ir para lojas
            </Button>
          }
        />
      </div>
    );
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState variant="loading" title="Carregando agenda" description="Buscando serviços e horários disponíveis." />
      </div>
    );
  }

  if (hasError) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState variant="error" title="Falha ao carregar agenda" description="Tente novamente em alguns instantes." />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <div className="h-[2px] w-full gold-shimmer flex-shrink-0" />
      <header className="bg-background sticky top-0 z-50 px-5 py-4 flex items-center justify-between border-b border-border">
        <div className="flex items-center gap-4">
          <button
            onClick={() => (step > 1 ? setStep(step - 1) : navigate("/client"))}
            className="w-9 h-9 flex items-center justify-center rounded-xl text-muted-foreground hover:text-foreground hover:bg-muted transition-colors -ml-2"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="font-bold tracking-widest text-sm uppercase" style={{ fontFamily: "'Playfair Display', serif" }}>
              Agendar
            </h1>
            <p className="text-[10px] text-muted-foreground uppercase tracking-widest leading-none mt-0.5">
              Passo {step} de {totalSteps}
            </p>
          </div>
        </div>
      </header>

      <div className="h-1 bg-muted w-full">
        <div className="h-full bg-primary transition-all duration-300 ease-out" style={{ width: `${(step / totalSteps) * 100}%` }} />
      </div>

      <main className="flex-1 overflow-y-auto px-5 py-6 pb-24">
        {step === 1 && (
          <div className="animate-fade-up space-y-6">
            <div>
              <h2 className="text-xl font-bold mb-3" style={{ fontFamily: "'Playfair Display', serif" }}>Selecione o cliente</h2>
              <Select value={selectedClient} onValueChange={setSelectedClient}>
                <SelectTrigger className="h-12 rounded-xl">
                  <SelectValue placeholder="Escolha o cliente" />
                </SelectTrigger>
                <SelectContent>
                  {activeClients.map((client) => (
                    <SelectItem key={client.id} value={client.id}>{client.name}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div>
              <h2 className="text-xl font-bold mb-4" style={{ fontFamily: "'Playfair Display', serif" }}>Escolha o serviço</h2>
              <div className="space-y-3">
                {activeServices.map((service) => (
                  <button
                    key={service.id}
                    onClick={() => setSelectedService(service.id)}
                    className={`w-full flex items-center justify-between p-4 rounded-2xl border transition-all text-left ${
                      selectedService === service.id
                        ? "border-primary bg-primary/5"
                        : "border-border bg-card hover:bg-muted/50"
                    }`}
                  >
                    <div>
                      <h3 className="font-semibold text-sm mb-0.5">{service.name}</h3>
                      <p className="text-[11px] text-muted-foreground">{service.duration_minutes} minutos</p>
                    </div>
                    <div className="flex items-center gap-4">
                      <span className="font-bold text-sm">R$ {service.price.toFixed(2)}</span>
                      <div className={`w-5 h-5 rounded-full border flex items-center justify-center ${
                        selectedService === service.id ? "bg-primary border-primary text-[#0d0d0d]" : "border-muted-foreground/30"
                      }`}>
                        {selectedService === service.id && <Check className="w-3.5 h-3.5" />}
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="animate-fade-up">
            <h2 className="text-xl font-bold mb-6" style={{ fontFamily: "'Playfair Display', serif" }}>Escolha o barbeiro</h2>
            <div className="space-y-3">
              {activeBarbers.map((barber) => (
                <button
                  key={barber.id}
                  onClick={() => setSelectedBarber(barber.id)}
                  className={`w-full flex items-center justify-between p-4 rounded-2xl border transition-all text-left ${
                    selectedBarber === barber.id
                      ? "border-primary bg-primary/5"
                      : "border-border bg-card hover:bg-muted/50"
                  }`}
                >
                  <div className="flex items-center gap-4">
                    <div className={`w-12 h-12 rounded-full flex items-center justify-center border ${
                      selectedBarber === barber.id ? "bg-primary/20 border-primary/30" : "bg-muted border-border"
                    }`}>
                      <User className={`w-5 h-5 ${selectedBarber === barber.id ? "text-primary" : "text-muted-foreground"}`} />
                    </div>
                    <div>
                      <h3 className="font-semibold text-sm mb-0.5">{barber.name}</h3>
                      <p className="text-[10px] uppercase tracking-wider text-muted-foreground">Disponível</p>
                    </div>
                  </div>
                  <div className={`w-5 h-5 rounded-full border flex items-center justify-center ${
                    selectedBarber === barber.id ? "bg-primary border-primary text-[#0d0d0d]" : "border-muted-foreground/30"
                  }`}>
                    {selectedBarber === barber.id && <Check className="w-3.5 h-3.5" />}
                  </div>
                </button>
              ))}
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="animate-fade-up">
            <h2 className="text-xl font-bold mb-4" style={{ fontFamily: "'Playfair Display', serif" }}>Escolha o dia</h2>
            <div className="flex gap-3 overflow-x-auto pb-2 -mx-2 px-2" style={{ scrollbarWidth: "none" }}>
              {bookingDates.map((date) => (
                <button
                  key={date.date}
                  onClick={() => {
                    setSelectedDate(date.date);
                    setSelectedTime(null);
                  }}
                  className={`flex-shrink-0 px-5 py-3 rounded-xl border transition-all text-sm font-medium ${
                    selectedDate === date.date
                      ? "bg-primary border-primary text-[#0d0d0d]"
                      : "bg-card border-border text-muted-foreground hover:bg-muted/50"
                  }`}
                >
                  {date.label}
                </button>
              ))}
            </div>
          </div>
        )}

        {step === 4 && (
          <div className="animate-fade-up">
            <h2 className="text-xl font-bold mb-4" style={{ fontFamily: "'Playfair Display', serif" }}>Escolha o horário</h2>
            <div className="grid grid-cols-3 gap-3">
              {getSelectedDateData()?.slots.map((slot) => (
                <button
                  key={slot}
                  onClick={() => setSelectedTime(slot)}
                  className={`py-3 rounded-xl border transition-all text-sm font-semibold ${
                    selectedTime === slot
                      ? "bg-primary border-primary text-[#0d0d0d]"
                      : "bg-card border-border text-foreground hover:bg-muted"
                  }`}
                >
                  {slot}
                </button>
              ))}
            </div>
          </div>
        )}

        {step === 5 && (
          <div className="animate-fade-up">
            <h2 className="text-xl font-bold mb-6" style={{ fontFamily: "'Playfair Display', serif" }}>Resumo</h2>
            <div className="bg-card border border-border rounded-2xl p-5 mb-8">
              <div className="space-y-5">
                <div className="flex items-start gap-4">
                  <div className="w-10 h-10 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center flex-shrink-0">
                    <User className="w-4 h-4 text-primary" />
                  </div>
                  <div>
                    <p className="text-[10px] uppercase tracking-widest text-muted-foreground mb-1">Cliente</p>
                    <p className="font-semibold text-sm">{getSelectedClientData()?.name}</p>
                  </div>
                </div>

                <div className="w-full h-px bg-border" />

                <div className="flex items-start gap-4">
                  <div className="w-10 h-10 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center flex-shrink-0">
                    <Scissors className="w-4 h-4 text-primary" />
                  </div>
                  <div>
                    <p className="text-[10px] uppercase tracking-widest text-muted-foreground mb-1">Serviço</p>
                    <p className="font-semibold text-sm">{getSelectedServiceData()?.name}</p>
                    <p className="text-xs text-muted-foreground mt-0.5">{getSelectedServiceData()?.duration_minutes} min</p>
                  </div>
                </div>

                <div className="w-full h-px bg-border" />

                <div className="flex items-start gap-4">
                  <div className="w-10 h-10 rounded-full bg-primary/10 border border-primary/20 flex items-center justify-center flex-shrink-0">
                    <Calendar className="w-4 h-4 text-primary" />
                  </div>
                  <div>
                    <p className="text-[10px] uppercase tracking-widest text-muted-foreground mb-1">Data e Hora</p>
                    <p className="font-semibold text-sm">{getSelectedDateData()?.label}, {selectedTime}</p>
                  </div>
                </div>
              </div>

              <div className="mt-6 pt-5 border-t border-border flex justify-between items-center">
                <span className="text-xs uppercase tracking-widest text-muted-foreground">Total</span>
                <span className="text-xl font-bold text-primary" style={{ fontFamily: "'Playfair Display', serif" }}>
                  R$ {getSelectedServiceData()?.price.toFixed(2)}
                </span>
              </div>
            </div>
          </div>
        )}
      </main>

      <div className="fixed bottom-0 left-0 right-0 p-5 bg-background border-t border-border z-50">
        <Button
          className="w-full h-12 rounded-xl text-sm font-semibold gold-shimmer text-[#0d0d0d] border-0 hover:opacity-90"
          disabled={
            isCreating ||
            (step === 1 && (!selectedClient || !selectedService)) ||
            (step === 2 && !selectedBarber) ||
            (step === 3 && !selectedDate) ||
            (step === 4 && !selectedTime)
          }
          onClick={() => (step < 5 ? setStep(step + 1) : handleConfirm())}
        >
          {isCreating ? (
            <span className="flex items-center justify-center gap-2">
              <Loader2 className="w-4 h-4 animate-spin" />
              Confirmando
            </span>
          ) : step < 5 ? (
            "Continuar"
          ) : (
            "Confirmar Agendamento"
          )}
        </Button>
      </div>
    </div>
  );
};

export default ClientBooking;
