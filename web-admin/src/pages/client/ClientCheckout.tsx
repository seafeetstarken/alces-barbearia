import { useMemo, useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { ArrowLeft, CreditCard, Wallet, QrCode, CheckCircle2, Shield, Lock } from "lucide-react";
import { DataState } from "@/components/ui/data-state";
import { useAppointments } from "@/hooks/useAppointments";
import { useCashier } from "@/hooks/useCashier";
import { useBilling } from "@/hooks/useBilling";
import { useCashback } from "@/hooks/useCashback";
import { useToast } from "@/hooks/use-toast";

const ClientCheckout = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const [searchParams] = useSearchParams();
  const type = searchParams.get("type") || "service";
  const appointmentId = searchParams.get("appointmentId");
  const selectedPlanId = searchParams.get("planId");
  const storeId = typeof window !== "undefined" ? localStorage.getItem("active_store_id") ?? undefined : undefined;
  const [paymentMethod, setPaymentMethod] = useState("card");
  const [isProcessing, setIsProcessing] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [newCard, setNewCard] = useState({ number: "", expiry: "", cvv: "", name: "" });
  const { appointments, isLoading: isLoadingAppointments, updateAppointmentStatusAsync } = useAppointments(storeId);
  const appointment = useMemo(
    () => appointments.find((item) => item.id === appointmentId),
    [appointments, appointmentId],
  );
  const { createTransactionAsync } = useCashier(storeId);
  const { plans, subscription, updateSubscriptionStatusAsync, isLoading: isLoadingBilling } = useBilling(storeId);
  const activePlan = useMemo(
    () => plans.find((plan) => plan.id === selectedPlanId) ?? plans[0] ?? null,
    [plans, selectedPlanId],
  );
  const { createMovementAsync } = useCashback(storeId, appointment?.client_id ?? undefined);

  const orderDetailsMap: Record<string, { title: string; subtitle: string; amount: number }> = {
    service: {
      title: appointment?.services[0]?.service?.name ?? "Atendimento",
      subtitle: appointment
        ? `${appointment.barber?.name ?? "Barbeiro"} • ${new Date(appointment.starts_at).toLocaleString("pt-BR")}`
        : "Atendimento",
      amount: appointment?.services.reduce((sum, item) => sum + item.unit_price * item.quantity, 0) ?? 0,
    },
    product: { title: "Compra de produtos", subtitle: "Carrinho da loja", amount: 145 },
    subscription: {
      title: activePlan?.name ?? "Assinatura",
      subtitle: "Assinatura mensal",
      amount: activePlan ? activePlan.amount_cents / 100 : 99,
    },
  };
  const orderDetails = orderDetailsMap[type as keyof typeof orderDetailsMap] || orderDetailsMap.service;

  const handlePayment = async () => {
    try {
      if (!storeId) {
        throw new Error("Loja não encontrada");
      }

      setIsProcessing(true);

      if (type === "service") {
        if (!appointment) {
          throw new Error("Agendamento não encontrado");
        }

        const amount = appointment.services.reduce((sum, item) => sum + item.unit_price * item.quantity, 0);

        await createTransactionAsync({
          transaction: {
            store_id: storeId,
            barber_id: appointment.barber_id,
            client_id: appointment.client_id,
            type: "service",
            description: appointment.services[0]?.service?.name ?? "Atendimento",
            amount,
            payment_method: paymentMethod === "pix" ? "pix" : paymentMethod === "cash" ? "cash" : "card",
            cash_register_id: null,
          },
          items: appointment.services.map((service) => ({
            service_id: service.service_id,
            product_id: null,
            quantity: service.quantity,
            unit_price: service.unit_price,
            points: service.points,
          })),
        });

        await updateAppointmentStatusAsync({ id: appointment.id, status: "completed" });

        if (appointment.client_id && amount > 0) {
          await createMovementAsync({
            movementType: "credit",
            amount: Number((amount * 0.05).toFixed(2)),
            description: "Cashback de atendimento",
            appointmentId: appointment.id,
          });
        }
      }

      if (type === "subscription") {
        if (!activePlan) {
          throw new Error("Plano não encontrado");
        }

        await updateSubscriptionStatusAsync({
          planId: activePlan.id,
          status: "active",
          providerSubscriptionId: subscription?.provider_subscription_id ?? `asaas-${Date.now()}`,
        });
      }

      if (type === "product") {
        await createTransactionAsync({
          transaction: {
            store_id: storeId,
            barber_id: null,
            client_id: appointment?.client_id ?? null,
            type: "product",
            description: "Compra de produtos",
            amount: orderDetails.amount,
            payment_method: paymentMethod === "pix" ? "pix" : paymentMethod === "cash" ? "cash" : "card",
            cash_register_id: null,
          },
        });
      }

      setIsSuccess(true);
    } catch (error) {
      toast({
        title: "Falha no pagamento",
        description: error instanceof Error ? error.message : "Não foi possível processar a cobrança.",
        variant: "destructive",
      });
    } finally {
      setIsProcessing(false);
    }
  };

  if (isSuccess) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center p-4">
        <Card className="w-full max-w-md text-center">
          <CardContent className="pt-12 pb-8 space-y-6">
            <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center mx-auto">
              <CheckCircle2 className="w-10 h-10 text-primary" />
            </div>
            <div>
              <h2 className="text-2xl font-semibold mb-2">Pagamento Confirmado</h2>
              <p className="text-muted-foreground">
                {type === "subscription" 
                  ? "Bem-vindo ao Clube de Corte! Sua assinatura está ativa."
                  : "Seu pagamento foi processado com sucesso."}
              </p>
            </div>
            <div className="bg-muted/50 rounded-lg p-4">
              <p className="text-sm text-muted-foreground">Valor pago</p>
              <p className="text-2xl font-bold">R$ {orderDetails.amount}</p>
            </div>
            <Button 
              className="w-full" 
              size="lg"
              onClick={() => navigate(type === "service" ? "/client/appointments" : type === "subscription" ? "/client/subscription" : "/client")}
            >
              {type === "service" ? "Ver Meus Agendamentos" : type === "subscription" ? "Ver Assinatura" : "Voltar ao Início"}
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  if (!storeId) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState
          variant="empty"
          title="Loja não selecionada"
          description="Selecione uma loja no painel administrativo antes de usar checkout."
          action={
            <Button variant="outline" onClick={() => navigate("/stores")}>
              Ir para lojas
            </Button>
          }
        />
      </div>
    );
  }

  if ((type === "service" && isLoadingAppointments) || (type === "subscription" && isLoadingBilling)) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState variant="loading" title="Preparando checkout" description="Carregando dados do pedido." />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <header className="bg-card border-b border-border sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4 flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => navigate(-1)}>
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div>
            <h1 className="font-semibold">Pagamento</h1>
            <p className="text-sm text-muted-foreground">Finalize sua compra</p>
          </div>
        </div>
      </header>

      <main className="container mx-auto px-4 py-6 space-y-6 max-w-lg">
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base font-medium">Resumo</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="flex justify-between items-center">
              <div>
                <p className="font-medium">{orderDetails.title}</p>
                <p className="text-sm text-muted-foreground">{orderDetails.subtitle}</p>
              </div>
              <p className="text-xl font-bold">R$ {orderDetails.amount}</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base font-medium">Forma de Pagamento</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <RadioGroup value={paymentMethod} onValueChange={setPaymentMethod}>
              <div className="flex items-center space-x-3 p-3 rounded-lg border border-border hover:bg-muted/50 transition-colors">
                <RadioGroupItem value="card" id="card" />
                <Label htmlFor="card" className="flex-1 flex items-center gap-3 cursor-pointer">
                  <div className="w-10 h-7 rounded bg-muted flex items-center justify-center">
                    <CreditCard className="w-5 h-5 text-muted-foreground" />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium">Cartão</p>
                    <p className="text-xs text-muted-foreground">Crédito ou débito</p>
                  </div>
                </Label>
              </div>

              <div className="flex items-start space-x-3 p-3 rounded-lg border border-border">
                <RadioGroupItem value="new-card" id="new-card" className="mt-1" />
                <div className="flex-1">
                  <Label htmlFor="new-card" className="font-medium cursor-pointer">
                    Novo cartão
                  </Label>
                  
                  {paymentMethod === "new-card" && (
                    <div className="mt-4 space-y-4">
                      <div className="space-y-2">
                        <Label className="text-sm">Número do cartão</Label>
                        <Input 
                          placeholder="0000 0000 0000 0000"
                          value={newCard.number}
                          onChange={(e) => setNewCard({...newCard, number: e.target.value})}
                        />
                      </div>
                      <div className="grid grid-cols-2 gap-3">
                        <div className="space-y-2">
                          <Label className="text-sm">Validade</Label>
                          <Input 
                            placeholder="MM/AA"
                            value={newCard.expiry}
                            onChange={(e) => setNewCard({...newCard, expiry: e.target.value})}
                          />
                        </div>
                        <div className="space-y-2">
                          <Label className="text-sm">CVV</Label>
                          <Input 
                            placeholder="123"
                            value={newCard.cvv}
                            onChange={(e) => setNewCard({...newCard, cvv: e.target.value})}
                          />
                        </div>
                      </div>
                      <div className="space-y-2">
                        <Label className="text-sm">Nome no cartão</Label>
                        <Input 
                          placeholder="Como está no cartão"
                          value={newCard.name}
                          onChange={(e) => setNewCard({...newCard, name: e.target.value})}
                        />
                      </div>
                    </div>
                  )}
                </div>
              </div>

              <div className="flex items-center space-x-3 p-3 rounded-lg border border-border hover:bg-muted/50 transition-colors">
                <RadioGroupItem value="pix" id="pix" />
                <Label htmlFor="pix" className="flex-1 flex items-center gap-3 cursor-pointer">
                  <div className="w-10 h-7 rounded bg-muted flex items-center justify-center">
                    <QrCode className="w-5 h-5 text-muted-foreground" />
                  </div>
                  <div>
                    <p className="font-medium">PIX</p>
                    <p className="text-xs text-muted-foreground">Pagamento instantâneo</p>
                  </div>
                </Label>
              </div>

              <div className="flex items-center space-x-3 p-3 rounded-lg border border-border hover:bg-muted/50 transition-colors">
                <RadioGroupItem value="cash" id="cash" />
                <Label htmlFor="cash" className="flex-1 flex items-center gap-3 cursor-pointer">
                  <div className="w-10 h-7 rounded bg-muted flex items-center justify-center">
                    <Wallet className="w-5 h-5 text-muted-foreground" />
                  </div>
                  <div>
                    <p className="font-medium">Dinheiro</p>
                    <p className="text-xs text-muted-foreground">Pagamento presencial</p>
                  </div>
                </Label>
              </div>
            </RadioGroup>
          </CardContent>
        </Card>

        <div className="flex items-center justify-center gap-2 text-sm text-muted-foreground">
          <Shield className="w-4 h-4" />
          <span>Pagamento 100% seguro</span>
          <Lock className="w-4 h-4" />
        </div>

        <Button 
          className="w-full h-14 text-base font-medium" 
          size="lg"
          onClick={handlePayment}
          disabled={isProcessing}
        >
          {isProcessing ? (
            <span className="flex items-center gap-2">
              <span className="w-5 h-5 border-2 border-primary-foreground/30 border-t-primary-foreground rounded-full animate-spin" />
              Processando...
            </span>
          ) : (
            `Pagar R$ ${orderDetails.amount}`
          )}
        </Button>
      </main>
    </div>
  );
};

export default ClientCheckout;
