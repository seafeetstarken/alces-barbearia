import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import {
  ChevronLeft,
  ChevronRight,
  Calendar,
  Clock,
  Users,
  CheckCircle2,
  XCircle,
} from "lucide-react";
import { useMemo, useState } from "react";
import { useStore } from "@/hooks/useStore";
import { useSchedule } from "@/hooks/useSchedule";
import { useBarbers } from "@/hooks/useBarbers";
import { DataState } from "@/components/ui/data-state";

const weekDays = ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"];

const generateWeekDates = (startDate: Date) => {
  const dates = [];
  for (let i = 0; i < 7; i++) {
    const date = new Date(startDate);
    date.setDate(startDate.getDate() + i);
    dates.push(date);
  }
  return dates;
};

const Schedule = () => {
  const { store } = useStore();
  const { schedules, isLoading, error } = useSchedule(store?.id);
  const { activeBarbers, isLoading: isBarbersLoading } = useBarbers(store?.id);

  const [currentWeekStart, setCurrentWeekStart] = useState(() => {
    const today = new Date();
    const dayOfWeek = today.getDay();
    const diff = today.getDate() - dayOfWeek;
    return new Date(today.setDate(diff));
  });

  const [selectedDate, setSelectedDate] = useState(new Date());
  const weekDates = generateWeekDates(currentWeekStart);

  const navigateWeek = (direction: "prev" | "next") => {
    const newStart = new Date(currentWeekStart);
    newStart.setDate(currentWeekStart.getDate() + (direction === "next" ? 7 : -7));
    setCurrentWeekStart(newStart);
  };

  const selectedDayOfWeek = selectedDate.getDay();
  const daySchedules = schedules.filter((entry) => entry.day_of_week === selectedDayOfWeek);

  const todaySchedule = useMemo(
    () =>
      activeBarbers.map((barber) => {
        const barberSchedule = daySchedules.find((entry) => entry.barber_id === barber.id);
        const initials =
          barber.initials ??
          barber.name
            .split(" ")
            .slice(0, 2)
            .map((part) => part[0])
            .join("")
            .toUpperCase();

        return {
          barberId: barber.id,
          barberName: barber.name,
          initials,
          status: barberSchedule?.is_active ? "working" : "off",
          shift: barberSchedule ? `${barberSchedule.start_time.slice(0, 5)} - ${barberSchedule.end_time.slice(0, 5)}` : undefined,
        };
      }),
    [activeBarbers, daySchedules],
  );

  const workingCount = todaySchedule.filter((entry) => entry.status === "working").length;
  const offCount = todaySchedule.filter((entry) => entry.status === "off").length;

  const statusConfig = {
    working: { label: "Trabalhando", color: "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400", icon: CheckCircle2 },
    off: { label: "Folga", color: "bg-muted text-muted-foreground", icon: XCircle },
  } as const;

  if (isLoading || isBarbersLoading) {
    return (
      <DashboardLayout title="Escala de Trabalho" subtitle="Gerencie a escala dos barbeiros">
        <DataState
          variant="loading"
          title="Carregando escala"
          description="Estamos sincronizando os turnos da equipe."
          className="max-w-xl mx-auto"
        />
      </DashboardLayout>
    );
  }

  if (error) {
    return (
      <DashboardLayout title="Escala de Trabalho" subtitle="Gerencie a escala dos barbeiros">
        <DataState
          variant="error"
          title="Falha ao carregar a escala"
          description="Não foi possível buscar os turnos. Atualize a tela para tentar novamente."
          className="max-w-xl mx-auto"
        />
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout title="Escala de Trabalho" subtitle="Gerencie a escala dos barbeiros">
      <Card className="border mb-6">
        <CardContent className="p-4">
          <div className="flex items-center justify-between mb-4">
            <Button variant="ghost" size="icon" onClick={() => navigateWeek("prev")}>
              <ChevronLeft className="w-5 h-5" />
            </Button>
            <div className="text-center">
              <p className="font-semibold text-foreground">
                {weekDates[0].toLocaleDateString("pt-BR", { month: "long", year: "numeric" })}
              </p>
              <p className="text-sm text-muted-foreground">
                Semana {Math.ceil(weekDates[0].getDate() / 7)}
              </p>
            </div>
            <Button variant="ghost" size="icon" onClick={() => navigateWeek("next")}>
              <ChevronRight className="w-5 h-5" />
            </Button>
          </div>

          <div className="grid grid-cols-7 gap-2">
            {weekDates.map((date, index) => {
              const isToday = date.toDateString() === new Date().toDateString();
              const isSelected = date.toDateString() === selectedDate.toDateString();

              return (
                <button
                  key={index}
                  onClick={() => setSelectedDate(date)}
                  className={`flex flex-col items-center p-3 rounded-lg transition-all ${
                    isSelected
                      ? "bg-primary text-primary-foreground"
                      : isToday
                      ? "bg-primary/10 text-primary"
                      : "hover:bg-muted"
                  }`}
                >
                  <span className="text-xs font-medium mb-1">{weekDays[index]}</span>
                  <span className={`text-lg font-bold ${isSelected ? "" : "text-foreground"}`}>
                    {date.getDate()}
                  </span>
                </button>
              );
            })}
          </div>
        </CardContent>
      </Card>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
              <Users className="w-6 h-6 text-green-600 dark:text-green-400" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Trabalhando</p>
              <p className="text-2xl font-bold text-foreground">{workingCount}</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-muted flex items-center justify-center">
              <XCircle className="w-6 h-6 text-muted-foreground" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Folga</p>
              <p className="text-2xl font-bold text-foreground">{offCount}</p>
            </div>
          </CardContent>
        </Card>

        <Card className="border">
          <CardContent className="p-4 flex items-center gap-4">
            <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center">
              <Calendar className="w-6 h-6 text-primary" />
            </div>
            <div>
              <p className="text-sm text-muted-foreground">Data</p>
              <p className="text-lg font-bold text-foreground">
                {selectedDate.toLocaleDateString("pt-BR", { weekday: "long", day: "numeric" })}
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
      <Card className="border">
        <CardHeader className="pb-3">
          <div className="flex items-center justify-between">
            <CardTitle className="text-lg font-semibold">Escala do Dia</CardTitle>
            <Button variant="outline" size="sm" disabled>
              Editar Escala
            </Button>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          {todaySchedule.length === 0 ? (
            <div className="p-6">
              <DataState
                variant="empty"
                title="Sem barbeiros ativos"
                description="Cadastre profissionais para montar a escala da semana."
              />
            </div>
          ) : (
            <div className="divide-y divide-border">
              {todaySchedule.map((entry) => {
                const StatusIcon = statusConfig[entry.status].icon;

                return (
                  <div
                    key={entry.barberId}
                    className="flex items-center justify-between px-6 py-4 hover:bg-muted/50 transition-colors"
                  >
                    <div className="flex items-center gap-4">
                      <Avatar className="w-12 h-12">
                        <AvatarFallback className="bg-primary/10 text-primary font-medium">
                          {entry.initials}
                        </AvatarFallback>
                      </Avatar>
                      <div>
                        <p className="font-medium text-foreground">{entry.barberName}</p>
                        {entry.shift && (
                          <div className="flex items-center gap-2 text-sm text-muted-foreground">
                            <Clock className="w-3.5 h-3.5" />
                            <span>{entry.shift}</span>
                          </div>
                        )}
                      </div>
                    </div>
                    <Badge className={statusConfig[entry.status].color}>
                      <StatusIcon className="w-3.5 h-3.5 mr-1" />
                      {statusConfig[entry.status].label}
                    </Badge>
                  </div>
                );
              })}
            </div>
          )}
        </CardContent>
      </Card>
    </DashboardLayout>
  );
};

export default Schedule;
