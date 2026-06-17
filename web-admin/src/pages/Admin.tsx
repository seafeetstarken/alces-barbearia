import { useState, useEffect } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import {
    Palette,
    Store,
    Settings2,
    Users,
    Plus,
    Save,
    Loader2,
    Building2,
    Eye,
} from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";
import { supabase } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";
import type { Store as StoreType, Settings } from "@/lib/supabase/types";

const Admin = () => {
    const { user, profile } = useAuth();
    const { toast } = useToast();

    const [stores, setStores] = useState<StoreType[]>([]);
    const [selectedStore, setSelectedStore] = useState<string | null>(null);
    const [settings, setSettings] = useState<Partial<Settings>>({});
    const [isLoading, setIsLoading] = useState(true);
    const [isSaving, setIsSaving] = useState(false);

    // Verificar se é super_admin
    const isSuperAdmin = profile?.role === 'super_admin';

    useEffect(() => {
        fetchStores();
    }, []);

    useEffect(() => {
        if (selectedStore) {
            fetchSettings(selectedStore);
        }
    }, [selectedStore]);

    const fetchStores = async () => {
        const { data, error } = await supabase
            .from('stores')
            .select('*')
            .order('name');

        if (!error && data) {
            setStores(data);
            if (data.length > 0) {
                setSelectedStore(data[0].id);
            }
        }
        setIsLoading(false);
    };

    const fetchSettings = async (storeId: string) => {
        const { data, error } = await supabase
            .from('settings')
            .select('*')
            .eq('store_id', storeId)
            .single();

        if (!error && data) {
            setSettings(data);
        } else {
            // Valores padrão se não existir
            setSettings({
                store_id: storeId,
                primary_color: '#D4A03C',
                secondary_color: '#6B7280',
                background_color: '#1A1614',
                card_color: '#26211E',
                font_family: 'Source Sans Pro',
                theme: 'dark',
                commission_percentage: 43,
            });
        }
    };

    const handleSaveSettings = async () => {
        if (!selectedStore) return;

        setIsSaving(true);

        const { error } = await supabase
            .from('settings')
            .upsert({
                ...settings,
                store_id: selectedStore,
            }, { onConflict: 'store_id' });

        if (error) {
            toast({
                variant: "destructive",
                title: "Erro",
                description: "Não foi possível salvar as configurações.",
            });
        } else {
            toast({
                title: "Configurações salvas!",
                description: "As alterações foram aplicadas com sucesso.",
            });
        }

        setIsSaving(false);
    };

    if (!isSuperAdmin) {
        return (
            <DashboardLayout title="Acesso Negado" subtitle="Área restrita">
                <Card className="border">
                    <CardContent className="p-12 text-center">
                        <Settings2 className="w-16 h-16 mx-auto text-muted-foreground mb-4" />
                        <h2 className="text-xl font-semibold mb-2">Área restrita</h2>
                        <p className="text-muted-foreground">
                            Esta área é exclusiva para Super Admins.
                        </p>
                    </CardContent>
                </Card>
            </DashboardLayout>
        );
    }

    if (isLoading) {
        return (
            <DashboardLayout title="Admin" subtitle="Gerenciamento White Label">
                <div className="flex items-center justify-center h-64">
                    <Loader2 className="w-8 h-8 animate-spin text-primary" />
                </div>
            </DashboardLayout>
        );
    }

    return (
        <DashboardLayout title="Super Admin" subtitle="Gerenciamento White Label">
            {/* Store Selector */}
            <div className="flex items-center gap-4 mb-6">
                <div className="flex-1 max-w-xs">
                    <Label>Selecionar Loja</Label>
                    <Select value={selectedStore || ''} onValueChange={setSelectedStore}>
                        <SelectTrigger>
                            <SelectValue placeholder="Selecione uma loja" />
                        </SelectTrigger>
                        <SelectContent>
                            {stores.map((store) => (
                                <SelectItem key={store.id} value={store.id}>
                                    {store.name}
                                </SelectItem>
                            ))}
                        </SelectContent>
                    </Select>
                </div>
                <Button variant="outline">
                    <Plus className="w-4 h-4 mr-2" />
                    Nova Loja
                </Button>
            </div>

            <Tabs defaultValue="branding" className="space-y-6">
                <TabsList>
                    <TabsTrigger value="branding">
                        <Palette className="w-4 h-4 mr-2" />
                        Branding
                    </TabsTrigger>
                    <TabsTrigger value="stores">
                        <Building2 className="w-4 h-4 mr-2" />
                        Lojas
                    </TabsTrigger>
                    <TabsTrigger value="users">
                        <Users className="w-4 h-4 mr-2" />
                        Usuários
                    </TabsTrigger>
                </TabsList>

                {/* Branding Tab */}
                <TabsContent value="branding">
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        {/* Colors */}
                        <Card className="border">
                            <CardHeader>
                                <CardTitle className="text-lg">Cores da Marca</CardTitle>
                                <CardDescription>
                                    Personalize as cores da interface
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="grid grid-cols-2 gap-4">
                                    <div className="space-y-2">
                                        <Label>Cor Primária</Label>
                                        <div className="flex gap-2">
                                            <Input
                                                type="color"
                                                value={settings.primary_color || '#D4A03C'}
                                                onChange={(e) => setSettings({ ...settings, primary_color: e.target.value })}
                                                className="w-12 h-10 p-1 cursor-pointer"
                                            />
                                            <Input
                                                value={settings.primary_color || '#D4A03C'}
                                                onChange={(e) => setSettings({ ...settings, primary_color: e.target.value })}
                                                className="flex-1"
                                            />
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <Label>Cor Secundária</Label>
                                        <div className="flex gap-2">
                                            <Input
                                                type="color"
                                                value={settings.secondary_color || '#6B7280'}
                                                onChange={(e) => setSettings({ ...settings, secondary_color: e.target.value })}
                                                className="w-12 h-10 p-1 cursor-pointer"
                                            />
                                            <Input
                                                value={settings.secondary_color || '#6B7280'}
                                                onChange={(e) => setSettings({ ...settings, secondary_color: e.target.value })}
                                                className="flex-1"
                                            />
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <Label>Cor de Fundo</Label>
                                        <div className="flex gap-2">
                                            <Input
                                                type="color"
                                                value={settings.background_color || '#1A1614'}
                                                onChange={(e) => setSettings({ ...settings, background_color: e.target.value })}
                                                className="w-12 h-10 p-1 cursor-pointer"
                                            />
                                            <Input
                                                value={settings.background_color || '#1A1614'}
                                                onChange={(e) => setSettings({ ...settings, background_color: e.target.value })}
                                                className="flex-1"
                                            />
                                        </div>
                                    </div>
                                    <div className="space-y-2">
                                        <Label>Cor dos Cards</Label>
                                        <div className="flex gap-2">
                                            <Input
                                                type="color"
                                                value={settings.card_color || '#26211E'}
                                                onChange={(e) => setSettings({ ...settings, card_color: e.target.value })}
                                                className="w-12 h-10 p-1 cursor-pointer"
                                            />
                                            <Input
                                                value={settings.card_color || '#26211E'}
                                                onChange={(e) => setSettings({ ...settings, card_color: e.target.value })}
                                                className="flex-1"
                                            />
                                        </div>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>

                        {/* Typography & Theme */}
                        <Card className="border">
                            <CardHeader>
                                <CardTitle className="text-lg">Tipografia e Tema</CardTitle>
                                <CardDescription>
                                    Configure fonte e tema padrão
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="space-y-2">
                                    <Label>Fonte</Label>
                                    <Select
                                        value={settings.font_family || 'Source Sans Pro'}
                                        onValueChange={(value) => setSettings({ ...settings, font_family: value })}
                                    >
                                        <SelectTrigger>
                                            <SelectValue />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="Source Sans Pro">Source Sans Pro</SelectItem>
                                            <SelectItem value="Inter">Inter</SelectItem>
                                            <SelectItem value="Roboto">Roboto</SelectItem>
                                            <SelectItem value="Poppins">Poppins</SelectItem>
                                            <SelectItem value="Montserrat">Montserrat</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>

                                <div className="space-y-2">
                                    <Label>Tema Padrão</Label>
                                    <Select
                                        value={settings.theme || 'dark'}
                                        onValueChange={(value) => setSettings({ ...settings, theme: value })}
                                    >
                                        <SelectTrigger>
                                            <SelectValue />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="dark">Escuro</SelectItem>
                                            <SelectItem value="light">Claro</SelectItem>
                                            <SelectItem value="system">Sistema</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>

                                <div className="space-y-2">
                                    <Label>Logo URL</Label>
                                    <Input
                                        value={settings.logo_url || ''}
                                        onChange={(e) => setSettings({ ...settings, logo_url: e.target.value })}
                                        placeholder="/assets/logo.png"
                                    />
                                </div>

                                <div className="space-y-2">
                                    <Label>Domínio Personalizado</Label>
                                    <Input
                                        value={settings.custom_domain || ''}
                                        onChange={(e) => setSettings({ ...settings, custom_domain: e.target.value })}
                                        placeholder="app.minhabarbearia.com"
                                    />
                                </div>
                            </CardContent>
                        </Card>

                        {/* Business Settings */}
                        <Card className="border">
                            <CardHeader>
                                <CardTitle className="text-lg">Configurações de Negócio</CardTitle>
                                <CardDescription>
                                    Regras de comissão e divisão
                                </CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="space-y-2">
                                    <Label>Porcentagem de Comissão (%)</Label>
                                    <Input
                                        type="number"
                                        min={0}
                                        max={100}
                                        value={settings.commission_percentage || 43}
                                        onChange={(e) => setSettings({ ...settings, commission_percentage: Number(e.target.value) })}
                                    />
                                    <p className="text-xs text-muted-foreground">
                                        Porcentagem do faturamento destinada aos profissionais
                                    </p>
                                </div>
                            </CardContent>
                        </Card>

                        {/* Preview */}
                        <Card className="border">
                            <CardHeader>
                                <CardTitle className="text-lg flex items-center gap-2">
                                    <Eye className="w-5 h-5" />
                                    Pré-visualização
                                </CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div
                                    className="rounded-lg p-4 space-y-3"
                                    style={{
                                        backgroundColor: settings.background_color || '#1A1614',
                                        fontFamily: settings.font_family || 'Source Sans Pro',
                                    }}
                                >
                                    <div
                                        className="rounded-lg p-4"
                                        style={{ backgroundColor: settings.card_color || '#26211E' }}
                                    >
                                        <h3
                                            className="font-semibold mb-2"
                                            style={{ color: settings.primary_color || '#D4A03C' }}
                                        >
                                            Exemplo de Card
                                        </h3>
                                        <p style={{ color: '#fff', opacity: 0.7, fontSize: '14px' }}>
                                            Esta é uma prévia de como os elementos ficarão com as cores selecionadas.
                                        </p>
                                        <button
                                            className="mt-3 px-4 py-2 rounded-lg text-sm font-medium"
                                            style={{
                                                backgroundColor: settings.primary_color || '#D4A03C',
                                                color: '#000',
                                            }}
                                        >
                                            Botão Primário
                                        </button>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    </div>

                    <div className="flex justify-end mt-6">
                        <Button onClick={handleSaveSettings} disabled={isSaving}>
                            {isSaving ? (
                                <>
                                    <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                                    Salvando...
                                </>
                            ) : (
                                <>
                                    <Save className="w-4 h-4 mr-2" />
                                    Salvar Configurações
                                </>
                            )}
                        </Button>
                    </div>
                </TabsContent>

                {/* Stores Tab */}
                <TabsContent value="stores">
                    <Card className="border">
                        <CardHeader>
                            <CardTitle>Lojas Cadastradas</CardTitle>
                            <CardDescription>
                                Gerencie as lojas do sistema
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            <div className="space-y-4">
                                {stores.map((store) => (
                                    <div
                                        key={store.id}
                                        className="flex items-center justify-between p-4 rounded-lg bg-muted/50"
                                    >
                                        <div className="flex items-center gap-3">
                                            <div className="w-10 h-10 rounded-lg bg-primary/10 flex items-center justify-center">
                                                <Store className="w-5 h-5 text-primary" />
                                            </div>
                                            <div>
                                                <h4 className="font-medium">{store.name}</h4>
                                                <p className="text-sm text-muted-foreground">{store.address}</p>
                                            </div>
                                        </div>
                                        <Badge variant="outline">{store.phone}</Badge>
                                    </div>
                                ))}
                            </div>
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Users Tab */}
                <TabsContent value="users">
                    <Card className="border">
                        <CardHeader>
                            <CardTitle>Gerenciamento de Usuários</CardTitle>
                            <CardDescription>
                                Adicione e gerencie usuários do sistema
                            </CardDescription>
                        </CardHeader>
                        <CardContent className="text-center py-8">
                            <Users className="w-12 h-12 mx-auto text-muted-foreground mb-4" />
                            <p className="text-muted-foreground mb-4">
                                Use o script para criar usuários:
                            </p>
                            <code className="bg-muted px-3 py-2 rounded text-sm">
                                npx tsx scripts/create-user.ts &lt;email&gt; &lt;senha&gt; &lt;nome&gt; &lt;role&gt;
                            </code>
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>
        </DashboardLayout>
    );
};

export default Admin;
