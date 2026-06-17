import { useState } from "react";
import DashboardLayout from "@/components/layout/DashboardLayout";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Plus,
  Search,
  MoreVertical,
  Package,
  AlertTriangle,
  Edit,
  Trash2,
  Loader2,
} from "lucide-react";
import { Input } from "@/components/ui/input";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useProducts } from "@/hooks/useProducts";
import { useStore } from "@/hooks/useStore";

const Products = () => {
  const { store } = useStore();
  const { products, lowStockProducts, isLoading } = useProducts(store?.id);
  const [searchTerm, setSearchTerm] = useState("");

  const filteredProducts = products.filter(p =>
    p.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const outOfStockProducts = products.filter(p => p.stock_quantity === 0);

  if (isLoading) {
    return (
      <DashboardLayout title="Produtos" subtitle="Gerencie seu catálogo de produtos">
        <div className="flex items-center justify-center h-64">
          <Loader2 className="w-8 h-8 animate-spin text-primary" />
        </div>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout
      title="Produtos"
      subtitle="Gerencie seu catálogo de produtos"
    >
      {/* Header Actions */}
      <div className="flex flex-col sm:flex-row gap-4 mb-6">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            placeholder="Buscar produto..."
            className="pl-9"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
        <Button variant="premium">
          <Plus className="w-4 h-4 mr-2" />
          Novo Produto
        </Button>
      </div>

      {/* Alerts */}
      {(lowStockProducts.length > 0 || outOfStockProducts.length > 0) && (
        <div className="mb-6 space-y-2">
          {outOfStockProducts.length > 0 && (
            <div className="p-4 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 flex items-center gap-3">
              <AlertTriangle className="w-5 h-5 text-destructive" />
              <div>
                <p className="font-medium text-foreground">
                  {outOfStockProducts.length} produto(s) sem estoque
                </p>
                <p className="text-sm text-muted-foreground">
                  {outOfStockProducts.map(p => p.name).join(", ")}
                </p>
              </div>
            </div>
          )}
          {lowStockProducts.length > 0 && (
            <div className="p-4 rounded-lg bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800 flex items-center gap-3">
              <AlertTriangle className="w-5 h-5 text-amber-600 dark:text-amber-400" />
              <div>
                <p className="font-medium text-foreground">
                  {lowStockProducts.length} produto(s) com estoque baixo
                </p>
                <p className="text-sm text-muted-foreground">
                  {lowStockProducts.map(p => p.name).join(", ")}
                </p>
              </div>
            </div>
          )}
        </div>
      )}

      {/* Products Grid */}
      {filteredProducts.length === 0 ? (
        <Card className="border">
          <CardContent className="p-12 text-center">
            <Package className="w-12 h-12 mx-auto text-muted-foreground mb-4" />
            <h3 className="text-lg font-semibold mb-2">Nenhum produto cadastrado</h3>
            <p className="text-muted-foreground mb-4">
              Adicione produtos para venda na barbearia
            </p>
            <Button variant="premium">
              <Plus className="w-4 h-4 mr-2" />
              Novo Produto
            </Button>
          </CardContent>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredProducts.map((product) => {
            const isLowStock = product.stock_quantity <= product.min_stock && product.stock_quantity > 0;
            const isOutOfStock = product.stock_quantity === 0;
            const margin = product.cost ? ((product.price - product.cost) / product.price * 100).toFixed(0) : '--';

            return (
              <Card
                key={product.id}
                className={`border hover:shadow-md transition-all ${isOutOfStock ? "opacity-60" : ""
                  }`}
              >
                <CardContent className="p-5">
                  <div className="flex items-start justify-between mb-3">
                    <div className="flex items-center gap-3">
                      <div className={`w-12 h-12 rounded-lg flex items-center justify-center ${isOutOfStock
                          ? "bg-red-100 dark:bg-red-900/30"
                          : isLowStock
                            ? "bg-amber-100 dark:bg-amber-900/30"
                            : "bg-primary/10"
                        }`}>
                        <Package className={`w-6 h-6 ${isOutOfStock
                            ? "text-destructive"
                            : isLowStock
                              ? "text-amber-600 dark:text-amber-400"
                              : "text-primary"
                          }`} />
                      </div>
                      <div>
                        <h3 className="font-semibold text-foreground">{product.name}</h3>
                        {product.category && (
                          <Badge variant="secondary" className="text-xs">
                            {product.category}
                          </Badge>
                        )}
                      </div>
                    </div>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon">
                          <MoreVertical className="w-4 h-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end" className="bg-popover">
                        <DropdownMenuItem>
                          <Edit className="w-4 h-4 mr-2" />
                          Editar
                        </DropdownMenuItem>
                        <DropdownMenuItem>Ajustar estoque</DropdownMenuItem>
                        <DropdownMenuItem className="text-destructive">
                          <Trash2 className="w-4 h-4 mr-2" />
                          Excluir
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </div>

                  <div className="grid grid-cols-2 gap-2 mb-4">
                    <div className="p-2 rounded-lg bg-muted/50">
                      <p className="text-lg font-bold text-foreground">
                        R$ {product.price.toFixed(2)}
                      </p>
                      <p className="text-xs text-muted-foreground">Preço venda</p>
                    </div>
                    <div className="p-2 rounded-lg bg-muted/50">
                      <p className="text-lg font-bold text-green-600 dark:text-green-400">
                        {margin}%
                      </p>
                      <p className="text-xs text-muted-foreground">Margem</p>
                    </div>
                  </div>

                  <div className="flex items-center justify-between pt-3 border-t">
                    <div className="flex items-center gap-2">
                      {isOutOfStock ? (
                        <Badge variant="destructive">Sem estoque</Badge>
                      ) : isLowStock ? (
                        <Badge className="bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400">
                          Estoque baixo
                        </Badge>
                      ) : (
                        <Badge variant="secondary">{product.stock_quantity} un.</Badge>
                      )}
                    </div>
                    {product.sku && (
                      <span className="text-xs text-muted-foreground">
                        SKU: {product.sku}
                      </span>
                    )}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </DashboardLayout>
  );
};

export default Products;
