import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Badge } from "@/components/ui/badge";
import {
  Scissors,
  Calendar,
  ShoppingBag,
  Clock,
  Star,
  Crown,
  Wallet,
  User,
  ChevronRight,
  MapPin,
  Phone,
} from "lucide-react";

const mockPromos = [
  { id: 1, title: "Combo Corte + Barba", discount: "15% OFF", description: "Aproveite nosso combo mais pedido" },
  { id: 2, title: "Primeira Visita", discount: "20% OFF", description: "Desconto especial para novos clientes" },
];

const mockBarbers = [
  { id: 1, name: "Carlos Silva", specialty: "Cortes Modernos", rating: 4.9, avatar: "CS" },
  { id: 2, name: "João Santos", specialty: "Barba & Bigode", rating: 4.8, avatar: "JS" },
  { id: 3, name: "Pedro Lima", specialty: "Degradê", rating: 4.7, avatar: "PL" },
];

const ClientHome = () => {
  const navigate = useNavigate();
  const [storeName] = useState("ALCES");

  return (
    <div className="min-h-screen bg-background flex flex-col">
      {/* Gold top line */}
      <div className="h-[2px] w-full gold-shimmer flex-shrink-0" />

      {/* Header */}
      <header className="bg-background border-b border-border sticky top-0 z-50 px-5 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg border border-primary/30 bg-primary/10 flex items-center justify-center">
            <Scissors className="w-4 h-4 text-primary" />
          </div>
          <div>
            <span className="font-bold tracking-widest text-sm" style={{ fontFamily: "'Playfair Display', serif" }}>
              {storeName}
            </span>
            <p className="text-[10px] text-muted-foreground uppercase tracking-widest leading-none mt-0.5">
              Premium Barbershop
            </p>
          </div>
        </div>
        <div className="flex items-center gap-1">
          <button
            onClick={() => navigate("/client/wallet")}
            className="w-9 h-9 flex items-center justify-center rounded-xl text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
          >
            <Wallet className="w-4 h-4" />
          </button>
          <button
            onClick={() => navigate("/client/profile")}
            className="w-9 h-9 flex items-center justify-center rounded-xl text-muted-foreground hover:text-foreground hover:bg-muted transition-colors"
          >
            <User className="w-4 h-4" />
          </button>
        </div>
      </header>

      {/* Main Content — scroll area */}
      <main className="flex-1 overflow-y-auto pb-24">
        {/* Hero */}
        <section className="px-5 pt-8 pb-6">
          <p className="text-xs uppercase tracking-[0.2em] text-muted-foreground mb-2">Bem-vindo</p>
          <h1 className="text-3xl font-bold leading-tight mb-1" style={{ fontFamily: "'Playfair Display', serif" }}>
            Estilo e<br />confiança.
          </h1>
          <p className="text-muted-foreground text-sm">Em cada corte, desde sempre.</p>
        </section>

        {/* CTA Buttons */}
        <section className="px-5 mb-7">
          <div className="flex gap-3">
            <button
              onClick={() => navigate("/client/booking")}
              className="flex-1 h-12 rounded-xl gold-shimmer text-[#0d0d0d] font-semibold text-sm flex items-center justify-center gap-2 transition-opacity hover:opacity-90"
            >
              <Calendar className="w-4 h-4" />
              Agendar
            </button>
            <button
              onClick={() => navigate("/client/services")}
              className="flex-1 h-12 rounded-xl border border-border bg-card text-foreground font-medium text-sm flex items-center justify-center gap-2 hover:bg-muted transition-colors"
            >
              <Scissors className="w-4 h-4" />
              Serviços
            </button>
          </div>
        </section>

        {/* Quick Stats Row */}
        <section className="px-5 mb-7">
          <div className="grid grid-cols-3 gap-3">
            {[
              { icon: Clock, label: "Seg–Sáb", sub: "9h às 20h" },
              { icon: MapPin, label: "Av. Principal", sub: "nº 123" },
              { icon: Phone, label: "Contato", sub: "(11) 9 9999-9999" },
            ].map(({ icon: Icon, label, sub }) => (
              <div key={label} className="bg-card border border-border rounded-xl p-3 text-center">
                <Icon className="w-4 h-4 text-primary mx-auto mb-1.5" />
                <p className="text-[11px] font-medium text-foreground leading-tight">{label}</p>
                <p className="text-[10px] text-muted-foreground leading-tight mt-0.5">{sub}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Clube de Corte Banner */}
        <section className="px-5 mb-7">
          <button
            onClick={() => navigate("/client/subscription")}
            className="w-full bg-card border border-border rounded-2xl p-4 flex items-center gap-4 hover:border-primary/30 transition-colors text-left group"
          >
            <div className="w-11 h-11 rounded-xl bg-primary/10 border border-primary/20 flex items-center justify-center flex-shrink-0 group-hover:bg-primary/15 transition-colors">
              <Crown className="w-5 h-5 text-primary" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-0.5">
                <span className="text-sm font-semibold">Clube de Corte</span>
                <Badge className="bg-primary/15 text-primary border-primary/20 text-[10px] px-1.5 py-0 h-4">Novo</Badge>
              </div>
              <p className="text-[11px] text-muted-foreground">1 corte/mês + 15% OFF • R$ 99/mês</p>
            </div>
            <ChevronRight className="w-4 h-4 text-muted-foreground flex-shrink-0" />
          </button>
        </section>

        {/* Promoções */}
        <section className="px-5 mb-7">
          <h2 className="text-xs uppercase tracking-[0.18em] text-muted-foreground mb-3">Promoções</h2>
          <div className="space-y-3">
            {mockPromos.map((promo) => (
              <div key={promo.id} className="bg-card border border-border rounded-xl p-4 flex items-center gap-3">
                <div className="flex-1">
                  <p className="text-sm font-medium">{promo.title}</p>
                  <p className="text-[11px] text-muted-foreground mt-0.5">{promo.description}</p>
                </div>
                <span className="text-xs font-bold text-primary whitespace-nowrap">{promo.discount}</span>
              </div>
            ))}
          </div>
        </section>

        {/* Barbeiros */}
        <section className="px-5 mb-4">
          <h2 className="text-xs uppercase tracking-[0.18em] text-muted-foreground mb-3">Nossos Barbeiros</h2>
          <div className="flex gap-3 overflow-x-auto pb-1 -mx-1 px-1" style={{ scrollbarWidth: "none" }}>
            {mockBarbers.map((barber) => (
              <div
                key={barber.id}
                className="flex-shrink-0 w-36 bg-card border border-border rounded-xl p-4 text-center"
              >
                <div className="w-12 h-12 rounded-full bg-muted border border-border flex items-center justify-center mx-auto mb-3">
                  <span className="text-sm font-semibold text-foreground">{barber.avatar}</span>
                </div>
                <p className="text-xs font-semibold truncate mb-0.5">{barber.name}</p>
                <p className="text-[10px] text-muted-foreground mb-2 truncate">{barber.specialty}</p>
                <div className="flex items-center justify-center gap-1">
                  <Star className="w-3 h-3 fill-primary text-primary" />
                  <span className="text-[11px] font-medium">{barber.rating}</span>
                </div>
              </div>
            ))}
          </div>
        </section>
      </main>

      {/* Bottom Navigation */}
      <nav className="fixed bottom-0 left-0 right-0 bg-card border-t border-border z-50 flex items-center">
        {[
          { icon: Scissors, label: "Início", href: "/client" },
          { icon: Calendar, label: "Agendar", href: "/client/booking" },
          { icon: Clock, label: "Horários", href: "/client/appointments" },
          { icon: ShoppingBag, label: "Loja", href: "/client/shop" },
          { icon: User, label: "Perfil", href: "/client/profile" },
        ].map(({ icon: Icon, label, href }) => (
          <button
            key={href}
            onClick={() => navigate(href)}
            className="flex-1 flex flex-col items-center justify-center py-3 gap-1 text-muted-foreground hover:text-primary transition-colors"
          >
            <Icon className="w-5 h-5" />
            <span className="text-[10px] font-medium">{label}</span>
          </button>
        ))}
      </nav>
    </div>
  );
};

export default ClientHome;
