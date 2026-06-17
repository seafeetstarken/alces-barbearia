import { useMemo } from "react";
import { useNavigate, useParams } from "react-router-dom";
import DashboardLayout from "@/components/layout/DashboardLayout";
import MetricCard from "@/components/dashboard/MetricCard";
import RecentServices from "@/components/dashboard/RecentServices";
import BarberPerformance from "@/components/dashboard/BarberPerformance";
import CashRegisterStatus from "@/components/dashboard/CashRegisterStatus";
import { Button } from "@/components/ui/button";
import {
  Wallet,
  Users,
  Scissors,
  TrendingUp,
  Plus,
} from "lucide-react";
import { useStore } from "@/hooks/useStore";
import { useBarbers } from "@/hooks/useBarbers";
import { useCashier } from "@/hooks/useCashier";
import { useCommissions } from "@/hooks/useCommissions";

const formatCurrency = (value: number) =>
  value.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

const Dashboard = () => {
  const navigate = useNavigate();
  const { storeId } = useParams();
  const { store } = useStore(storeId);
  const { activeBarbers, isLoading: isBarbersLoading } = useBarbers(store?.id);
  const { pointsByBarber, isLoading: isCommissionsLoading } = useCommissions(store?.id);
  const { transactions, totalIncome, totalExpenses, isOpen, cashRegister, isLoading: isCashierLoading } = useCashier(store?.id);

  const today = new Date().toLocaleDateString("pt-BR", {
    weekday: "long",
    day: "numeric",
    month: "long",
  });

  const serviceTransactions = useMemo(
    () => transactions.filter((transaction) => transaction.type === "service"),
    [transactions],
  );

  const paymentBreakdown = useMemo(
    () =>
      ["pix", "card", "cash"].map((method) => {
        const methodTransactions = transactions.filter(
          (transaction) =>
            (transaction.type === "service" || transaction.type === "product" || transaction.type === "deposit") &&
            transaction.payment_method === method,
        );

        return {
          method: method as "pix" | "card" | "cash",
          count: methodTransactions.length,
          amount: methodTransactions.reduce((sum, item) => sum + item.amount, 0),
        };
      }),
    [transactions],
  );

  const recentServices = useMemo(
    () =>
      serviceTransactions.slice(0, 6).map((transaction) => ({
        id: transaction.id,
        clientName: transaction.client?.name ?? "Cliente balcão",
        barberName: transaction.barber?.name ?? "Equipe",
        serviceName: transaction.description ?? "Atendimento",
        price: transaction.amount,
        points: pointsByBarber.find((item) => item.barberId === transaction.barber_id)?.totalPoints ?? 0,
        time: new Date(transaction.created_at).toLocaleTimeString("pt-BR", {
          hour: "2-digit",
          minute: "2-digit",
        }),
        paymentMethod: transaction.payment_method ?? "cash",
      })),
    [pointsByBarber, serviceTransactions],
  );

  const topBarbers = useMemo(() => {
    const perBarberSummary = pointsByBarber
      .map((pointsEntry) => {
        const barber = activeBarbers.find((item) => item.id === pointsEntry.barberId);
        const barberServices = serviceTransactions.filter((service) => service.barber_id === pointsEntry.barberId);
        const barberRevenue = barberServices.reduce((sum, service) => sum + service.amount, 0);
        const initials =
          barber?.initials ??
          pointsEntry.barberName
            .split(" ")
            .slice(0, 2)
            .map((part) => part[0])
            .join("")
            .toUpperCase();

        return {
          id: pointsEntry.barberId,
          name: pointsEntry.barberName,
          initials,
          points: pointsEntry.totalPoints,
          services: barberServices.length,
          revenue: barberRevenue,
        };
      })
      .sort((a, b) => b.points - a.points)
      .slice(0, 4);

    const maxPoints = Math.max(...perBarberSummary.map((item) => item.points), 30);

    return perBarberSummary.map((barber) => ({
      ...barber,
      maxPoints,
    }));
  }, [activeBarbers, pointsByBarber, serviceTransactions]);

  const totalPoints = pointsByBarber.reduce((sum, item) => sum + item.totalPoints, 0);
  const estimatedCommissionPool = totalIncome * 0.43;

  return (
    <DashboardLayout
      title="Dashboard"
      subtitle={`${today.charAt(0).toUpperCase() + today.slice(1)}`}
      storeName={store?.name}
    >
      <div className="flex flex-col sm:flex-row gap-3 mb-6">
        <Button variant="premium" size="lg" className="w-full sm:w-auto" onClick={() => navigate("/cashier")}>
          <Plus className="w-4 h-4 mr-2" />
          Novo Atendimento
        </Button>
        <Button variant="outline" size="lg" className="w-full sm:w-auto" onClick={() => navigate("/cashier")}>
          <Wallet className="w-4 h-4 mr-2" />
          {isOpen ? "Ver Caixa" : "Abrir Caixa"}
        </Button>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <MetricCard
          title="Faturamento Hoje"
          value={formatCurrency(totalIncome)}
          subtitle={`${serviceTransactions.length} atendimentos`}
          icon={Wallet}
          variant="primary"
        />
        <MetricCard
          title="Barbeiros Ativos"
          value={String(activeBarbers.length)}
          subtitle={isBarbersLoading ? "Atualizando equipe..." : "Em operação hoje"}
          icon={Users}
          variant="default"
        />
        <MetricCard
          title="Serviços Realizados"
          value={String(serviceTransactions.length)}
          subtitle={
            activeBarbers.length > 0
              ? `Média: ${(serviceTransactions.length / activeBarbers.length).toFixed(1)} por barbeiro`
              : "Aguardando equipe ativa"
          }
          icon={Scissors}
          variant="default"
        />
        <MetricCard
          title="Pontos Distribuídos"
          value={String(totalPoints)}
          subtitle={`${formatCurrency(estimatedCommissionPool)} no pool`}
          icon={TrendingUp}
          variant="success"
        />
      </div>
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <RecentServices
            services={recentServices}
            isLoading={isCashierLoading}
            onViewAll={() => navigate("/cashier")}
          />
        </div>
        <div className="space-y-6">
          <CashRegisterStatus
            isOpen={isOpen}
            openedAt={
              cashRegister?.opened_at
                ? new Date(cashRegister.opened_at).toLocaleTimeString("pt-BR", {
                    hour: "2-digit",
                    minute: "2-digit",
                  })
                : undefined
            }
            totalRevenue={totalIncome}
            totalExpenses={totalExpenses}
            paymentBreakdown={paymentBreakdown}
            isLoading={isCashierLoading}
            onToggleCashier={() => navigate("/cashier")}
          />
          <BarberPerformance
            barbers={topBarbers}
            isLoading={isCommissionsLoading}
            onViewDetails={() => navigate("/commissions")}
          />
        </div>
      </div>
    </DashboardLayout>
  );
};

export default Dashboard;
