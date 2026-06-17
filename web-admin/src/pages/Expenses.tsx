import { useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { 
  Plus, 
  Search, 
  Receipt,
  ArrowDownRight,
  Calendar,
  Filter,
  TrendingDown,
  Wallet,
  ShoppingCart,
  Zap,
  Wrench,
} from "lucide-react";
import { Input } from "@/components/ui/input";

interface Expense {
  id: string;
  description: string;
  category: "supplies" | "utilities" | "maintenance" | "other";
  amount: number;
  date: string;
  paidBy: string;
  paymentMethod: "pix" | "card" | "cash" | "transfer";
}

const expenses: Expense[] = [
  {
    id: "1",
    description: "Lâminas de barbear",
    category: "supplies",
    amount: 180,
    date: "2025-01-21",
    paidBy: "Caixa",
    paymentMethod: "cash",
  },
  {
    id: "2",
    description: "Conta de energia",
    category: "utilities",
    amount: 450,
    date: "2025-01-20",
    paidBy: "Conta empresa",
    paymentMethod: "transfer",
  },
  {
    id: "3",
    description: "Manutenção ar condicionado",
    category: "maintenance",
    amount: 350,
    date: "2025-01-19",
    paidBy: "Conta empresa",
    paymentMethod: "pix",
  },
  {
    id: "4",
    description: "Produtos de limpeza",
    category: "supplies",
    amount: 95,
    date: "2025-01-18",
    paidBy: "Caixa",
    paymentMethod: "cash",
  },
  {
    id: "5",
    description: "Café e água",
    category: "supplies",
    amount: 120,
    date: "2025-01-17",
    paidBy: "Caixa",
    paymentMethod: "pix",
  },
  {
    id: "6",
    description: "Conserto cadeira",
    category: "maintenance",
    amount: 200,
    date: "2025-01-15",
    paidBy: "Conta empresa",
    paymentMethod: "transfer",
  },
];

const categoryConfig = {
  supplies: { label: "Suprimentos", icon: ShoppingCart, color: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400" },
  utilities: { label: "Contas", icon: Zap, color: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400" },
  maintenance: { label: "Manutenção", icon: Wrench, color: "bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-400" },
  other: { label: "Outros", icon: Receipt, color: "bg-muted text-muted-foreground" },
};

const Expenses = () => {
  const totalExpenses = expenses.reduce((sum, e) => sum + e.amount, 0);
  const suppliesTotal = expenses.filter(e => e.category === "supplies").reduce((sum, e) => sum + e.amount, 0);
  const utilitiesTotal = expenses.filter(e => e.category === "utilities").reduce((sum, e) => sum + e.amount, 0);
  const maintenanceTotal = expenses.filter(e => e.category === "maintenance").reduce((sum, e) => sum + e.amount, 0);

  return (
    <DashboardLayout
      title="Despesas"
      subtitle="Controle de gastos da barbearia"
    >
      {/* Header Actions */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input placeholder="Buscar despesa..." className="pl-9" />
        </div>
        <div className="flex gap-2">
          <Button variant="outline">
            <Filter className="w-4 h-4 mr-2" />
            Filtrar
          </Button>
          <Button variant="premium">
            <Plus className="w-4 h-4 mr-2" />
            Nova Despesa
          </Button>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card className="border bg-red-50 dark:bg-red-900/20">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
              <TrendingDown className="w-6 h-6 text-destructive" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Total Mês</p>
              <p className="text-2xl font-bold text-foreground">
                R$ {totalExpenses.toFixed(2)}
              </p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
              <ShoppingCart className="w-6 h-6 text-blue-600 dark:text-blue-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Suprimentos</p>
              <p className="text-2xl font-bold text-foreground">
                R$ {suppliesTotal.toFixed(2)}
              </p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
              <Zap className="w-6 h-6 text-amber-600 dark:text-amber-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Contas</p>
              <p className="text-2xl font-bold text-foreground">
                R$ {utilitiesTotal.toFixed(2)}
              </p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center">
              <Wrench className="w-6 h-6 text-purple-600 dark:text-purple-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Manutenção</p>
              <p className="text-2xl font-bold text-foreground">
                R$ {maintenanceTotal.toFixed(2)}
              </p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Expenses List */}
      <Card className="border">
        <CardHeader className="pb-3">
          <div className="flex items-center justify-between">
            <CardTitle className="text-lg font-semibold">Despesas do Mês</CardTitle>
            <Badge variant="outline">{expenses.length} registros</Badge>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <div className="divide-y divide-border">
            {expenses.map((expense) => {
              const CategoryIcon = categoryConfig[expense.category].icon;
              
              return (
                <div
                  key={expense.id}
                  className="flex items-center justify-between px-6 py-4 hover:bg-muted/50 transition-colors"
                >
                  <div className="flex items-center gap-4">
                    <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${
                      categoryConfig[expense.category].color.split(" ").slice(0, 2).join(" ")
                    }`}>
                      <CategoryIcon className={`w-5 h-5 ${
                        categoryConfig[expense.category].color.split(" ").slice(2).join(" ")
                      }`} />
                    </div>
                    <div>
                      <p className="font-medium text-foreground">{expense.description}</p>
                      <div className="flex items-center gap-2 text-sm text-muted-foreground">
                        <Badge className={categoryConfig[expense.category].color}>
                          {categoryConfig[expense.category].label}
                        </Badge>
                        <span>•</span>
                        <span>{expense.paidBy}</span>
                      </div>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="font-semibold text-destructive">
                      - R$ {expense.amount.toFixed(2)}
                    </p>
                    <div className="flex items-center gap-1 justify-end text-sm text-muted-foreground">
                      <Calendar className="w-3.5 h-3.5" />
                      <span>{new Date(expense.date).toLocaleDateString("pt-BR")}</span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>
    </DashboardLayout>
  );
};

export default Expenses;
