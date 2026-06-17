import { SidebarProvider, SidebarInset, SidebarTrigger } from "@/components/ui/sidebar";
import AppSidebar from "./AppSidebar";
import { Separator } from "@/components/ui/separator";
import { Bell } from "lucide-react";
import { Button } from "@/components/ui/button";
import { ThemeToggle } from "@/components/ThemeToggle";

interface DashboardLayoutProps {
  children: React.ReactNode;
  title: string;
  subtitle?: string;
  storeName?: string;
}

const DashboardLayout = ({
  children,
  title,
  subtitle,
  storeName = "Barbearia Central",
}: DashboardLayoutProps) => {
  return (
    <SidebarProvider>
      <div className="min-h-screen flex w-full bg-background">
        <AppSidebar storeName={storeName} />
        <SidebarInset className="flex-1 min-w-0">

          {/* Top Bar */}
          <header className="sticky top-0 z-10 flex h-14 items-center gap-3 border-b border-border bg-background px-5">
            <SidebarTrigger className="-ml-1 text-muted-foreground hover:text-foreground" />
            <Separator orientation="vertical" className="h-5 bg-border" />

            {/* Page title inline on mobile */}
            <span className="text-sm font-semibold text-foreground truncate">{title}</span>

            <div className="flex items-center gap-1.5 ml-auto">
              <ThemeToggle />
              <Button variant="ghost" size="icon" className="relative w-9 h-9 text-muted-foreground hover:text-foreground">
                <Bell className="w-4 h-4" />
                <span className="absolute top-2 right-2 w-1.5 h-1.5 bg-primary rounded-full" />
              </Button>
              <div className="w-8 h-8 rounded-full bg-primary/15 border border-primary/20 flex items-center justify-center">
                <span className="text-xs font-semibold text-primary">JD</span>
              </div>
            </div>
          </header>

          {/* Page Content */}
          <main className="flex-1 p-5 md:p-6">
            <div className="mb-5">
              <h1 className="text-xl font-bold text-foreground">{title}</h1>
              {subtitle && (
                <p className="text-sm text-muted-foreground mt-0.5">{subtitle}</p>
              )}
            </div>
            {children}
          </main>

        </SidebarInset>
      </div>
    </SidebarProvider>
  );
};

export default DashboardLayout;
