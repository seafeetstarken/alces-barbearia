import { useState, useEffect } from "react";
import { useNavigate, Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Eye, EyeOff, Loader2 } from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";
import { useToast } from "@/hooks/use-toast";

const Login = () => {
  const navigate = useNavigate();
  const { signIn, user, isLoading: authLoading, isSuperAdmin } = useAuth();
  const { toast } = useToast();

  const [showPassword, setShowPassword] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    // Only auto-redirect if they are already logged in on mount
    if (user && !authLoading && !isLoading) {
      navigate(isSuperAdmin ? "/admin" : "/stores", { replace: true });
    }
  }, [user, authLoading, isSuperAdmin, navigate, isLoading]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    const { error, role } = await signIn(email, password);

    if (error) {
      toast({
        variant: "destructive",
        title: "Erro ao entrar",
        description: getErrorMessage(error.message),
      });
      setIsLoading(false);
      return;
    }

    toast({
      title: "Bem-vindo!",
      description: "Login realizado com sucesso.",
    });
    
    // Explicitly navigate based on the returned role
    navigate(role === 'super_admin' ? "/admin" : "/stores", { replace: true });
  };

  const getErrorMessage = (message: string): string => {
    if (message.includes("Invalid login credentials")) return "Email ou senha incorretos.";
    if (message.includes("Email not confirmed")) return "Confirme seu email antes de entrar.";
    return "Ocorreu um erro. Tente novamente.";
  };

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#0d0d0d]">
        <Loader2 className="w-6 h-6 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0d0d0d] flex flex-col">
      {/* Top decorative bar */}
      <div className="h-1 w-full gold-shimmer" />

      <div className="flex-1 flex flex-col justify-center px-6 py-12 max-w-sm mx-auto w-full">
        {/* Brand */}
        <div className="mb-12 space-y-3">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 flex items-center justify-center">
              <img src="/alces-logo.png" alt="Alce's Logo" className="w-full h-full object-contain drop-shadow-md" />
            </div>
            <span className="text-xs tracking-[0.25em] uppercase text-muted-foreground font-medium">
              Sistema de Gestão
            </span>
          </div>
          <h1
            className="text-4xl font-bold text-white leading-tight"
            style={{ fontFamily: "'Playfair Display', serif" }}
          >
            Alce's<br />Barbearia
          </h1>
          <p className="text-muted-foreground text-sm">
            Acesse com suas credenciais
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleLogin} className="space-y-4">
          <div className="space-y-1.5">
            <label htmlFor="email" className="text-xs text-muted-foreground uppercase tracking-wider">
              Email
            </label>
            <Input
              id="email"
              type="email"
              placeholder="seu@email.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoComplete="email"
              className="h-12 bg-white/5 border-white/10 text-white placeholder:text-white/25 focus:border-primary/50 focus:ring-0 rounded-xl"
            />
          </div>

          <div className="space-y-1.5">
            <div className="flex items-center justify-between">
              <label htmlFor="password" className="text-xs text-muted-foreground uppercase tracking-wider">
                Senha
              </label>
              <Link
                to="/forgot-password"
                className="text-xs text-primary/70 hover:text-primary transition-colors"
              >
                Esqueceu?
              </Link>
            </div>
            <div className="relative">
              <Input
                id="password"
                type={showPassword ? "text" : "password"}
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                autoComplete="current-password"
                className="h-12 bg-white/5 border-white/10 text-white placeholder:text-white/25 focus:border-primary/50 focus:ring-0 rounded-xl pr-11"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-white/30 hover:text-white/70 transition-colors"
              >
                {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
              </button>
            </div>
          </div>

          <div className="pt-2">
            <Button
              type="submit"
              className="w-full h-12 rounded-xl font-semibold tracking-wide text-sm gold-shimmer text-[#0d0d0d] border-0 hover:opacity-90 transition-opacity"
              disabled={isLoading}
            >
              {isLoading ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Entrando...
                </>
              ) : (
                "Entrar"
              )}
            </Button>
          </div>
        </form>

        {/* Footer */}
        <p className="mt-10 text-center text-xs text-white/25">
          Precisa de ajuda?{" "}
          <a
            href="https://api.whatsapp.com/send/?phone=5547996155719"
            target="_blank"
            rel="noopener noreferrer"
            className="text-primary/60 hover:text-primary transition-colors"
          >
            Entre em contato
          </a>
        </p>
      </div>
    </div>
  );
};

export default Login;
