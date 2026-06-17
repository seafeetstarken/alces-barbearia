import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ArrowLeft, User, Mail, Phone, Calendar, LogOut, ChevronRight, Scissors } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

const ClientProfile = () => {
  const navigate = useNavigate();
  const [profile, setProfile] = useState({
    name: "João da Silva",
    email: "joao@email.com",
    phone: "(11) 99999-9999",
    birthdate: "1990-05-15",
  });

  const stats = {
    totalVisits: 24,
    lastVisit: "15 Jan 2026",
    favoriteBarber: "Carlos Silva",
    memberSince: "Mar 2023",
  };

  return (
    <div className="min-h-screen bg-background flex flex-col">
      {/* Gold top line */}
      <div className="h-[2px] w-full gold-shimmer flex-shrink-0" />

      {/* Header */}
      <header className="bg-background sticky top-0 z-50 px-5 py-4 flex items-center justify-between border-b border-border">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate("/client")}
            className="w-9 h-9 flex items-center justify-center rounded-xl text-muted-foreground hover:text-foreground hover:bg-muted transition-colors -ml-2"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="font-bold tracking-widest text-sm" style={{ fontFamily: "'Playfair Display', serif" }}>
              MEU PERFIL
            </h1>
            <p className="text-[10px] text-muted-foreground uppercase tracking-widest leading-none mt-0.5">
              Área do Cliente
            </p>
          </div>
        </div>
      </header>

      <main className="flex-1 overflow-y-auto px-5 py-8 pb-24">
        {/* Avatar & Info */}
        <div className="text-center mb-10">
          <div className="w-24 h-24 rounded-full border border-primary/20 bg-primary/5 flex items-center justify-center mx-auto mb-4 relative">
            <User className="w-10 h-10 text-primary" />
            <div className="absolute bottom-0 right-0 w-7 h-7 bg-card border border-border rounded-full flex items-center justify-center">
              <Scissors className="w-3.5 h-3.5 text-primary" />
            </div>
          </div>
          <h2 className="text-2xl font-bold mb-1" style={{ fontFamily: "'Playfair Display', serif" }}>
            {profile.name}
          </h2>
          <p className="text-xs text-muted-foreground uppercase tracking-widest">
            Desde {stats.memberSince}
          </p>
        </div>

        {/* Stats Row */}
        <div className="grid grid-cols-2 gap-3 mb-10">
          <div className="bg-card border border-border rounded-2xl p-4 text-center">
            <p className="text-3xl font-light text-primary mb-1" style={{ fontFamily: "'Playfair Display', serif" }}>
              {stats.totalVisits}
            </p>
            <p className="text-[10px] text-muted-foreground uppercase tracking-widest leading-none">Visitas</p>
          </div>
          <div className="bg-card border border-border rounded-2xl p-4 flex flex-col items-center justify-center text-center">
            <p className="text-sm font-semibold mb-1 truncate w-full">{stats.favoriteBarber}</p>
            <p className="text-[10px] text-muted-foreground uppercase tracking-widest leading-none">Barbeiro Favorito</p>
          </div>
        </div>

        {/* Edit Form */}
        <section className="mb-10">
          <h3 className="text-xs uppercase tracking-[0.18em] text-muted-foreground mb-4">Dados Pessoais</h3>
          <div className="space-y-4 bg-card border border-border rounded-2xl p-5">
            <div className="space-y-1.5">
              <label className="text-[10px] text-muted-foreground uppercase tracking-wider">Nome</label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground/50" />
                <Input
                  value={profile.name}
                  onChange={(e) => setProfile({ ...profile, name: e.target.value })}
                  className="pl-10 h-11 bg-background border-border text-sm rounded-xl focus:border-primary/50"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-[10px] text-muted-foreground uppercase tracking-wider">E-mail</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground/50" />
                <Input
                  type="email"
                  value={profile.email}
                  onChange={(e) => setProfile({ ...profile, email: e.target.value })}
                  className="pl-10 h-11 bg-background border-border text-sm rounded-xl focus:border-primary/50"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-[10px] text-muted-foreground uppercase tracking-wider">Telefone</label>
              <div className="relative">
                <Phone className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground/50" />
                <Input
                  value={profile.phone}
                  onChange={(e) => setProfile({ ...profile, phone: e.target.value })}
                  className="pl-10 h-11 bg-background border-border text-sm rounded-xl focus:border-primary/50"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-[10px] text-muted-foreground uppercase tracking-wider">Nascimento</label>
              <div className="relative">
                <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground/50" />
                <Input
                  type="date"
                  value={profile.birthdate}
                  onChange={(e) => setProfile({ ...profile, birthdate: e.target.value })}
                  className="pl-10 h-11 bg-background border-border text-sm rounded-xl focus:border-primary/50"
                />
              </div>
            </div>

            <Button className="w-full h-11 rounded-xl font-semibold text-sm gold-shimmer text-[#0d0d0d] border-0 hover:opacity-90 mt-2">
              Salvar Alterações
            </Button>
          </div>
        </section>

        {/* Menu Links */}
        <section className="mb-10">
          <div className="bg-card border border-border rounded-2xl overflow-hidden divide-y divide-border">
            {[
              { label: "Meus Agendamentos", href: "/client/appointments" },
              { label: "Carteira e Pagamentos", href: "/client/wallet" },
              { label: "Clube de Corte", href: "/client/subscription" },
            ].map((item) => (
              <button
                key={item.href}
                className="w-full flex items-center justify-between p-4 hover:bg-muted/50 transition-colors group"
                onClick={() => navigate(item.href)}
              >
                <span className="text-sm font-medium">{item.label}</span>
                <ChevronRight className="w-4 h-4 text-muted-foreground group-hover:text-primary transition-colors" />
              </button>
            ))}
          </div>
        </section>

        {/* Logout */}
        <button
          onClick={() => navigate("/client")}
          className="w-full flex items-center justify-center gap-2 h-12 rounded-xl border border-destructive/20 text-destructive hover:bg-destructive/10 transition-colors text-sm font-semibold"
        >
          <LogOut className="w-4 h-4" />
          Sair da Conta
        </button>
      </main>
    </div>
  );
};

export default ClientProfile;
