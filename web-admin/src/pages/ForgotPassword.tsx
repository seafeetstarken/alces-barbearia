import { useState } from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ArrowLeft, Loader2, Mail, CheckCircle } from "lucide-react";
import { supabase } from "@/lib/supabase";
import { useToast } from "@/hooks/use-toast";

const ForgotPassword = () => {
    const { toast } = useToast();
    const [email, setEmail] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [isSuccess, setIsSuccess] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);

        const { error } = await supabase.auth.resetPasswordForEmail(email, {
            redirectTo: `${window.location.origin}/reset-password`,
        });

        if (error) {
            toast({
                variant: "destructive",
                title: "Erro",
                description: "Não foi possível enviar o email. Tente novamente.",
            });
            setIsLoading(false);
            return;
        }

        setIsSuccess(true);
        setIsLoading(false);
    };

    if (isSuccess) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-background p-4">
                <div className="w-full max-w-md space-y-8">
                    <Card className="border-0 shadow-xl">
                        <CardContent className="pt-8 pb-8 text-center space-y-4">
                            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-green-500/10 mb-4">
                                <CheckCircle className="w-8 h-8 text-green-500" />
                            </div>
                            <CardTitle>Email enviado!</CardTitle>
                            <CardDescription className="text-base">
                                Enviamos um link para <strong>{email}</strong>.
                                Verifique sua caixa de entrada e clique no link para redefinir sua senha.
                            </CardDescription>
                            <Link to="/">
                                <Button variant="outline" className="mt-4">
                                    <ArrowLeft className="w-4 h-4 mr-2" />
                                    Voltar ao login
                                </Button>
                            </Link>
                        </CardContent>
                    </Card>
                </div>
            </div>
        );
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-background p-4">
            <div className="w-full max-w-md space-y-8">
                {/* Header */}
                <div className="text-center space-y-2">
                    <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-primary/10 mb-4">
                        <Mail className="w-8 h-8 text-primary" />
                    </div>
                    <h1 className="text-2xl font-bold text-foreground">Esqueceu sua senha?</h1>
                    <p className="text-muted-foreground">
                        Digite seu email e enviaremos um link para redefinir sua senha.
                    </p>
                </div>

                {/* Form Card */}
                <Card className="border-0 shadow-xl">
                    <CardHeader className="space-y-1 pb-4">
                        <CardTitle className="text-xl">Recuperar senha</CardTitle>
                        <CardDescription>
                            Insira o email cadastrado no sistema
                        </CardDescription>
                    </CardHeader>
                    <CardContent>
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div className="space-y-2">
                                <Label htmlFor="email">Email</Label>
                                <Input
                                    id="email"
                                    type="email"
                                    placeholder="seu@email.com"
                                    value={email}
                                    onChange={(e) => setEmail(e.target.value)}
                                    required
                                    autoComplete="email"
                                    className="h-11"
                                />
                            </div>

                            <Button
                                type="submit"
                                className="w-full"
                                size="lg"
                                disabled={isLoading}
                            >
                                {isLoading ? (
                                    <>
                                        <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                                        Enviando...
                                    </>
                                ) : (
                                    "Enviar link de recuperação"
                                )}
                            </Button>
                        </form>
                    </CardContent>
                </Card>

                {/* Back to login */}
                <div className="text-center">
                    <Link to="/" className="text-sm text-primary hover:underline inline-flex items-center">
                        <ArrowLeft className="w-4 h-4 mr-1" />
                        Voltar ao login
                    </Link>
                </div>
            </div>
        </div>
    );
};

export default ForgotPassword;
