import { useNavigate, useLocation } from "react-router-dom";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import {
  LayoutDashboard,
  Wallet,
  Users,
  Calendar,
  Scissors,
  Package,
  ShoppingCart,
  Receipt,
  Target,
  TrendingUp,
  BarChart3,
  Settings,
  LogOut,
  Store,
  UserCircle,
  ShieldCheck,
} from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";

interface NavItem {
  title: string;
  icon: React.ElementType;
  href: string;
}

const mainNavItems: NavItem[] = [
  { title: "Dashboard", icon: LayoutDashboard, href: "/dashboard" },
  { title: "Caixa", icon: Wallet, href: "/cashier" },
  { title: "Comissões", icon: TrendingUp, href: "/commissions" },
];

const managementItems: NavItem[] = [
  { title: "Barbeiros", icon: Users, href: "/barbers" },
  { title: "Escala", icon: Calendar, href: "/schedule" },
  { title: "Clientes", icon: UserCircle, href: "/clients" },
  { title: "Serviços", icon: Scissors, href: "/services" },
];

const inventoryItems: NavItem[] = [
  { title: "Produtos", icon: Package, href: "/products" },
  { title: "Estoque", icon: ShoppingCart, href: "/inventory" },
];

const financialItems: NavItem[] = [
  { title: "Despesas", icon: Receipt, href: "/expenses" },
  { title: "Metas e Bônus", icon: Target, href: "/goals" },
  { title: "Relatórios", icon: BarChart3, href: "/reports" },
];

const superAdminItems: NavItem[] = [
  { title: "White Label", icon: ShieldCheck, href: "/admin" },
  { title: "Lojas", icon: Store, href: "/stores" },
];

interface AppSidebarProps {
  storeName?: string;
}

const AppSidebar = ({ storeName = "Barbearia Central" }: AppSidebarProps) => {
  const navigate = useNavigate();
  const location = useLocation();
  const { isOwner, isManager, isSuperAdmin, isLeader, signOut } = useAuth();

  const isActive = (href: string) => location.pathname.startsWith(href);

  const renderNavItems = (items: NavItem[]) => (
    <SidebarMenu>
      {items.map((item) => (
        <SidebarMenuItem key={item.href}>
          <SidebarMenuButton
            onClick={() => navigate(item.href)}
            isActive={isActive(item.href)}
            className="rounded-lg transition-all duration-150 hover:bg-sidebar-accent text-sidebar-foreground data-[active=true]:bg-sidebar-accent data-[active=true]:text-primary"
          >
            <item.icon className="w-4 h-4 flex-shrink-0" />
            <span className="text-sm">{item.title}</span>
          </SidebarMenuButton>
        </SidebarMenuItem>
      ))}
    </SidebarMenu>
  );

  return (
    <Sidebar className="border-r border-sidebar-border bg-sidebar">
      {/* Logo */}
      <SidebarHeader className="border-b border-sidebar-border p-5">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 flex items-center justify-center flex-shrink-0">
            <img src="/alces-logo.png" alt="Alce's Logo" className="w-full h-full object-contain drop-shadow-md" />
          </div>
          <div className="flex-1 min-w-0">
            <h2
              className="font-bold text-sidebar-accent-foreground tracking-wide truncate text-sm"
              style={{ fontFamily: "'Playfair Display', serif" }}
            >
              {storeName}
            </h2>
            <button
              onClick={() => navigate("/stores")}
              className="text-[10px] text-sidebar-foreground/40 hover:text-primary flex items-center gap-1 transition-colors mt-0.5"
            >
              <Store className="w-3 h-3" />
              Trocar loja
            </button>
          </div>
        </div>
      </SidebarHeader>

      <SidebarContent className="px-3 py-4">
        {isSuperAdmin && (
          <SidebarGroup className="mb-2">
            <SidebarGroupLabel className="text-[10px] uppercase tracking-[0.15em] text-sidebar-foreground/40 px-2 mb-1">
              Admin Geral
            </SidebarGroupLabel>
            <SidebarGroupContent>{renderNavItems(superAdminItems)}</SidebarGroupContent>
          </SidebarGroup>
        )}

        <SidebarGroup className="mb-2">
          <SidebarGroupLabel className="text-[10px] uppercase tracking-[0.15em] text-sidebar-foreground/40 px-2 mb-1">
            Principal
          </SidebarGroupLabel>
          <SidebarGroupContent>{renderNavItems(mainNavItems)}</SidebarGroupContent>
        </SidebarGroup>

        {(isLeader || isSuperAdmin) && (
          <>
            <SidebarGroup className="mb-2">
              <SidebarGroupLabel className="text-[10px] uppercase tracking-[0.15em] text-sidebar-foreground/40 px-2 mb-1">
                Gestão
              </SidebarGroupLabel>
              <SidebarGroupContent>{renderNavItems(managementItems)}</SidebarGroupContent>
            </SidebarGroup>

            <SidebarGroup className="mb-2">
              <SidebarGroupLabel className="text-[10px] uppercase tracking-[0.15em] text-sidebar-foreground/40 px-2 mb-1">
                Estoque
              </SidebarGroupLabel>
              <SidebarGroupContent>{renderNavItems(inventoryItems)}</SidebarGroupContent>
            </SidebarGroup>

            <SidebarGroup>
              <SidebarGroupLabel className="text-[10px] uppercase tracking-[0.15em] text-sidebar-foreground/40 px-2 mb-1">
                Financeiro
              </SidebarGroupLabel>
              <SidebarGroupContent>{renderNavItems(financialItems)}</SidebarGroupContent>
            </SidebarGroup>
          </>
        )}
      </SidebarContent>

      <SidebarFooter className="border-t border-sidebar-border p-3">
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton
              onClick={() => navigate("/settings")}
              className="rounded-lg text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground transition-colors"
            >
              <Settings className="w-4 h-4" />
              <span className="text-sm">Configurações</span>
            </SidebarMenuButton>
          </SidebarMenuItem>
          <SidebarMenuItem>
            <SidebarMenuButton
              onClick={async () => {
                await signOut();
                navigate("/");
              }}
              className="rounded-lg text-sidebar-foreground/60 hover:text-destructive hover:bg-destructive/10 transition-colors"
            >
              <LogOut className="w-4 h-4" />
              <span className="text-sm">Sair</span>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarFooter>
    </Sidebar>
  );
};

export default AppSidebar;
