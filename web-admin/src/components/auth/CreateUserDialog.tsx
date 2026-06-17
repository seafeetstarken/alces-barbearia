import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog";
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from "@/components/ui/select";
import { UserPlus, Loader2 } from "lucide-react";
import { supabase } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";
import type { UserRole } from "@/lib/supabase/types";

interface CreateUserDialogProps {
    storeId?: string;
    onSuccess?: () => void;
}

export function CreateUserDialog({ storeId, onSuccess }: CreateUserDialogProps) {
    const { toast } = useToast();
    const [open, setOpen] = useState(false);
    const [isLoading, setIsLoading] = useState(false);

    const [formData, setFormData] = useState({
        email: "",
        password: "",
        fullName: "",
        role: "barber" as UserRole,
    });

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);

        try {
            // Create user in Supabase Auth using admin API
            // Note: In production, this should be done via a server function or edge function
            // For now, we use the client SDK which requires the user to be an admin

            const { data, error } = await supabase.auth.signUp({
                email: formData.email,
                password: formData.password,
                options: {
                    data: {
                        full_name: formData.fullName,
                        role: formData.role,
                    },
                },
            });

            if (error) throw error;

            // If user was created and we have a storeId, create barber entry
            if (data.user && storeId && (formData.role === 'barber' || formData.role === 'leader')) {
                const initials = formData.fullName
                    .split(' ')
                    .map(n => n[0])
                    .join('')
                    .toUpperCase()
                    .slice(0, 2);

                await supabase.from('barbers').insert({
                    profile_id: data.user.id,
                    store_id: storeId,
                    name: formData.fullName,
                    initials,
                    email: formData.email,
                    level: 'junior',
                    level_multiplier: 0.8,
                    is_leader: formData.role === 'leader',
                    is_active: true,
                });
            }

            toast({
                title: "Usuário criado!",
                description: `${formData.fullName} foi adicionado como ${getRoleName(formData.role)}.`,
            });

            setOpen(false);
            setFormData({
                email: "",
                password: "",
                fullName: "",
                role: "barber",
            });
            onSuccess?.();
        } catch (error: unknown) {
            let message = "Não foi possível criar o usuário.";

            if (error instanceof Error && error.message?.includes("already registered")) {
                message = "Este email já está cadastrado.";
            }

            toast({
                variant: "destructive",
                title: "Erro",
                description: message,
            });
        } finally {
            setIsLoading(false);
        }
    };

    const getRoleName = (role: UserRole): string => {
        const names: Record<UserRole, string> = {
            super_admin: "Super Admin",
            owner: "Dono",
            manager: "Gestor",
            leader: "Líder",
            barber: "Barber",
        };
        return names[role];
    };

    return (
        <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild>
                <Button>
                    <UserPlus className="w-4 h-4 mr-2" />
                    Adicionar Usuário
                </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[425px]">
                <form onSubmit={handleSubmit}>
                    <DialogHeader>
                        <DialogTitle>Novo Usuário</DialogTitle>
                        <DialogDescription>
                            Adicione um novo membro à equipe. Ele receberá acesso ao sistema.
                        </DialogDescription>
                    </DialogHeader>
                    <div className="grid gap-4 py-4">
                        <div className="space-y-2">
                            <Label htmlFor="fullName">Nome completo</Label>
                            <Input
                                id="fullName"
                                value={formData.fullName}
                                onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
                                placeholder="João Pedro Silva"
                                required
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="email">Email</Label>
                            <Input
                                id="email"
                                type="email"
                                value={formData.email}
                                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                placeholder="joao@email.com"
                                required
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="password">Senha inicial</Label>
                            <Input
                                id="password"
                                type="password"
                                value={formData.password}
                                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                                placeholder="Mínimo 6 caracteres"
                                minLength={6}
                                required
                            />
                        </div>
                        <div className="space-y-2">
                            <Label htmlFor="role">Função</Label>
                            <Select
                                value={formData.role}
                                onValueChange={(value: UserRole) => setFormData({ ...formData, role: value })}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder="Selecione a função" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="barber">Barber</SelectItem>
                                    <SelectItem value="leader">Líder</SelectItem>
                                    <SelectItem value="manager">Gestor</SelectItem>
                                    <SelectItem value="owner">Dono</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button type="button" variant="outline" onClick={() => setOpen(false)}>
                            Cancelar
                        </Button>
                        <Button type="submit" disabled={isLoading}>
                            {isLoading ? (
                                <>
                                    <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                                    Criando...
                                </>
                            ) : (
                                "Criar usuário"
                            )}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
