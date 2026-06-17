import { useNavigate } from "react-router-dom";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import {
  ArrowLeft, Crown, Check, Scissors, Calendar, Percent, Gift,
  CreditCard, AlertCircle, CheckCircle2
} from "lucide-react";
import { useBilling } from "@/hooks/useBilling";
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

const benefits = [
  { icon: Scissors, title: "1 Corte por mês", description: "Incluso na assinatura" },
  { icon: Percent, title: "15% OFF em serviços", description: "Desconto em todos os serviços extras" },
  { icon: Gift, title: "10% OFF na loja", description: "Desconto em produtos" },
  { icon: Calendar, title: "Agendamento prioritário", description: "Horários exclusivos para membros" },
];

const ClientSubscription = () => {
  const navigate = useNavigate();
  const { toast } = useToast();
  const storeId = typeof window !== "undefined" ? localStorage.getItem("active_store_id") ?? undefined : undefined;
  const { plans, subscription, updateSubscriptionStatus, isUpdating, isLoading, error } = useBilling(storeId);
  const selectedPlan = plans[0];
  const isSubscribed = subscription?.status === "active" || subscription?.status === "trialing";

  const handleSubscribe = () => {
    if (!selectedPlan) {
      toast({
        title: "Plano indisponível",
        description: "Nenhum plano ativo encontrado para contratação.",
        variant: "destructive",
      });
      return;
    }

    navigate(`/client/checkout?type=subscription&planId=${selectedPlan.id}`);
  };

  const handleCancel = () => {
    if (!subscription) return;
    updateSubscriptionStatus(
      {
        planId: subscription.plan_id ?? selectedPlan?.id ?? "",
        status: "canceled",
      },
      {
        onSuccess: () =>
          toast({
            title: "Assinatura cancelada",
            description: "Seu plano será encerrado ao final do período atual.",
          }),
        onError: () =>
          toast({
            title: "Falha ao cancelar",
            description: "Não foi possível cancelar a assinatura agora.",
            variant: "destructive",
          }),
      },
    );
  };

  if (!storeId) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState
          variant="empty"
          title="Loja não selecionada"
          description="Selecione uma loja no painel administrativo para gerenciar assinatura."
          action={
            <Button variant="outline" onClick={() => navigate("/stores")}>
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
        <DataState variant="loading" title="Carregando assinatura" description="Buscando status atual da sua assinatura." />
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState variant="error" title="Falha ao carregar assinatura" description="Tente novamente em alguns instantes." />
      </div>
    );
  }

  if (isSubscribed) {
    return (
      <div className="min-h-screen bg-background">
        <header className="bg-card border-b border-border sticky top-0 z-50">
          <div className="container mx-auto px-4 py-4 flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => navigate("/client")}>
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <h1 className="font-semibold">Clube de Corte</h1>
          </div>
        </header>

        <main className="container mx-auto px-4 py-6 space-y-6 max-w-lg">
          {/* Status Card */}
          <Card className="bg-primary/5 border-primary/20">
            <CardContent className="pt-6">
              <div className="flex items-center gap-4 mb-4">
                <div className="w-14 h-14 rounded-full bg-primary/10 flex items-center justify-center">
                  <Crown className="w-7 h-7 text-primary" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h2 className="text-xl font-semibold">Assinatura Ativa</h2>
                    <Badge className="bg-primary text-primary-foreground">Membro</Badge>
                  </div>
                  <p className="text-sm text-muted-foreground">
                    Status: {subscription?.status === "trialing" ? "Período de teste" : "Ativa"}
                  </p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4 mt-6">
                <div className="bg-background rounded-lg p-4 text-center">
                  <p className="text-3xl font-bold text-primary">1</p>
                  <p className="text-sm text-muted-foreground">Corte disponível</p>
                </div>
                <div className="bg-background rounded-lg p-4 text-center">
                  <p className="text-3xl font-bold">15%</p>
                  <p className="text-sm text-muted-foreground">Desconto ativo</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Benefits */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Seus Benefícios</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {benefits.map((benefit, index) => (
                <div key={index} className="flex items-center gap-4">
                  <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                    <benefit.icon className="w-5 h-5 text-primary" />
                  </div>
                  <div className="flex-1">
                    <p className="font-medium">{benefit.title}</p>
                    <p className="text-sm text-muted-foreground">{benefit.description}</p>
                  </div>
                  <CheckCircle2 className="w-5 h-5 text-primary" />
                </div>
              ))}
            </CardContent>
          </Card>

          {/* Billing Info */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Cobrança</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Valor mensal</span>
                <span className="font-semibold">
                  R$ {((selectedPlan?.amount_cents ?? 9900) / 100).toFixed(2)}/mês
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Próxima cobrança</span>
                <span>
                  {subscription?.current_period_end
                    ? new Date(subscription.current_period_end).toLocaleDateString("pt-BR")
                    : "-"}
                </span>
              </div>
              <Separator />
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <CreditCard className="w-4 h-4 text-muted-foreground" />
                  <span className="text-sm">Pagamento recorrente Asaas</span>
                </div>
                <Button variant="ghost" size="sm" onClick={() => navigate("/client/wallet")}>
                  Alterar
                </Button>
              </div>
            </CardContent>
          </Card>

          {/* Actions */}
          <div className="space-y-3">
            <Button className="w-full" onClick={() => navigate("/client/booking")}>
              Usar Meu Corte do Mês
            </Button>

            <AlertDialog>
              <AlertDialogTrigger asChild>
                <Button variant="ghost" className="w-full text-destructive hover:text-destructive">
                  Cancelar Assinatura
                </Button>
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>Cancelar assinatura?</AlertDialogTitle>
                  <AlertDialogDescription>
                    Você perderá todos os benefícios do Clube de Corte. O cancelamento será efetivado ao final do período atual.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>Manter Assinatura</AlertDialogCancel>
                  <AlertDialogAction
                    onClick={handleCancel}
                    className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
                    disabled={isUpdating}
                  >
                    Confirmar Cancelamento
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>
          </div>
        </main>
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
          <h1 className="font-semibold">Clube de Corte</h1>
        </div>
      </header>

      <main className="container mx-auto px-4 py-6 space-y-6 max-w-lg">
        {/* Hero */}
        <div className="text-center py-8">
          <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
            <Crown className="w-10 h-10 text-primary" />
          </div>
          <h2 className="text-2xl font-bold mb-2">Clube de Corte</h2>
          <p className="text-muted-foreground">
            Assine e aproveite benefícios exclusivos todos os meses
          </p>
        </div>

        {/* Price Card */}
        <Card className="bg-primary/5 border-primary/20">
          <CardContent className="pt-6 text-center">
            <div className="mb-4">
              <span className="text-4xl font-bold">
                R$ {((selectedPlan?.amount_cents ?? 9900) / 100).toFixed(2)}
              </span>
              <span className="text-muted-foreground">/mês</span>
            </div>
            <p className="text-sm text-muted-foreground">
              Cancele quando quiser, sem multas
            </p>
          </CardContent>
        </Card>

        {/* Benefits */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base">O que está incluso</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {benefits.map((benefit, index) => (
              <div key={index} className="flex items-start gap-4">
                <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                  <benefit.icon className="w-5 h-5 text-primary" />
                </div>
                <div>
                  <p className="font-medium">{benefit.title}</p>
                  <p className="text-sm text-muted-foreground">{benefit.description}</p>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>

        {/* Comparison */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Compare e economize</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3 text-sm">
              <div className="flex justify-between">
                <span className="text-muted-foreground">1 corte avulso</span>
                <span>R$ 45</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">+ Barba (com 15% off)</span>
                <span>R$ 30</span>
              </div>
              <Separator />
              <div className="flex justify-between font-medium">
                <span>Total com clube</span>
                <span className="text-primary">R$ 75</span>
              </div>
              <div className="flex justify-between text-muted-foreground">
                <span>Total sem clube</span>
                <span className="line-through">R$ 80</span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Button className="w-full h-14 text-base font-medium" size="lg" onClick={handleSubscribe}>
          Assinar por R$ {((selectedPlan?.amount_cents ?? 9900) / 100).toFixed(2)}/mês
        </Button>

        <p className="text-xs text-center text-muted-foreground">
          Ao assinar, você concorda com os termos de uso e política de privacidade.
        </p>
      </main>
    </div>
  );
};

export default ClientSubscription;
