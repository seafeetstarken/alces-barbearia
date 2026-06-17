import { useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Separator } from "@/components/ui/separator";
import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs";
import { 
  Store,
  Palette,
  Coins,
  Bell,
  Upload,
} from "lucide-react";
import { useTheme } from "next-themes";
import { BrandingPreview } from "@/components/settings/BrandingPreview";

const fontOptions = [
  { value: "Source Sans Pro", label: "Source Sans Pro" },
  { value: "Inter", label: "Inter" },
  { value: "Poppins", label: "Poppins" },
  { value: "Roboto", label: "Roboto" },
  { value: "Playfair Display", label: "Playfair Display" },
];

const radiusOptions = [
  { value: "0", label: "Nenhum" },
  { value: "0.5", label: "Suave" },
  { value: "1", label: "Médio" },
  { value: "1.5", label: "Arredondado" },
  { value: "2", label: "Muito Arredondado" },
];

const spacingOptions = [
  { value: "compact", label: "Compacto" },
  { value: "normal", label: "Normal" },
  { value: "relaxed", label: "Espaçado" },
];

const Settings = () => {
  const { setTheme, theme } = useTheme();
  const [brandColors, setBrandColors] = useState({
    primary: "#F59E0B",
    secondary: "#6B7280",
    background: "#1A1614",
    card: "#26211E",
  });
  const [fontFamily, setFontFamily] = useState("Source Sans Pro");
  const [borderRadius, setBorderRadius] = useState("1");
  const [spacing, setSpacing] = useState("normal");

  const handleColorChange = (key: keyof typeof brandColors, value: string) => {
    setBrandColors(prev => ({ ...prev, [key]: value }));
  };

  return (
    <DashboardLayout
      title="Configurações"
      subtitle="Personalize sua barbearia"
    >
      <Tabs defaultValue="general" className="w-full">
        <TabsList className="mb-6">
          <TabsTrigger value="general">
            <Store className="w-4 h-4 mr-2" />
            Geral
          </TabsTrigger>
          <TabsTrigger value="branding">
            <Palette className="w-4 h-4 mr-2" />
            Marca
          </TabsTrigger>
          <TabsTrigger value="commission">
            <Coins className="w-4 h-4 mr-2" />
            Comissões
          </TabsTrigger>
          <TabsTrigger value="notifications">
            <Bell className="w-4 h-4 mr-2" />
            Notificações
          </TabsTrigger>
        </TabsList>

        {/* General Settings */}
        <TabsContent value="general">
          <div className="space-y-6">
            <Card className="border">
              <CardHeader>
                <CardTitle>Informações da Loja</CardTitle>
                <CardDescription>Dados básicos da sua barbearia</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="storeName">Nome da Loja</Label>
                    <Input id="storeName" defaultValue="Barbearia Central" />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="phone">Telefone</Label>
                    <Input id="phone" defaultValue="(11) 99999-0000" />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="address">Endereço</Label>
                  <Input id="address" defaultValue="Av. Paulista, 1000 - São Paulo" />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="openTime">Horário de Abertura</Label>
                    <Input id="openTime" type="time" defaultValue="08:00" />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="closeTime">Horário de Fechamento</Label>
                    <Input id="closeTime" type="time" defaultValue="20:00" />
                  </div>
                </div>
                <Button>Salvar Alterações</Button>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* Branding Settings (White Label) */}
        <TabsContent value="branding">
          <div className="space-y-6">
            <Card className="border">
              <CardHeader>
                <CardTitle>Identidade Visual</CardTitle>
                <CardDescription>Personalize a aparência do sistema com sua marca</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                {/* Logo */}
                <div className="space-y-2">
                  <Label>Logo da Empresa</Label>
                  <div className="flex items-center gap-4">
                    <div className="w-20 h-20 rounded-lg bg-muted flex items-center justify-center border-2 border-dashed border-border">
                      <Store className="w-8 h-8 text-muted-foreground" />
                    </div>
                    <Button variant="outline">
                      <Upload className="w-4 h-4 mr-2" />
                      Enviar Logo
                    </Button>
                  </div>
                  <p className="text-xs text-muted-foreground">
                    Recomendado: 200x200px, PNG ou SVG
                  </p>
                </div>

                <Separator />

                {/* Theme Selection */}
                <div className="space-y-4">
                  <Label>Tema de Fundo</Label>
                  <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                    <button
                      type="button"
                      onClick={() => setTheme("dark")}
                      className={`p-4 rounded-lg border-2 ${theme === "dark" ? "border-primary" : "border-border"} bg-[hsl(24,9%,10%)] text-[hsl(60,9%,97%)] flex flex-col items-center gap-2 transition-all hover:scale-105`}
                    >
                      <div className="w-full h-12 rounded bg-[hsl(12,6%,15%)] border border-[hsl(33,5%,32%)]" />
                      <span className="text-sm font-medium">Escuro</span>
                      <span className="text-xs opacity-60">Recomendado</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => setTheme("light")}
                      className={`p-4 rounded-lg border-2 ${theme === "light" ? "border-primary" : "border-border"} bg-[hsl(60,4%,95%)] text-[hsl(24,9%,10%)] flex flex-col items-center gap-2 transition-all hover:scale-105`}
                    >
                      <div className="w-full h-12 rounded bg-[hsl(60,9%,97%)] border border-[hsl(23,5%,82%)]" />
                      <span className="text-sm font-medium">Claro</span>
                    </button>
                    <button
                      type="button"
                      onClick={() => setTheme("system")}
                      className={`p-4 rounded-lg border-2 ${theme === "system" ? "border-primary" : "border-border"} bg-gradient-to-b from-[hsl(24,9%,10%)] to-[hsl(60,4%,95%)] flex flex-col items-center gap-2 transition-all hover:scale-105`}
                    >
                      <div className="w-full h-12 rounded bg-gradient-to-r from-[hsl(12,6%,15%)] to-[hsl(60,9%,97%)] border" />
                      <span className="text-sm font-medium text-[hsl(60,9%,97%)]">Automático</span>
                      <span className="text-xs text-[hsl(60,9%,97%)]/60">Sistema</span>
                    </button>
                  </div>
                </div>

                <Separator />

                {/* Typography & Spacing */}
                <div className="space-y-4">
                  <Label>Tipografia e Layout</Label>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div className="space-y-2">
                      <Label className="text-xs text-muted-foreground">Fonte Principal</Label>
                      <select
                        value={fontFamily}
                        onChange={(e) => setFontFamily(e.target.value)}
                        className="w-full h-10 rounded-md border border-input bg-background px-3 py-2 text-sm"
                      >
                        {fontOptions.map((font) => (
                          <option key={font.value} value={font.value}>
                            {font.label}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-xs text-muted-foreground">Bordas Arredondadas</Label>
                      <select
                        value={borderRadius}
                        onChange={(e) => setBorderRadius(e.target.value)}
                        className="w-full h-10 rounded-md border border-input bg-background px-3 py-2 text-sm"
                      >
                        {radiusOptions.map((r) => (
                          <option key={r.value} value={r.value}>
                            {r.label}
                          </option>
                        ))}
                      </select>
                    </div>
                    <div className="space-y-2">
                      <Label className="text-xs text-muted-foreground">Espaçamento</Label>
                      <select
                        value={spacing}
                        onChange={(e) => setSpacing(e.target.value)}
                        className="w-full h-10 rounded-md border border-input bg-background px-3 py-2 text-sm"
                      >
                        {spacingOptions.map((s) => (
                          <option key={s.value} value={s.value}>
                            {s.label}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>
                </div>

                <Separator />

                {/* Colors with Live Preview */}
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                  <div className="space-y-4">
                    <Label>Cores da Marca</Label>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label className="text-xs text-muted-foreground">Cor Principal</Label>
                        <div className="flex items-center gap-2">
                          <input
                            type="color"
                            value={brandColors.primary}
                            onChange={(e) => handleColorChange("primary", e.target.value)}
                            className="w-10 h-10 rounded-lg border cursor-pointer"
                          />
                          <Input
                            value={brandColors.primary}
                            onChange={(e) => handleColorChange("primary", e.target.value)}
                            className="font-mono text-sm"
                          />
                        </div>
                      </div>
                      <div className="space-y-2">
                        <Label className="text-xs text-muted-foreground">Cor Secundária</Label>
                        <div className="flex items-center gap-2">
                          <input
                            type="color"
                            value={brandColors.secondary}
                            onChange={(e) => handleColorChange("secondary", e.target.value)}
                            className="w-10 h-10 rounded-lg border cursor-pointer"
                          />
                          <Input
                            value={brandColors.secondary}
                            onChange={(e) => handleColorChange("secondary", e.target.value)}
                            className="font-mono text-sm"
                          />
                        </div>
                      </div>
                      <div className="space-y-2">
                        <Label className="text-xs text-muted-foreground">Cor de Fundo</Label>
                        <div className="flex items-center gap-2">
                          <input
                            type="color"
                            value={brandColors.background}
                            onChange={(e) => handleColorChange("background", e.target.value)}
                            className="w-10 h-10 rounded-lg border cursor-pointer"
                          />
                          <Input
                            value={brandColors.background}
                            onChange={(e) => handleColorChange("background", e.target.value)}
                            className="font-mono text-sm"
                          />
                        </div>
                      </div>
                      <div className="space-y-2">
                        <Label className="text-xs text-muted-foreground">Cor de Card</Label>
                        <div className="flex items-center gap-2">
                          <input
                            type="color"
                            value={brandColors.card}
                            onChange={(e) => handleColorChange("card", e.target.value)}
                            className="w-10 h-10 rounded-lg border cursor-pointer"
                          />
                          <Input
                            value={brandColors.card}
                            onChange={(e) => handleColorChange("card", e.target.value)}
                            className="font-mono text-sm"
                          />
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Live Preview */}
                  <BrandingPreview
                    primaryColor={brandColors.primary}
                    secondaryColor={brandColors.secondary}
                    backgroundColor={brandColors.background}
                    cardColor={brandColors.card}
                    fontFamily={fontFamily}
                    borderRadius={borderRadius}
                    spacing={spacing}
                  />
                </div>

                <Separator />

                {/* Custom Domain (placeholder) */}
                <div className="space-y-2">
                  <Label htmlFor="domain">Domínio Personalizado</Label>
                  <Input id="domain" placeholder="app.suabarbearia.com.br" />
                  <p className="text-xs text-muted-foreground">
                    Configure um domínio personalizado para seus clientes acessarem
                  </p>
                </div>

                <Button>Salvar Marca</Button>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* Commission Settings */}
        <TabsContent value="commission">
          <div className="space-y-6">
            <Card className="border">
              <CardHeader>
                <CardTitle>Sistema de Comissões</CardTitle>
                <CardDescription>Configure como as comissões são calculadas</CardDescription>
              </CardHeader>
              <CardContent className="space-y-6">
                <div className="p-4 rounded-lg bg-primary/5 border border-primary/20">
                  <h4 className="font-semibold text-foreground mb-2">Modelo: Splitshare por Pontos</h4>
                  <p className="text-sm text-muted-foreground">
                    43% do faturamento é distribuído entre os barbeiros proporcionalmente aos pontos acumulados.
                  </p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="percentage">Percentual de Distribuição</Label>
                    <div className="flex items-center gap-2">
                      <Input id="percentage" type="number" defaultValue="43" />
                      <span className="text-muted-foreground">%</span>
                    </div>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="baseValue">Valor Base por Ponto</Label>
                    <div className="flex items-center gap-2">
                      <span className="text-muted-foreground">R$</span>
                      <Input id="baseValue" type="number" defaultValue="15.75" step="0.01" />
                    </div>
                  </div>
                </div>

                <Separator />

                <div className="space-y-4">
                  <h4 className="font-semibold text-foreground">Pontuação por Serviço</h4>
                  <div className="space-y-3">
                    {[
                      { service: "Corte", points: 1 },
                      { service: "Corte + Barba", points: 2 },
                      { service: "Barba", points: 1 },
                      { service: "Pigmentação", points: 2 },
                    ].map((item) => (
                      <div key={item.service} className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                        <span className="font-medium text-foreground">{item.service}</span>
                        <div className="flex items-center gap-2">
                          <Input 
                            type="number" 
                            defaultValue={item.points} 
                            className="w-20 text-center"
                          />
                          <span className="text-muted-foreground">pontos</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <Button>Salvar Configurações</Button>
              </CardContent>
            </Card>

            <Card className="border">
              <CardHeader>
                <CardTitle>Multiplicadores de Nível</CardTitle>
                <CardDescription>Defina os multiplicadores para cada nível de carreira</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                {[
                  { level: "Júnior", multiplier: 0.8 },
                  { level: "Profissional", multiplier: 1.0 },
                  { level: "Sênior", multiplier: 1.2 },
                  { level: "Master", multiplier: 1.5 },
                ].map((item) => (
                  <div key={item.level} className="flex items-center justify-between p-3 rounded-lg bg-muted/50">
                    <span className="font-medium text-foreground">{item.level}</span>
                    <div className="flex items-center gap-2">
                      <Input 
                        type="number" 
                        defaultValue={item.multiplier} 
                        step="0.1"
                        className="w-20 text-center"
                      />
                      <span className="text-muted-foreground">x</span>
                    </div>
                  </div>
                ))}
                <Button>Salvar Multiplicadores</Button>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* Notifications */}
        <TabsContent value="notifications">
          <Card className="border">
            <CardHeader>
              <CardTitle>Preferências de Notificação</CardTitle>
              <CardDescription>Configure como e quando receber alertas</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {[
                { 
                  title: "Caixa aberto/fechado", 
                  description: "Receba alertas quando o caixa for aberto ou fechado",
                  enabled: true 
                },
                { 
                  title: "Meta alcançada", 
                  description: "Seja notificado quando um barbeiro atingir uma meta",
                  enabled: true 
                },
                { 
                  title: "Estoque baixo", 
                  description: "Alerta quando produtos estiverem com estoque baixo",
                  enabled: true 
                },
                { 
                  title: "Novo cliente", 
                  description: "Notificação quando um novo cliente for cadastrado",
                  enabled: false 
                },
                { 
                  title: "Relatório diário", 
                  description: "Receba um resumo do dia ao fechar o caixa",
                  enabled: true 
                },
              ].map((notification) => (
                <div key={notification.title} className="flex items-center justify-between">
                  <div className="space-y-0.5">
                    <p className="font-medium text-foreground">{notification.title}</p>
                    <p className="text-sm text-muted-foreground">{notification.description}</p>
                  </div>
                  <Switch defaultChecked={notification.enabled} />
                </div>
              ))}
              <Button>Salvar Preferências</Button>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </DashboardLayout>
  );
};

export default Settings;
