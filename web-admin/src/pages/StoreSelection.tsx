import { useNavigate } from "react-router-dom";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Store, MapPin, Users, ChevronRight, Plus, LogOut } from "lucide-react";
import { useStore } from "@/hooks/useStore";
import { useBarbers } from "@/hooks/useBarbers";
import { useAuth } from "@/contexts/AuthContext";

const StoreSelection = () => {
  const navigate = useNavigate();
  const { stores, setActiveStoreId, isLoading } = useStore();
  const { signOut } = useAuth();
  const { barbers } = useBarbers();

  const handleSelectStore = (storeId: string) => {
    setActiveStoreId(storeId);
    navigate(`/dashboard/${storeId}`);
  };

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 flex items-center justify-center">
              <img src="/alces-logo.png" alt="Alce's Logo" className="w-full h-full object-contain" />
            </div>
            <div>
              <h1 className="font-semibold text-foreground text-lg leading-tight" style={{ fontFamily: "'Playfair Display', serif" }}>Alce's</h1>
              <p className="text-xs tracking-[0.2em] uppercase text-muted-foreground">Barbearia</p>
            </div>
          </div>
          <Button variant="ghost" size="sm" onClick={signOut}>
            <LogOut className="w-4 h-4 mr-2" />
            Sair
          </Button>
        </div>
      </header>

      {/* Content */}
      <main className="container mx-auto px-4 py-8">
        <div className="max-w-3xl mx-auto">
          {/* Title */}
          <div className="mb-8">
            <h2 className="text-2xl font-bold text-foreground mb-2">
              Selecione uma loja
            </h2>
            <p className="text-muted-foreground">
              Escolha a unidade que deseja gerenciar
            </p>
          </div>

          {/* Store Cards */}
          <div className="space-y-3">
            {isLoading && (
              <Card className="border">
                <CardContent className="p-4 space-y-3">
                  <Skeleton className="h-6 w-56" />
                  <Skeleton className="h-4 w-80" />
                </CardContent>
              </Card>
            )}
            {!isLoading && stores.map((store) => (
              (() => {
                const hasWorkingHours = Boolean(store.open_time && store.close_time);
                return (
              <Card
                key={store.id}
                className="group cursor-pointer hover:shadow-lg transition-all duration-200 border hover:border-primary/30"
                onClick={() => handleSelectStore(store.id)}
              >
                <CardContent className="p-4">
                  <div className="flex items-center gap-4">
                    {/* Store Icon */}
                    <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
                      <Store className="w-6 h-6 text-primary" />
                    </div>

                    {/* Store Info */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="font-semibold text-foreground truncate">
                          {store.name}
                        </h3>
                        <span
                          className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium ${
                            hasWorkingHours
                              ? "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400"
                              : "bg-muted text-muted-foreground"
                          }`}
                        >
                          {hasWorkingHours ? "Aberta" : "Sem horário"}
                        </span>
                      </div>
                      <div className="flex items-center gap-4 text-sm text-muted-foreground">
                        <span className="flex items-center gap-1">
                          <MapPin className="w-3.5 h-3.5" />
                          {store.address || "Endereço não informado"}
                        </span>
                        <span className="flex items-center gap-1">
                          <Users className="w-3.5 h-3.5" />
                          {barbers.filter((barber) => barber.store_id === store.id).length} barbeiros
                        </span>
                      </div>
                    </div>

                    {/* Arrow */}
                    <ChevronRight className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors" />
                  </div>
                </CardContent>
              </Card>
                );
              })()
            ))}
            {!isLoading && stores.length === 0 && (
              <Card className="border">
                <CardContent className="p-6 text-sm text-muted-foreground">
                  Nenhuma loja vinculada ao seu usuário.
                </CardContent>
              </Card>
            )}
          </div>

          {/* Add Store Button */}
          <Button
            variant="outline"
            className="w-full mt-4 h-14 border-dashed hover:border-primary hover:bg-primary/5"
          >
            <Plus className="w-5 h-5 mr-2" />
            Adicionar nova loja
          </Button>
        </div>
      </main>
    </div>
  );
};

export default StoreSelection;
