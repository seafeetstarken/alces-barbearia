import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { ArrowLeft, ShoppingCart, Plus, Minus } from "lucide-react";

const mockProducts = [
  { id: 1, name: "Pomada Modeladora", price: 45, category: "Finalização", stock: 15 },
  { id: 2, name: "Óleo para Barba", price: 55, category: "Barba", stock: 8 },
  { id: 3, name: "Shampoo Antiqueda", price: 65, category: "Cabelo", stock: 12 },
  { id: 4, name: "Balm para Barba", price: 40, category: "Barba", stock: 6 },
  { id: 5, name: "Cera Matte", price: 50, category: "Finalização", stock: 10 },
  { id: 6, name: "Condicionador", price: 35, category: "Cabelo", stock: 20 },
];

const ClientShop = () => {
  const navigate = useNavigate();
  const [cart, setCart] = useState<{ [key: number]: number }>({});

  const addToCart = (productId: number) => {
    setCart(prev => ({
      ...prev,
      [productId]: (prev[productId] || 0) + 1
    }));
  };

  const removeFromCart = (productId: number) => {
    setCart(prev => {
      const newCart = { ...prev };
      if (newCart[productId] > 1) {
        newCart[productId]--;
      } else {
        delete newCart[productId];
      }
      return newCart;
    });
  };

  const cartCount = Object.values(cart).reduce((a, b) => a + b, 0);
  const cartTotal = Object.entries(cart).reduce((total, [id, qty]) => {
    const product = mockProducts.find(p => p.id === Number(id));
    return total + (product?.price || 0) * qty;
  }, 0);

  return (
    <div className="min-h-screen bg-background pb-24">
      {/* Header */}
      <header className="bg-card border-b border-border sticky top-0 z-50">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => navigate("/client")}>
              <ArrowLeft className="w-5 h-5" />
            </Button>
            <h1 className="font-semibold">Loja</h1>
          </div>
          <Button variant="outline" size="sm" onClick={() => navigate("/client/cart")} className="relative">
            <ShoppingCart className="w-4 h-4 mr-2" />
            Carrinho
            {cartCount > 0 && (
              <Badge className="absolute -top-2 -right-2 h-5 w-5 p-0 flex items-center justify-center">
                {cartCount}
              </Badge>
            )}
          </Button>
        </div>
      </header>

      <main className="container mx-auto px-4 py-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {mockProducts.map((product) => (
            <Card key={product.id}>
              <CardContent className="p-4">
                <div className="aspect-square bg-muted rounded-lg mb-4 flex items-center justify-center">
                  <span className="text-4xl">📦</span>
                </div>
                <Badge variant="outline" className="mb-2">{product.category}</Badge>
                <h3 className="font-medium mb-1">{product.name}</h3>
                <p className="text-lg font-bold text-primary mb-3">R$ {product.price}</p>
                
                {cart[product.id] ? (
                  <div className="flex items-center justify-between">
                    <Button variant="outline" size="icon" onClick={() => removeFromCart(product.id)}>
                      <Minus className="w-4 h-4" />
                    </Button>
                    <span className="font-medium">{cart[product.id]}</span>
                    <Button variant="outline" size="icon" onClick={() => addToCart(product.id)}>
                      <Plus className="w-4 h-4" />
                    </Button>
                  </div>
                ) : (
                  <Button className="w-full" onClick={() => addToCart(product.id)}>
                    <Plus className="w-4 h-4 mr-2" />
                    Adicionar
                  </Button>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      </main>

      {/* Cart Footer */}
      {cartCount > 0 && (
        <div className="fixed bottom-0 left-0 right-0 bg-card border-t border-border p-4">
          <div className="container mx-auto flex items-center justify-between">
            <div>
              <p className="text-sm text-muted-foreground">{cartCount} itens</p>
              <p className="text-xl font-bold">R$ {cartTotal}</p>
            </div>
            <Button size="lg" onClick={() => navigate("/client/cart")}>
              Ver Carrinho
            </Button>
          </div>
        </div>
      )}
    </div>
  );
};

export default ClientShop;
