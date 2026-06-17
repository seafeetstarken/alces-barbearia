import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { 
  Wallet, 
  ArrowUpRight, 
  ArrowDownRight, 
  CreditCard, 
  Banknote,
  QrCode,
} from "lucide-react";
import { DataState } from "@/components/ui/data-state";

const paymentIconMap = {
  pix: QrCode,
  card: CreditCard,
  cash: Banknote,
} as const;

interface CashRegisterStatusProps {
  isOpen: boolean;
  openedAt?: string;
  totalRevenue: number;
  totalExpenses: number;
  paymentBreakdown: Array<{ method: "pix" | "card" | "cash"; amount: number; count: number }>;
  isLoading?: boolean;
  onToggleCashier?: () => void;
}

const CashRegisterStatus = ({
  isOpen,
  openedAt,
  totalRevenue,
  totalExpenses,
  paymentBreakdown,
  isLoading,
  onToggleCashier,
}: CashRegisterStatusProps) => {
  const hasMovement = paymentBreakdown.some((item) => item.count > 0);

  return (
    <Card className="border">
      <CardHeader className="pb-3">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <CardTitle className="text-lg font-semibold">Caixa</CardTitle>
            <Badge
              variant={isOpen ? "default" : "secondary"}
              className={isOpen ? "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400" : ""}
            >
              {isOpen ? "Aberto" : "Fechado"}
            </Badge>
          </div>
          <span className="text-sm text-muted-foreground">
            {isOpen && openedAt ? `Aberto às ${openedAt}` : "Sem abertura hoje"}
          </span>
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid grid-cols-2 gap-4">
          <div className="space-y-1">
            <div className="flex items-center gap-1 text-sm text-muted-foreground">
              <ArrowUpRight className="w-4 h-4 text-green-500" />
              Entradas
            </div>
            <p className="text-xl font-bold text-foreground">
              R$ {totalRevenue.toFixed(2)}
            </p>
          </div>
          <div className="space-y-1">
            <div className="flex items-center gap-1 text-sm text-muted-foreground">
              <ArrowDownRight className="w-4 h-4 text-destructive" />
              Saídas
            </div>
            <p className="text-xl font-bold text-foreground">
              R$ {totalExpenses.toFixed(2)}
            </p>
          </div>
        </div>
        <div className="h-px bg-border" />
        {isLoading ? (
          <DataState
            variant="loading"
            title="Carregando caixa"
            description="Buscando movimentações de hoje."
          />
        ) : !hasMovement ? (
          <DataState
            variant="empty"
            title="Sem movimentações por pagamento"
            description="Registre entradas para visualizar o detalhamento."
          />
        ) : (
          <div className="space-y-3">
            <p className="text-sm font-medium text-muted-foreground">Por forma de pagamento</p>
            {paymentBreakdown.map((payment) => {
              const Icon = paymentIconMap[payment.method];
              const paymentLabel = payment.method === "pix" ? "PIX" : payment.method === "card" ? "Cartão" : "Dinheiro";

              return (
                <div key={payment.method} className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <div className="w-8 h-8 rounded-md bg-muted flex items-center justify-center">
                      <Icon className="w-4 h-4 text-muted-foreground" />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-foreground">{paymentLabel}</p>
                      <p className="text-xs text-muted-foreground">{payment.count} transações</p>
                    </div>
                  </div>
                  <p className="font-semibold text-foreground">R$ {payment.amount.toFixed(2)}</p>
                </div>
              );
            })}
          </div>
        )}
        <div className="pt-2">
          <Button className="w-full" variant="soft" onClick={onToggleCashier}>
            <Wallet className="w-4 h-4 mr-2" />
            {isOpen ? "Fechar Caixa" : "Abrir Caixa"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
};

export default CashRegisterStatus;
