import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Scissors, Calendar, Star } from "lucide-react";

interface BrandingPreviewProps {
  primaryColor: string;
  secondaryColor: string;
  backgroundColor: string;
  cardColor: string;
  fontFamily: string;
  borderRadius: string;
  spacing: string;
}

const fontFamilies: Record<string, string> = {
  "Source Sans Pro": "'Source Sans Pro', sans-serif",
  "Inter": "'Inter', sans-serif",
  "Poppins": "'Poppins', sans-serif",
  "Roboto": "'Roboto', sans-serif",
  "Playfair Display": "'Playfair Display', serif",
};

const spacingValues: Record<string, string> = {
  compact: "0.5rem",
  normal: "1rem",
  relaxed: "1.5rem",
};

export function BrandingPreview({
  primaryColor,
  secondaryColor,
  backgroundColor,
  cardColor,
  fontFamily,
  borderRadius,
  spacing,
}: BrandingPreviewProps) {
  const fontStack = fontFamilies[fontFamily] || fontFamilies["Source Sans Pro"];
  const spacingValue = spacingValues[spacing] || spacingValues.normal;
  const radiusValue = `${borderRadius}rem`;

  return (
    <div className="space-y-4">
      <h4 className="font-semibold text-foreground">Preview ao Vivo</h4>
      <div
        className="border-2 border-dashed border-border overflow-hidden"
        style={{ 
          backgroundColor, 
          fontFamily: fontStack,
          borderRadius: radiusValue,
          padding: spacingValue,
        }}
      >
        {/* Mini Header */}
        <div
          className="flex items-center justify-between"
          style={{ 
            backgroundColor: cardColor,
            borderRadius: radiusValue,
            padding: spacingValue,
            marginBottom: spacingValue,
          }}
        >
          <div className="flex items-center gap-2">
            <div
              className="w-8 h-8 flex items-center justify-center"
              style={{ backgroundColor: primaryColor, borderRadius: radiusValue }}
            >
              <Scissors className="w-4 h-4 text-white" />
            </div>
            <span className="font-semibold text-sm" style={{ color: primaryColor }}>
              Sua Barbearia
            </span>
          </div>
          <Badge
            style={{
              backgroundColor: `${primaryColor}20`,
              color: primaryColor,
              borderColor: primaryColor,
              borderRadius: radiusValue,
            }}
            variant="outline"
          >
            Premium
          </Badge>
        </div>

        {/* Mini Cards */}
        <div className="grid grid-cols-2" style={{ gap: spacingValue, marginBottom: spacingValue }}>
          <div
            style={{ backgroundColor: cardColor, borderRadius: radiusValue, padding: spacingValue }}
          >
            <div className="flex items-center gap-2 mb-2">
              <Calendar className="w-4 h-4" style={{ color: primaryColor }} />
              <span className="text-xs font-medium" style={{ color: secondaryColor }}>
                Agendamentos
              </span>
            </div>
            <p className="text-lg font-bold" style={{ color: primaryColor }}>
              24
            </p>
          </div>
          <div
            style={{ backgroundColor: cardColor, borderRadius: radiusValue, padding: spacingValue }}
          >
            <div className="flex items-center gap-2 mb-2">
              <Star className="w-4 h-4" style={{ color: primaryColor }} />
              <span className="text-xs font-medium" style={{ color: secondaryColor }}>
                Avaliação
              </span>
            </div>
            <p className="text-lg font-bold" style={{ color: primaryColor }}>
              4.9
            </p>
          </div>
        </div>

        {/* Mini Button */}
        <Button
          className="w-full text-sm"
          style={{
            backgroundColor: primaryColor,
            color: "#fff",
            borderRadius: radiusValue,
          }}
        >
          Agendar Horário
        </Button>
      </div>
      <p className="text-xs text-muted-foreground text-center">
        Esta é uma prévia de como sua marca aparecerá para os clientes
      </p>
    </div>
  );
}
