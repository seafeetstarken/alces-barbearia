import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { 
  BarChart3,
  TrendingUp,
  TrendingDown,
  Download,
  Calendar,
  Users,
  Scissors,
  Wallet,
  Filter,
} from "lucide-react";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

const Reports = () => {
  return (
    <DashboardLayout
      title="Relatórios"
      subtitle="Análise de desempenho"
    >
      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <Select defaultValue="month">
          <SelectTrigger className="w-full sm:w-48">
            <Calendar className="w-4 h-4 mr-2" />
            <SelectValue placeholder="Período" />
          </SelectTrigger>
          <SelectContent className="bg-popover">
            <SelectItem value="today">Hoje</SelectItem>
            <SelectItem value="week">Esta Semana</SelectItem>
            <SelectItem value="month">Este Mês</SelectItem>
            <SelectItem value="quarter">Trimestre</SelectItem>
            <SelectItem value="year">Este Ano</SelectItem>
          </SelectContent>
        </Select>
        <Button variant="outline">
          <Download className="w-4 h-4 mr-2" />
          Exportar
        </Button>
      </div>

      {/* KPIs */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        <Card className="border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Faturamento</p>
                <p className="text-2xl font-bold text-foreground">R$ 23.500</p>
                <div className="flex items-center gap-1 text-sm text-green-600 dark:text-green-400">
                  <TrendingUp className="w-4 h-4" />
                  <span>+15.3% vs mês anterior</span>
                </div>
              </div>
              <div className="w-10 h-10 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
                <Wallet className="w-5 h-5 text-green-600 dark:text-green-400" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Atendimentos</p>
                <p className="text-2xl font-bold text-foreground">665</p>
                <div className="flex items-center gap-1 text-sm text-green-600 dark:text-green-400">
                  <TrendingUp className="w-4 h-4" />
                  <span>+8.2% vs mês anterior</span>
                </div>
              </div>
              <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
                <Scissors className="w-5 h-5 text-primary" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Ticket Médio</p>
                <p className="text-2xl font-bold text-foreground">R$ 52,80</p>
                <div className="flex items-center gap-1 text-sm text-green-600 dark:text-green-400">
                  <TrendingUp className="w-4 h-4" />
                  <span>+5.1% vs mês anterior</span>
                </div>
              </div>
              <div className="w-10 h-10 rounded-lg bg-muted flex items-center justify-center">
                <BarChart3 className="w-5 h-5 text-muted-foreground" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-5">
            <div className="flex items-start justify-between">
              <div className="space-y-2">
                <p className="text-sm font-medium text-muted-foreground">Comissões Pagas</p>
                <p className="text-2xl font-bold text-foreground">R$ 8.420</p>
                <div className="flex items-center gap-1 text-sm text-muted-foreground">
                  <span>35.8% do faturamento</span>
                </div>
              </div>
              <div className="w-10 h-10 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
                <Users className="w-5 h-5 text-amber-600 dark:text-amber-400" />
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Services Breakdown */}
        <Card className="border">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg font-semibold">Serviços Mais Realizados</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {[
              { name: "Corte + Barba", count: 280, revenue: 18200, percentage: 42 },
              { name: "Corte", count: 250, revenue: 11250, percentage: 38 },
              { name: "Barba", count: 85, revenue: 2975, percentage: 13 },
              { name: "Pigmentação", count: 35, revenue: 2800, percentage: 5 },
              { name: "Outros", count: 15, revenue: 975, percentage: 2 },
            ].map((service, index) => (
              <div key={service.name} className="flex items-center gap-4">
                <div className="w-8 text-center">
                  <span className="text-sm font-bold text-muted-foreground">{index + 1}</span>
                </div>
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <span className="font-medium text-foreground">{service.name}</span>
                    <span className="text-sm text-muted-foreground">{service.count} serviços</span>
                  </div>
                  <div className="h-2 bg-muted rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-primary rounded-full"
                      style={{ width: `${service.percentage}%` }}
                    />
                  </div>
                </div>
                <div className="w-24 text-right">
                  <p className="font-semibold text-foreground">R$ {service.revenue.toLocaleString()}</p>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>

        {/* Barber Performance */}
        <Card className="border">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg font-semibold">Desempenho por Barbeiro</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {[
              { name: "João Pedro", services: 220, revenue: 8500, commission: 2975, trend: 12 },
              { name: "Lucas Almeida", services: 175, revenue: 6200, commission: 2170, trend: 8 },
              { name: "Rafael Santos", services: 155, revenue: 5400, commission: 1890, trend: -3 },
              { name: "Pedro Costa", services: 115, revenue: 3200, commission: 1120, trend: 15 },
            ].map((barber) => (
              <div key={barber.name} className="p-4 rounded-lg bg-muted/50">
                <div className="flex items-center justify-between mb-2">
                  <span className="font-medium text-foreground">{barber.name}</span>
                  <div className={`flex items-center gap-1 text-sm ${
                    barber.trend >= 0 
                      ? "text-green-600 dark:text-green-400" 
                      : "text-destructive"
                  }`}>
                    {barber.trend >= 0 ? (
                      <TrendingUp className="w-4 h-4" />
                    ) : (
                      <TrendingDown className="w-4 h-4" />
                    )}
                    <span>{barber.trend >= 0 ? "+" : ""}{barber.trend}%</span>
                  </div>
                </div>
                <div className="grid grid-cols-3 gap-2 text-sm">
                  <div>
                    <p className="text-muted-foreground">Serviços</p>
                    <p className="font-semibold text-foreground">{barber.services}</p>
                  </div>
                  <div>
                    <p className="text-muted-foreground">Faturamento</p>
                    <p className="font-semibold text-foreground">R$ {barber.revenue.toLocaleString()}</p>
                  </div>
                  <div>
                    <p className="text-muted-foreground">Comissão</p>
                    <p className="font-semibold text-primary">R$ {barber.commission.toLocaleString()}</p>
                  </div>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>

        {/* Payment Methods */}
        <Card className="border">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg font-semibold">Formas de Pagamento</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {[
              { method: "PIX", amount: 12580, percentage: 53.5, transactions: 342 },
              { method: "Cartão de Crédito", amount: 6820, percentage: 29.0, transactions: 185 },
              { method: "Cartão de Débito", amount: 2350, percentage: 10.0, transactions: 64 },
              { method: "Dinheiro", amount: 1750, percentage: 7.5, transactions: 74 },
            ].map((payment) => (
              <div key={payment.method} className="flex items-center gap-4">
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <span className="font-medium text-foreground">{payment.method}</span>
                    <span className="text-sm text-muted-foreground">{payment.transactions} transações</span>
                  </div>
                  <div className="h-2 bg-muted rounded-full overflow-hidden">
                    <div 
                      className="h-full bg-primary rounded-full"
                      style={{ width: `${payment.percentage}%` }}
                    />
                  </div>
                </div>
                <div className="w-28 text-right">
                  <p className="font-semibold text-foreground">R$ {payment.amount.toLocaleString()}</p>
                  <p className="text-xs text-muted-foreground">{payment.percentage}%</p>
                </div>
              </div>
            ))}
          </CardContent>
        </Card>

        {/* Daily Revenue */}
        <Card className="border">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg font-semibold">Faturamento Diário</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {[
                { day: "Segunda", date: "20/01", revenue: 2850, services: 36 },
                { day: "Terça", date: "21/01", revenue: 2525, services: 32 },
                { day: "Quarta", date: "22/01", revenue: 0, services: 0, future: true },
                { day: "Quinta", date: "23/01", revenue: 0, services: 0, future: true },
                { day: "Sexta", date: "24/01", revenue: 0, services: 0, future: true },
                { day: "Sábado", date: "25/01", revenue: 0, services: 0, future: true },
                { day: "Domingo", date: "26/01", revenue: 0, services: 0, future: true },
              ].map((day) => (
                <div 
                  key={day.day} 
                  className={`flex items-center justify-between p-3 rounded-lg ${
                    day.future ? "opacity-50" : "bg-muted/50"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-16">
                      <p className="font-medium text-foreground text-sm">{day.day}</p>
                      <p className="text-xs text-muted-foreground">{day.date}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    {!day.future ? (
                      <>
                        <p className="font-semibold text-foreground">R$ {day.revenue.toLocaleString()}</p>
                        <p className="text-xs text-muted-foreground">{day.services} serviços</p>
                      </>
                    ) : (
                      <p className="text-sm text-muted-foreground">-</p>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default Reports;
