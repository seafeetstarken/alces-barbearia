import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { ArrowLeft, CreditCard, Plus, Trash2, Star, Receipt, Calendar, ShoppingBag } from "lucide-react";
import { useClients } from "@/hooks/useClients";
import { useCashback } from "@/hooks/useCashback";
import { DataState } from "@/components/ui/data-state";

const defaultCards = [
  { id: 1, last4: "4242", brand: "Visa", expiry: "12/26", isDefault: true },
  { id: 2, last4: "8888", brand: "Mastercard", expiry: "08/25", isDefault: false },
];

const ClientWallet = () => {
  const navigate = useNavigate();
  const storeId = typeof window !== "undefined" ? localStorage.getItem("active_store_id") ?? undefined : undefined;
  const { activeClients, isLoading: isClientsLoading } = useClients(storeId);
  const clientId = activeClients[0]?.id;
  const { balance, statement, isLoading, error } = useCashback(storeId, clientId);
  const [cards, setCards] = useState(defaultCards);
  const [isAddingCard, setIsAddingCard] = useState(false);
  const [newCard, setNewCard] = useState({ number: "", expiry: "", cvv: "", name: "" });

  const setDefaultCard = (id: number) => {
    setCards(cards.map(c => ({ ...c, isDefault: c.id === id })));
  };

  const removeCard = (id: number) => {
    setCards(cards.filter(c => c.id !== id));
  };

  const addCard = () => {
    const last4 = newCard.number.slice(-4) || "0000";
    setCards([...cards, {
      id: Date.now(),
      last4,
      brand: "Visa",
      expiry: newCard.expiry || "12/28",
      isDefault: false
    }]);
    setNewCard({ number: "", expiry: "", cvv: "", name: "" });
    setIsAddingCard(false);
  };

  const getTransactionIcon = (type: string) => {
    switch (type) {
      case "credit": return <Star className="w-4 h-4" />;
      case "debit": return <ShoppingBag className="w-4 h-4" />;
      case "expire": return <Calendar className="w-4 h-4" />;
      default: return <Receipt className="w-4 h-4" />;
    }
  };

  if (!storeId) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState
          variant="empty"
          title="Loja não selecionada"
          description="Selecione uma loja no painel administrativo para usar carteira."
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
        <DataState variant="loading" title="Carregando carteira" description="Buscando saldo e extrato de cashback." />
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-background p-5">
        <DataState variant="error" title="Falha ao carregar carteira" description="Tente novamente em alguns instantes." />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <header className="bg-card border-b border-border sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4 flex items-center gap-4">
          <Button variant="ghost" size="icon" onClick={() => navigate("/client/profile")}>
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <h1 className="font-semibold">Carteira</h1>
        </div>
      </header>

      <main className="container mx-auto px-4 py-6">
        <Card className="mb-6 bg-primary/5 border-primary/20">
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Saldo de Cashback</CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-3xl font-bold text-primary">R$ {balance.toFixed(2)}</p>
            <p className="text-sm text-muted-foreground">Disponível para uso no checkout</p>
          </CardContent>
        </Card>

        <Tabs defaultValue="cards">
          <TabsList className="w-full mb-6">
            <TabsTrigger value="cards" className="flex-1">Cartões</TabsTrigger>
            <TabsTrigger value="history" className="flex-1">Histórico</TabsTrigger>
          </TabsList>

          <TabsContent value="cards" className="space-y-4">
            {cards.map((card) => (
              <Card key={card.id} className={card.isDefault ? "ring-1 ring-primary" : ""}>
                <CardContent className="p-4">
                  <div className="flex items-center gap-4">
                    <div className="w-14 h-10 rounded-lg bg-gradient-to-br from-muted to-muted-foreground/20 flex items-center justify-center">
                      <CreditCard className="w-6 h-6 text-foreground/70" />
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2">
                        <p className="font-medium">{card.brand} •••• {card.last4}</p>
                        {card.isDefault && (
                          <Badge variant="secondary" className="text-xs">Padrão</Badge>
                        )}
                      </div>
                      <p className="text-sm text-muted-foreground">Expira em {card.expiry}</p>
                    </div>
                    <div className="flex gap-2">
                      {!card.isDefault && (
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setDefaultCard(card.id)}
                        >
                          Usar como padrão
                        </Button>
                      )}
                      <Button
                        variant="ghost"
                        size="icon"
                        className="text-destructive hover:text-destructive"
                        onClick={() => removeCard(card.id)}
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}

            <Dialog open={isAddingCard} onOpenChange={setIsAddingCard}>
              <DialogTrigger asChild>
                <Button variant="outline" className="w-full h-14">
                  <Plus className="w-4 h-4 mr-2" />
                  Adicionar Cartão
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Adicionar Cartão</DialogTitle>
                </DialogHeader>
                <div className="space-y-4 pt-4">
                  <div className="space-y-2">
                    <Label>Número do cartão</Label>
                    <Input
                      placeholder="0000 0000 0000 0000"
                      value={newCard.number}
                      onChange={(e) => setNewCard({ ...newCard, number: e.target.value })}
                    />
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-2">
                      <Label>Validade</Label>
                      <Input
                        placeholder="MM/AA"
                        value={newCard.expiry}
                        onChange={(e) => setNewCard({ ...newCard, expiry: e.target.value })}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>CVV</Label>
                      <Input
                        placeholder="123"
                        value={newCard.cvv}
                        onChange={(e) => setNewCard({ ...newCard, cvv: e.target.value })}
                      />
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label>Nome no cartão</Label>
                    <Input
                      placeholder="Como está no cartão"
                      value={newCard.name}
                      onChange={(e) => setNewCard({ ...newCard, name: e.target.value })}
                    />
                  </div>
                  <Button className="w-full" onClick={addCard}>
                    Salvar Cartão
                  </Button>
                </div>
              </DialogContent>
            </Dialog>
          </TabsContent>

          <TabsContent value="history" className="space-y-4">
            {statement.map((tx) => (
              <Card key={tx.id}>
                <CardContent className="p-4">
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-full bg-muted flex items-center justify-center">
                      {getTransactionIcon(tx.movement_type)}
                    </div>
                    <div className="flex-1">
                      <p className="font-medium">{tx.description ?? "Movimentação de cashback"}</p>
                      <p className="text-sm text-muted-foreground">
                        {new Date(tx.created_at).toLocaleDateString("pt-BR")}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className={`font-semibold ${tx.movement_type === "debit" || tx.movement_type === "expire" ? "text-destructive" : "text-primary"}`}>
                        {tx.movement_type === "debit" || tx.movement_type === "expire" ? "-" : "+"} R$ {tx.amount.toFixed(2)}
                      </p>
                      <Badge variant="outline" className="text-xs">{tx.movement_type}</Badge>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
            {statement.length === 0 && (
              <DataState
                variant="empty"
                title="Sem movimentações"
                description="Seu extrato de cashback aparecerá aqui após os próximos pagamentos."
              />
            )}
          </TabsContent>
        </Tabs>
      </main>
    </div>
  );
};

export default ClientWallet;
