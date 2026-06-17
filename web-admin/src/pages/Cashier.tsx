import { useMemo, useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  Wallet,
  Plus,
  ArrowUpRight,
  ArrowDownRight,
  CreditCard,
  Banknote,
  QrCode,
  Scissors,
  Clock,
  User,
  CheckCircle2,
  Loader2,
} from "lucide-react";
import { useStore } from "@/hooks/useStore";
import { useCashier } from "@/hooks/useCashier";
import { useServices } from "@/hooks/useServices";
import { useBarbers } from "@/hooks/useBarbers";
import { useToast } from "@/hooks/use-toast";
import { DataState } from "@/components/ui/data-state";

const formatCurrency = (value: number) =>
  value.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

const Cashier = () => {
  const { store } = useStore();
  const { activeServices, isLoading: isServicesLoading } = useServices(store?.id);
  const { activeBarbers, isLoading: isBarbersLoading } = useBarbers(store?.id);
  const {
    cashRegister,
    isOpen,
    transactions,
    totalIncome,
    totalExpenses,
    balance,
    isLoading,
    error,
    openCashRegister,
    closeCashRegister,
    createTransaction,
    isOpening,
    isClosing,
    isCreating,
  } = useCashier(store?.id);
  const { toast } = useToast();

  const [newServiceDialog, setNewServiceDialog] = useState(false);
  const [selectedService, setSelectedService] = useState("");
  const [selectedBarber, setSelectedBarber] = useState("");
  const [selectedPayment, setSelectedPayment] = useState<"pix" | "card" | "cash" | "">("");
  const [clientName, setClientName] = useState("");
  const [openingBalanceInput, setOpeningBalanceInput] = useState("200");

  const handleRegisterService = () => {
    if (!store?.id || !selectedService || !selectedBarber || !selectedPayment) {
      return;
    }

    const service = activeServices.find((item) => item.id === selectedService);
    if (!service) {
      return;
    }

    createTransaction(
      {
        transaction: {
          store_id: store.id,
          barber_id: selectedBarber,
          client_id: null,
          type: "service",
          description: clientName ? `${service.name} - ${clientName}` : service.name,
          amount: service.price,
          payment_method: selectedPayment,
          cash_register_id: cashRegister?.id ?? null,
        },
        items: [
          {
            service_id: service.id,
            product_id: null,
            quantity: 1,
            unit_price: service.price,
            points: service.points,
          },
        ],
      },
      {
        onSuccess: () => {
          setNewServiceDialog(false);
          setSelectedService("");
          setSelectedBarber("");
          setSelectedPayment("");
          setClientName("");
          toast({
            title: "Atendimento registrado",
            description: "A movimentação já entrou no caixa e no cálculo de pontos.",
          });
        },
        onError: () => {
          toast({
            title: "Não foi possível registrar",
            description: "Confira os dados e tente novamente.",
            variant: "destructive",
          });
        },
      },
    );
  };

  const handleToggleCashier = () => {
    if (!store?.id) {
      return;
    }

    if (isOpen && cashRegister) {
      closeCashRegister(
        { closingBalance: balance },
        {
          onSuccess: () =>
            toast({
              title: "Caixa fechado",
              description: "Fechamento concluído com sucesso.",
            }),
          onError: () =>
            toast({
              title: "Não foi possível fechar o caixa",
              description: "Verifique as movimentações e tente novamente.",
              variant: "destructive",
            }),
        },
      );
      return;
    }

    const parsedOpeningBalance = Number(openingBalanceInput.replace(",", "."));
    if (Number.isNaN(parsedOpeningBalance) || parsedOpeningBalance < 0) {
      toast({
        title: "Valor de abertura inválido",
        description: "Informe um saldo inicial válido para abrir o caixa.",
        variant: "destructive",
      });
      return;
    }

    openCashRegister(
      { openingBalance: parsedOpeningBalance },
      {
        onSuccess: () =>
          toast({
            title: "Caixa aberto",
            description: "Movimentações do dia já podem ser registradas.",
          }),
        onError: () =>
          toast({
            title: "Não foi possível abrir o caixa",
            description: "Tente novamente em instantes.",
            variant: "destructive",
          }),
      },
    );
  };

  const selectedServiceData = activeServices.find((item) => item.id === selectedService);
  const normalizedTransactions = useMemo(
    () =>
      transactions.map((transaction) => {
        const isIncome = transaction.type === "service" || transaction.type === "product" || transaction.type === "deposit";
        return {
          id: transaction.id,
          type: isIncome ? "income" : "expense",
          description: transaction.description ?? "Movimentação manual",
          value: transaction.amount,
          paymentMethod: transaction.payment_method,
          time: new Date(transaction.created_at).toLocaleTimeString("pt-BR", {
            hour: "2-digit",
            minute: "2-digit",
          }),
        };
      }),
    [transactions],
  );

  if (isLoading) {
    return (
      <DashboardLayout title="Caixa" subtitle="Gerencie as entradas e saídas do dia">
        <DataState
          variant="loading"
          title="Carregando caixa"
          description="Estamos atualizando os dados financeiros de hoje."
          className="max-w-xl mx-auto"
        />
      </DashboardLayout>
    );
  }

  if (error) {
    return (
      <DashboardLayout title="Caixa" subtitle="Gerencie as entradas e saídas do dia">
        <DataState
          variant="error"
          title="Falha ao carregar o caixa"
          description="Não conseguimos buscar as movimentações. Tente recarregar a página."
          className="max-w-xl mx-auto"
        />
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout title="Caixa" subtitle="Gerencie as entradas e saídas do dia">
      <div className={`mb-6 p-4 rounded-lg flex flex-col sm:flex-row gap-4 sm:items-center sm:justify-between ${isOpen ? "bg-green-50 border border-green-200 dark:bg-green-900/20 dark:border-green-800" : "bg-muted border"}`}>
        <div className="flex items-center gap-3">
          <div className={`w-3 h-3 rounded-full ${isOpen ? "bg-green-500" : "bg-muted-foreground"}`} />
          <div>
            <p className="font-semibold text-foreground">Caixa {isOpen ? "Aberto" : "Fechado"}</p>
            <p className="text-sm text-muted-foreground">
              {isOpen && cashRegister?.opened_at
                ? `Aberto às ${new Date(cashRegister.opened_at).toLocaleTimeString("pt-BR", { hour: "2-digit", minute: "2-digit" })}`
                : "Abra o caixa para iniciar o dia"}
            </p>
          </div>
        </div>
        <Button variant={isOpen ? "soft" : "default"} onClick={handleToggleCashier} disabled={isOpening || isClosing}>
          {(isOpening || isClosing) && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
          {isOpen ? "Fechar Caixa" : "Abrir Caixa"}
        </Button>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card className="border">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Abertura</p>
                <p className="text-xl font-bold text-foreground">{formatCurrency(cashRegister?.opening_balance ?? 0)}</p>
              </div>
              <Wallet className="w-8 h-8 text-muted-foreground" />
            </div>
          </CardContent>
        </Card>

        <Card className="border bg-green-50 dark:bg-green-900/20">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Entradas</p>
                <p className="text-xl font-bold text-green-600 dark:text-green-400">{formatCurrency(totalIncome)}</p>
              </div>
              <ArrowUpRight className="w-8 h-8 text-green-500" />
            </div>
          </CardContent>
        </Card>

        <Card className="border bg-red-50 dark:bg-red-900/20">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Saídas</p>
                <p className="text-xl font-bold text-destructive">{formatCurrency(totalExpenses)}</p>
              </div>
              <ArrowDownRight className="w-8 h-8 text-destructive" />
            </div>
          </CardContent>
        </Card>

        <Card className="border bg-primary/5">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Saldo Atual</p>
                <p className="text-xl font-bold text-foreground">{formatCurrency(balance)}</p>
              </div>
              <Wallet className="w-8 h-8 text-primary" />
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="border">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg font-semibold">Ações Rápidas</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {!isOpen && (
              <div className="space-y-2 p-3 rounded-lg border bg-muted/50">
                <Label htmlFor="opening-balance">Saldo inicial do caixa</Label>
                <Input
                  id="opening-balance"
                  value={openingBalanceInput}
                  onChange={(event) => setOpeningBalanceInput(event.target.value)}
                  inputMode="decimal"
                  placeholder="0,00"
                />
              </div>
            )}
            <Dialog open={newServiceDialog} onOpenChange={setNewServiceDialog}>
              <DialogTrigger asChild>
                <Button className="w-full justify-start" variant="premium" size="lg" disabled={!isOpen}>
                  <Plus className="w-5 h-5 mr-3" />
                  Registrar Atendimento
                </Button>
              </DialogTrigger>
              <DialogContent className="sm:max-w-md">
                <DialogHeader>
                  <DialogTitle>Novo Atendimento</DialogTitle>
                  <DialogDescription>
                    Registre um novo serviço realizado
                  </DialogDescription>
                </DialogHeader>
                <div className="space-y-4 py-4">
                  <div className="space-y-2">
                    <Label>Cliente</Label>
                    <Input
                      placeholder="Nome do cliente"
                      value={clientName}
                      onChange={(e) => setClientName(e.target.value)}
                    />
                  </div>

                  <div className="space-y-2">
                    <Label>Serviço</Label>
                    <Select value={selectedService} onValueChange={setSelectedService}>
                      <SelectTrigger>
                        <SelectValue placeholder="Selecione o serviço" />
                      </SelectTrigger>
                      <SelectContent>
                        {activeServices.map((service) => (
                          <SelectItem key={service.id} value={service.id}>
                            <div className="flex items-center justify-between w-full">
                              <span>{service.name}</span>
                              <span className="text-muted-foreground ml-2">{formatCurrency(service.price)}</span>
                            </div>
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    {selectedServiceData && (
                      <div className="flex items-center gap-4 text-sm text-muted-foreground mt-1">
                        <span className="flex items-center gap-1">
                          <Clock className="w-3.5 h-3.5" />
                          {selectedServiceData.duration_minutes}min
                        </span>
                        <span className="flex items-center gap-1">
                          <Scissors className="w-3.5 h-3.5" />
                          {selectedServiceData.points} pt{selectedServiceData.points > 1 ? "s" : ""}
                        </span>
                      </div>
                    )}
                  </div>

                  <div className="space-y-2">
                    <Label>Barbeiro</Label>
                    <Select value={selectedBarber} onValueChange={setSelectedBarber}>
                      <SelectTrigger>
                        <SelectValue placeholder="Selecione o barbeiro" />
                      </SelectTrigger>
                      <SelectContent>
                        {activeBarbers.map((barber) => (
                          <SelectItem key={barber.id} value={barber.id}>
                            {barber.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label>Forma de Pagamento</Label>
                    <div className="grid grid-cols-3 gap-2">
                      {[
                        { id: "pix", label: "PIX", icon: QrCode },
                        { id: "card", label: "Cartão", icon: CreditCard },
                        { id: "cash", label: "Dinheiro", icon: Banknote },
                      ].map((method) => (
                        <button
                          key={method.id}
                          onClick={() => setSelectedPayment(method.id as "pix" | "card" | "cash")}
                          type="button"
                          className={`flex flex-col items-center gap-2 p-3 rounded-lg border transition-all ${
                            selectedPayment === method.id
                              ? "border-primary bg-primary/10"
                              : "border-border hover:border-primary/50"
                          }`}
                        >
                          <method.icon className={`w-5 h-5 ${
                            selectedPayment === method.id ? "text-primary" : "text-muted-foreground"
                          }`} />
                          <span className={`text-sm ${
                            selectedPayment === method.id ? "text-primary font-medium" : "text-muted-foreground"
                          }`}>
                            {method.label}
                          </span>
                        </button>
                      ))}
                    </div>
                  </div>

                  {selectedServiceData && (
                    <div className="p-4 rounded-lg bg-muted">
                      <div className="flex items-center justify-between">
                        <span className="text-sm text-muted-foreground">Total</span>
                        <span className="text-xl font-bold text-foreground">
                          {formatCurrency(selectedServiceData.price)}
                        </span>
                      </div>
                    </div>
                  )}
                </div>
                <DialogFooter>
                  <Button variant="outline" onClick={() => setNewServiceDialog(false)}>
                    Cancelar
                  </Button>
                  <Button
                    onClick={handleRegisterService}
                    disabled={!selectedService || !selectedBarber || !selectedPayment || isCreating}
                  >
                    {isCreating && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                    <CheckCircle2 className="w-4 h-4 mr-2" />
                    Confirmar
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
            <Button className="w-full justify-start" variant="outline" size="lg" disabled>
              <ArrowDownRight className="w-5 h-5 mr-3" />
              Registrar Saída
            </Button>
            <Button className="w-full justify-start" variant="outline" size="lg" disabled>
              <ArrowUpRight className="w-5 h-5 mr-3" />
              Entrada Manual
            </Button>
            {(isServicesLoading || isBarbersLoading) && (
              <p className="text-xs text-muted-foreground">Atualizando serviços e equipe para o checkout rápido.</p>
            )}
          </CardContent>
        </Card>
        <Card className="border lg:col-span-2">
          <CardHeader className="pb-3">
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg font-semibold">Movimentações</CardTitle>
              <Badge variant="outline">{normalizedTransactions.length} registros</Badge>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            {normalizedTransactions.length === 0 ? (
              <div className="p-6">
                <DataState
                  variant="empty"
                  title="Sem movimentações registradas"
                  description="Use a ação principal para lançar o primeiro atendimento do dia."
                />
              </div>
            ) : (
              <div className="divide-y divide-border">
                {normalizedTransactions.map((transaction) => (
                  <div
                    key={transaction.id}
                    className="flex items-center justify-between px-6 py-4 hover:bg-muted/50 transition-colors"
                  >
                    <div className="flex items-center gap-4">
                      <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${transaction.type === "income" ? "bg-green-100 dark:bg-green-900/30" : "bg-red-100 dark:bg-red-900/30"}`}>
                        {transaction.type === "income" ? (
                          <ArrowUpRight className="w-5 h-5 text-green-600 dark:text-green-400" />
                        ) : (
                          <ArrowDownRight className="w-5 h-5 text-destructive" />
                        )}
                      </div>
                      <div>
                        <p className="font-medium text-foreground">{transaction.description}</p>
                        <div className="flex items-center gap-2 text-sm text-muted-foreground">
                          <Clock className="w-3.5 h-3.5" />
                          <span>{transaction.time}</span>
                          {transaction.paymentMethod && (
                            <>
                              <span>•</span>
                              <span className="capitalize">
                                {transaction.paymentMethod === "pix"
                                  ? "PIX"
                                  : transaction.paymentMethod === "card"
                                    ? "Cartão"
                                    : "Dinheiro"}
                              </span>
                            </>
                          )}
                        </div>
                      </div>
                    </div>
                    <p className={`font-semibold ${transaction.type === "income" ? "text-green-600 dark:text-green-400" : "text-destructive"}`}>
                      {transaction.type === "income" ? "+" : "-"} {formatCurrency(transaction.value)}
                    </p>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default Cashier;
