import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
    TrendingUp,
    Award,
    Star,
    ChevronRight,
    Users,
    Target,
    CircleDollarSign,
} from "lucide-react";

import { useParams } from "react-router-dom";
import { useStore } from "@/hooks/useStore";
import { useBarbers } from "@/hooks/useBarbers";

// Career levels data (will come from useCareerLevels hook when connected)
const careerLevels = [
    {
        name: "Júnior",
        order: 1,
        multiplier: 0.8,
        requirements: {
            months: 0,
            services: 0,
            rating: 0,
        },
        benefits: "Treinamento básico, acompanhamento de mentor",
        color: "bg-slate-500",
    },
    {
        name: "Profissional",
        order: 2,
        multiplier: 1.0,
        requirements: {
            months: 6,
            services: 500,
            rating: 4.0,
        },
        benefits: "Comissão padrão, autonomia de agenda",
        color: "bg-blue-500",
    },
    {
        name: "Sênior",
        order: 3,
        multiplier: 1.2,
        requirements: {
            months: 18,
            services: 2000,
            rating: 4.5,
        },
        benefits: "Bônus de 20%, treinamento de novos barbers",
        color: "bg-purple-500",
    },
    {
        name: "Master",
        order: 4,
        multiplier: 1.5,
        requirements: {
            months: 36,
            services: 5000,
            rating: 4.8,
        },
        benefits: "Bônus de 50%, liderança de equipe, participação nos lucros",
        color: "bg-amber-500",
    },
];

const CareerPlan = () => {
    const { storeId } = useParams();
    const { store } = useStore(storeId);
    const { activeBarbers } = useBarbers(store?.id);

    return (
        <DashboardLayout
            title="Plano de Carreira"
            subtitle="Níveis, progressões e benefícios"
        >
            {/* Overview Cards */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
                <Card className="border">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-muted-foreground">Níveis Disponíveis</p>
                                <p className="text-2xl font-bold">{careerLevels.length}</p>
                            </div>
                            <Award className="w-8 h-8 text-primary" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-muted-foreground">Multiplicador Máximo</p>
                                <p className="text-2xl font-bold">1.5x</p>
                            </div>
                            <TrendingUp className="w-8 h-8 text-green-500" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-muted-foreground">Barbers Ativos</p>
                                <p className="text-2xl font-bold">{activeBarbers.length}</p>
                            </div>
                            <Users className="w-8 h-8 text-blue-500" />
                        </div>
                    </CardContent>
                </Card>
                <Card className="border">
                    <CardContent className="pt-6">
                        <div className="flex items-center justify-between">
                            <div>
                                <p className="text-sm text-muted-foreground">Em Progressão</p>
                                <p className="text-2xl font-bold">0</p>
                            </div>
                            <Target className="w-8 h-8 text-purple-500" />
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Career Levels */}
            <Card className="border mb-8">
                <CardHeader>
                    <CardTitle>Níveis de Carreira</CardTitle>
                    <CardDescription>
                        Cada nível oferece multiplicadores de comissão e benefícios exclusivos
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="space-y-4">
                        {careerLevels.map((level, index) => (
                            <div
                                key={level.name}
                                className="flex items-center gap-4 p-4 rounded-lg bg-muted/50 hover:bg-muted/80 transition-colors"
                            >
                                {/* Level Badge */}
                                <div className={`w-12 h-12 rounded-full ${level.color} flex items-center justify-center text-white font-bold text-lg`}>
                                    {level.order}
                                </div>

                                {/* Level Info */}
                                <div className="flex-1">
                                    <div className="flex items-center gap-2 mb-1">
                                        <h3 className="font-semibold text-lg">{level.name}</h3>
                                        <span className="px-2 py-0.5 text-xs font-medium bg-primary/10 text-primary rounded-full">
                                            {level.multiplier}x
                                        </span>
                                    </div>
                                    <p className="text-sm text-muted-foreground">{level.benefits}</p>
                                </div>

                                {/* Requirements */}
                                <div className="hidden md:flex items-center gap-6 text-sm">
                                    <div className="text-center">
                                        <p className="font-semibold">{level.requirements.months}</p>
                                        <p className="text-muted-foreground">meses</p>
                                    </div>
                                    <div className="text-center">
                                        <p className="font-semibold">{level.requirements.services}</p>
                                        <p className="text-muted-foreground">serviços</p>
                                    </div>
                                    <div className="text-center flex items-center gap-1">
                                        <Star className="w-4 h-4 text-yellow-500 fill-yellow-500" />
                                        <span className="font-semibold">{level.requirements.rating || '-'}</span>
                                    </div>
                                </div>

                                {/* Arrow to next level */}
                                {index < careerLevels.length - 1 && (
                                    <ChevronRight className="w-5 h-5 text-muted-foreground" />
                                )}
                            </div>
                        ))}
                    </div>
                </CardContent>
            </Card>

            {/* Commission Explanation */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <Card className="border">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <CircleDollarSign className="w-5 h-5" />
                            Como funciona a Comissão
                        </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        <div className="p-4 bg-primary/5 rounded-lg border border-primary/20">
                            <p className="text-sm">
                                <strong>43%</strong> do faturamento é distribuído entre os barbers
                                proporcionalmente aos <strong>pontos acumulados</strong>.
                            </p>
                        </div>

                        <div className="space-y-2">
                            <h4 className="font-medium">Exemplo de cálculo:</h4>
                            <ul className="text-sm text-muted-foreground space-y-1">
                                <li>• Faturamento do dia: <strong>R$ 2.000</strong></li>
                                <li>• Pool de comissão (43%): <strong>R$ 860</strong></li>
                                <li>• Total de pontos: <strong>40 pontos</strong></li>
                                <li>• Valor por ponto: <strong>R$ 21,50</strong></li>
                            </ul>
                        </div>

                        <div className="space-y-2">
                            <h4 className="font-medium">Barber Sênior (1.2x) com 10 pontos:</h4>
                            <p className="text-lg font-bold text-primary">
                                R$ 21,50 × 10 × 1.2 = <span className="text-green-500">R$ 258,00</span>
                            </p>
                        </div>
                    </CardContent>
                </Card>

                <Card className="border">
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <Award className="w-5 h-5" />
                            Pontuação por Serviço
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-3">
                            {[
                                { name: "Corte", points: 1, price: 45 },
                                { name: "Corte + Barba", points: 2, price: 65 },
                                { name: "Barba", points: 1, price: 35 },
                                { name: "Pigmentação", points: 2, price: 80 },
                            ].map((service) => (
                                <div
                                    key={service.name}
                                    className="flex items-center justify-between p-3 rounded-lg bg-muted/50"
                                >
                                    <div>
                                        <p className="font-medium">{service.name}</p>
                                        <p className="text-sm text-muted-foreground">
                                            R$ {service.price.toFixed(2)}
                                        </p>
                                    </div>
                                    <div className="flex items-center gap-1 px-3 py-1 bg-primary/10 rounded-full">
                                        <Star className="w-4 h-4 text-primary" />
                                        <span className="font-bold text-primary">{service.points}</span>
                                        <span className="text-sm text-muted-foreground">
                                            {service.points === 1 ? 'ponto' : 'pontos'}
                                        </span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </DashboardLayout>
    );
};

export default CareerPlan;
