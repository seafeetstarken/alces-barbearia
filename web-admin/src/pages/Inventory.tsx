import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { 
  Plus, 
  Search, 
  Package,
  ArrowUpRight,
  ArrowDownRight,
  AlertTriangle,
  ClipboardList,
  TrendingUp,
  TrendingDown,
} from "lucide-react";
import { Input } from "@/components/ui/input";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";

interface StockMovement {
  id: string;
  productName: string;
  type: "in" | "out" | "adjustment";
  quantity: number;
  reason: string;
  date: string;
  user: string;
}

const movements: StockMovement[] = [];

interface StockSummary {
  productName: string;
  sku: string;
  currentStock: number;
  minStock: number;
  lastMovement: string;
  status: "ok" | "low" | "out";
}

const stockSummary: StockSummary[] = [];

const Inventory = () => {
  const totalProducts = stockSummary.length;
  const lowStockCount = stockSummary.filter(s => s.status === "low").length;
  const outOfStockCount = stockSummary.filter(s => s.status === "out").length;

  return (
    <DashboardLayout
      title="Estoque"
      subtitle="Controle de inventário"
    >
      {/* Header Actions */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input placeholder="Buscar produto..." className="pl-9" />
        </div>
        <div className="flex gap-2">
          <Button variant="outline">
            <ClipboardList className="w-4 h-4 mr-2" />
            Inventário
          </Button>
          <Button variant="premium">
            <Plus className="w-4 h-4 mr-2" />
            Entrada de Estoque
          </Button>
        </div>
      </div>

      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
              <Package className="w-6 h-6 text-primary" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Total Produtos</p>
              <p className="text-2xl font-bold text-foreground">{totalProducts}</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
              <TrendingUp className="w-6 h-6 text-green-600 dark:text-green-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Estoque Ok</p>
              <p className="text-2xl font-bold text-foreground">
                {totalProducts - lowStockCount - outOfStockCount}
              </p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center">
              <AlertTriangle className="w-6 h-6 text-amber-600 dark:text-amber-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Estoque Baixo</p>
              <p className="text-2xl font-bold text-foreground">{lowStockCount}</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
              <TrendingDown className="w-6 h-6 text-destructive" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Sem Estoque</p>
              <p className="text-2xl font-bold text-foreground">{outOfStockCount}</p>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Stock Summary */}
        <Card className="border">
          <CardHeader className="pb-3">
            <CardTitle className="text-lg font-semibold">Resumo do Estoque</CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Produto</TableHead>
                  <TableHead className="text-center">Qtd</TableHead>
                  <TableHead className="text-right">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {stockSummary.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={3} className="text-center py-6 text-muted-foreground text-sm">
                      Nenhum produto cadastrado no estoque.
                    </TableCell>
                  </TableRow>
                ) : (
                  stockSummary.map((item) => (
                    <TableRow key={item.sku}>
                      <TableCell>
                        <div>
                          <p className="font-medium text-foreground">{item.productName}</p>
                          <p className="text-xs text-muted-foreground">{item.sku}</p>
                        </div>
                      </TableCell>
                      <TableCell className="text-center font-medium">
                        {item.currentStock}
                      </TableCell>
                      <TableCell className="text-right">
                        {item.status === "ok" && (
                          <Badge variant="secondary">OK</Badge>
                        )}
                        {item.status === "low" && (
                          <Badge className="bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400">
                            Baixo
                          </Badge>
                        )}
                        {item.status === "out" && (
                          <Badge variant="destructive">Zerado</Badge>
                        )}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {/* Recent Movements */}
        <Card className="border">
          <CardHeader className="pb-3">
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg font-semibold">Movimentações Recentes</CardTitle>
              <button className="text-sm text-primary hover:underline">Ver todas</button>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <div className="divide-y divide-border">
              {movements.length === 0 ? (
                <p className="text-sm text-muted-foreground text-center py-8">
                  Nenhuma movimentação de estoque recente.
                </p>
              ) : (
                movements.map((movement) => (
                  <div
                    key={movement.id}
                    className="flex items-center justify-between px-6 py-3"
                  >
                    <div className="flex items-center gap-3">
                      <div className={`w-8 h-8 rounded-lg flex items-center justify-center ${
                        movement.type === "in"
                          ? "bg-green-100 dark:bg-green-900/30"
                          : movement.type === "out"
                          ? "bg-red-100 dark:bg-red-900/30"
                          : "bg-amber-100 dark:bg-amber-900/30"
                      }`}>
                        {movement.type === "in" ? (
                          <ArrowUpRight className="w-4 h-4 text-green-600 dark:text-green-400" />
                        ) : movement.type === "out" ? (
                          <ArrowDownRight className="w-4 h-4 text-destructive" />
                        ) : (
                          <AlertTriangle className="w-4 h-4 text-amber-600 dark:text-amber-400" />
                        )}
                      </div>
                      <div>
                        <p className="font-medium text-foreground text-sm">
                          {movement.productName}
                        </p>
                        <p className="text-xs text-muted-foreground">
                          {movement.reason} • {movement.user}
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className={`font-semibold text-sm ${
                        movement.type === "in"
                          ? "text-green-600 dark:text-green-400"
                          : "text-destructive"
                      }`}>
                        {movement.type === "in" ? "+" : "-"}{Math.abs(movement.quantity)} un.
                      </p>
                      <p className="text-xs text-muted-foreground">
                        {movement.date.split(" ")[0]}
                      </p>
                    </div>
                  </div>
                ))
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </DashboardLayout>
  );
};

export default Inventory;
