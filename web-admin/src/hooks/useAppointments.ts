import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/lib/supabase";
import type { Appointment, AppointmentService } from "@/lib/supabase/types";

export type AppointmentWithRelations = Appointment & {
  barber: { id: string; name: string } | null;
  client: { id: string; name: string } | null;
  services: (AppointmentService & { service: { id: string; name: string } | null })[];
};

export function useAppointments(storeId?: string, clientId?: string) {
  const queryClient = useQueryClient();

  const appointmentsQuery = useQuery({
    queryKey: ["appointments", storeId, clientId],
    queryFn: async () => {
      if (!storeId) return [];

      let query = supabase
        .from("appointments")
        .select("*, barber:barbers(id, name), client:clients(id, name), services:appointment_services(*, service:services(id, name))")
        .eq("store_id", storeId)
        .order("starts_at", { ascending: true });

      if (clientId) {
        query = query.eq("client_id", clientId);
      }

      const { data, error } = await query;
      if (error) throw error;
      return (data ?? []) as AppointmentWithRelations[];
    },
    enabled: Boolean(storeId),
  });

  const createAppointment = useMutation({
    mutationFn: async ({
      appointment,
      services,
    }: {
      appointment: Omit<Appointment, "id" | "created_at" | "updated_at">;
      services: Omit<AppointmentService, "id" | "appointment_id" | "created_at">[];
    }) => {
      const { data: createdAppointment, error: appointmentError } = await supabase
        .from("appointments")
        .insert(appointment as never)
        .select()
        .single();
      const created = createdAppointment as unknown as Appointment | null;

      if (appointmentError) throw appointmentError;
      if (!created) throw new Error("Falha ao criar agendamento");

      if (services.length > 0) {
        const { error: servicesError } = await supabase
          .from("appointment_services")
          .insert(
            services.map((service) => ({
              ...service,
              appointment_id: created.id,
            })) as never,
          );

        if (servicesError) throw servicesError;
      }

      return created;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["appointments"] });
    },
  });

  const updateAppointmentStatus = useMutation({
    mutationFn: async ({ id, status }: { id: string; status: Appointment["status"] }) => {
      const { data, error } = await supabase
        .from("appointments")
        .update({ status } as never)
        .eq("id", id)
        .select()
        .single();

      if (error) throw error;
      return data as Appointment;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["appointments"] });
    },
  });

  return {
    appointments: appointmentsQuery.data ?? [],
    isLoading: appointmentsQuery.isLoading,
    error: appointmentsQuery.error,
    createAppointment: createAppointment.mutate,
    createAppointmentAsync: createAppointment.mutateAsync,
    updateAppointmentStatus: updateAppointmentStatus.mutate,
    updateAppointmentStatusAsync: updateAppointmentStatus.mutateAsync,
    isCreating: createAppointment.isPending,
    isUpdatingStatus: updateAppointmentStatus.isPending,
  };
}
