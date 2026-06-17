import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import { AuthProvider } from "@/contexts/AuthContext";
import Login from "./pages/Login";
import ForgotPassword from "./pages/ForgotPassword";
import ResetPassword from "./pages/ResetPassword";
import StoreSelection from "./pages/StoreSelection";
import Dashboard from "./pages/Dashboard";
import Cashier from "./pages/Cashier";
import Commissions from "./pages/Commissions";
import Barbers from "./pages/Barbers";
import Schedule from "./pages/Schedule";
import Clients from "./pages/Clients";
import Services from "./pages/Services";
import Products from "./pages/Products";
import Inventory from "./pages/Inventory";
import Expenses from "./pages/Expenses";
import Goals from "./pages/Goals";
import Reports from "./pages/Reports";
import Settings from "./pages/Settings";
import CareerPlan from "./pages/CareerPlan";
import Admin from "./pages/Admin";
import NotFound from "./pages/NotFound";
// Client App
import ClientHome from "./pages/client/ClientHome";
import ClientBooking from "./pages/client/ClientBooking";
import ClientServices from "./pages/client/ClientServices";
import ClientShop from "./pages/client/ClientShop";
import ClientCart from "./pages/client/ClientCart";
import ClientAppointments from "./pages/client/ClientAppointments";
import ClientProfile from "./pages/client/ClientProfile";
import ClientCheckout from "./pages/client/ClientCheckout";
import ClientWallet from "./pages/client/ClientWallet";
import ClientSubscription from "./pages/client/ClientSubscription";
import ScrollToTop from "./components/ScrollToTop";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <AuthProvider>
      <TooltipProvider>
        <Toaster />
        <Sonner />
        <BrowserRouter>
          <ScrollToTop />
          <Routes>
            {/* Auth Routes */}
            <Route path="/" element={<Login />} />
            <Route path="/forgot-password" element={<ForgotPassword />} />
            <Route path="/reset-password" element={<ResetPassword />} />

            {/* Super Admin Route */}
            <Route path="/admin" element={<Admin />} />

            {/* Admin/Management Routes */}
            <Route path="/stores" element={<StoreSelection />} />
            <Route path="/dashboard/:storeId" element={<Dashboard />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/cashier" element={<Cashier />} />
            <Route path="/commissions" element={<Commissions />} />
            <Route path="/barbers" element={<Barbers />} />
            <Route path="/schedule" element={<Schedule />} />
            <Route path="/clients" element={<Clients />} />
            <Route path="/services" element={<Services />} />
            <Route path="/products" element={<Products />} />
            <Route path="/inventory" element={<Inventory />} />
            <Route path="/expenses" element={<Expenses />} />
            <Route path="/goals" element={<Goals />} />
            <Route path="/reports" element={<Reports />} />
            <Route path="/settings" element={<Settings />} />
            <Route path="/career" element={<CareerPlan />} />

            {/* Client App Routes */}
            <Route path="/client" element={<ClientHome />} />
            <Route path="/client/booking" element={<ClientBooking />} />
            <Route path="/client/services" element={<ClientServices />} />
            <Route path="/client/shop" element={<ClientShop />} />
            <Route path="/client/cart" element={<ClientCart />} />
            <Route path="/client/appointments" element={<ClientAppointments />} />
            <Route path="/client/profile" element={<ClientProfile />} />
            <Route path="/client/checkout" element={<ClientCheckout />} />
            <Route path="/client/wallet" element={<ClientWallet />} />
            <Route path="/client/subscription" element={<ClientSubscription />} />

            <Route path="*" element={<NotFound />} />
          </Routes>
        </BrowserRouter>
      </TooltipProvider>
    </AuthProvider>
  </QueryClientProvider>
);

export default App;
