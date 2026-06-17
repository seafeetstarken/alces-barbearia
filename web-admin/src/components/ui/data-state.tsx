import { ReactNode } from "react";
import { AlertCircle, CheckCircle2, Inbox, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";

type DataStateVariant = "loading" | "empty" | "error" | "success";

interface DataStateProps {
  variant: DataStateVariant;
  title: string;
  description?: string;
  action?: ReactNode;
  className?: string;
}

const variantIcon = {
  loading: Loader2,
  empty: Inbox,
  error: AlertCircle,
  success: CheckCircle2,
} as const;

const variantWrapper = {
  loading: "bg-muted/40 border-border",
  empty: "bg-muted/30 border-border",
  error: "bg-destructive/5 border-destructive/20",
  success: "bg-emerald-500/5 border-emerald-500/20",
} as const;

const variantIconStyle = {
  loading: "text-primary animate-spin",
  empty: "text-muted-foreground",
  error: "text-destructive",
  success: "text-emerald-600 dark:text-emerald-400",
} as const;

export function DataState({ variant, title, description, action, className }: DataStateProps) {
  const Icon = variantIcon[variant];

  return (
    <div
      className={cn(
        "w-full rounded-xl border px-5 py-8 text-center flex flex-col items-center gap-3",
        variantWrapper[variant],
        className,
      )}
    >
      <div className="w-11 h-11 rounded-full bg-background/80 flex items-center justify-center border border-border/60">
        <Icon className={cn("w-5 h-5", variantIconStyle[variant])} />
      </div>
      <div className="space-y-1">
        <h3 className="text-base font-semibold text-foreground">{title}</h3>
        {description && <p className="text-sm text-muted-foreground">{description}</p>}
      </div>
      {action ? <div className="pt-1">{action}</div> : null}
    </div>
  );
}
