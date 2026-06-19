---
name: Obsidian Gold Executive
colors:
  surface: '#131315'
  surface-dim: '#131315'
  surface-bright: '#39393b'
  surface-container-lowest: '#0e0e10'
  surface-container-low: '#1c1b1d'
  surface-container: '#201f21'
  surface-container-high: '#2a2a2c'
  surface-container-highest: '#353437'
  on-surface: '#e5e1e4'
  on-surface-variant: '#d3c4b0'
  inverse-surface: '#e5e1e4'
  inverse-on-surface: '#313032'
  outline: '#9c8f7d'
  outline-variant: '#4f4536'
  surface-tint: '#f5bd57'
  primary: '#f5bd57'
  on-primary: '#422c00'
  primary-container: '#d4a03c'
  on-primary-container: '#533900'
  inverse-primary: '#7d5800'
  secondary: '#75daa8'
  on-secondary: '#003823'
  secondary-container: '#008056'
  on-secondary-container: '#d1ffe3'
  tertiary: '#c8c5ca'
  on-tertiary: '#303033'
  tertiary-container: '#aaa8ac'
  on-tertiary-container: '#3e3d41'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdea9'
  primary-fixed-dim: '#f5bd57'
  on-primary-fixed: '#271900'
  on-primary-fixed-variant: '#5f4100'
  secondary-fixed: '#92f7c3'
  secondary-fixed-dim: '#75daa8'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005235'
  tertiary-fixed: '#e4e1e6'
  tertiary-fixed-dim: '#c8c5ca'
  on-tertiary-fixed: '#1b1b1e'
  on-tertiary-fixed-variant: '#47464a'
  background: '#131315'
  on-background: '#e5e1e4'
  surface-variant: '#353437'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-sm:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  display-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style
The design system is engineered to evoke the atmosphere of a high-end, members-only barbershop. It targets a discerning clientele who values precision, luxury, and technological sophistication. The aesthetic is a fusion of **Modern Corporate** and **Glassmorphism**, drawing inspiration from luxury automotive dashboards and premium fintech interfaces.

The UI should feel heavy, expensive, and grounded. It utilizes a "Deep Obsidian" foundation punctuated by "Premium Gold" accents to create a high-contrast, prestigious environment. Visual interest is generated through depth—using layered semi-transparent surfaces and subtle golden glows—rather than decorative clutter.

## Colors
The palette is dominated by **Deep Obsidian (#0A0A0C)** for the canvas to ensure absolute black depth, providing a void-like backdrop that makes foreground elements pop. 

- **Primary Action (Gold):** Used sparingly for primary buttons, active states, and premium indicators. It should feel like a metallic glint in a dark room.
- **Surface (Graphite):** Cards and containers use **#18181B**. To enhance the premium feel, these surfaces must feature a 6% opacity white border to simulate a "beveled glass" edge.
- **Success (Soft Green):** Reserved for loyalty club tags, confirmed appointments, and positive status changes.
- **Typography:** Titles use high-contrast **#F3F4F6** for immediate legibility, while secondary body text uses **#9CA3AF** to maintain visual hierarchy and reduce eye strain in dark mode.

## Typography
The typography strategy pairs the technical, geometric precision of **Space Grotesk** for headings with the utilitarian clarity of **Inter** for functional text. 

Headlines should feel "engineered," utilizing slight negative letter-spacing to create a tight, professional look. Labels and small metadata should often be uppercase with increased tracking to mimic the aesthetic of luxury watch faces or instrument clusters. Use `display-lg-mobile` for hero sections on handsets to maintain impact without overflowing the viewport.

## Layout & Spacing
The system follows a strict 4px grid. Layouts should emphasize a **fixed-width centered approach** for desktop and a **fluid-margin approach** for mobile.

- **Margins:** Standard mobile horizontal padding is 24px to provide "breathing room" against the dark edges of the screen.
- **Sectioning:** Vertical stacks use 32px or 48px gaps to define distinct functional areas (e.g., "Available Times" vs "Service Selection").
- **Dashboard Grid:** On tablets and desktops, use a 12-column grid. Components like "Upcoming Appointments" should span significant width, while "Barber Profiles" should appear as a horizontal scrolling list or a 3-column grid.

## Elevation & Depth
Depth is created through transparency and light simulation rather than traditional shadows.

1.  **Level 0 (Base):** #0A0A0C background.
2.  **Level 1 (Cards):** #18181B with a 1px solid border at 6% white opacity.
3.  **Level 2 (Active/Floating):** Surfaces use a background blur (Backdrop Filter: 12px) and a subtle inner glow. 
4.  **The "Golden Glow":** Primary buttons and active selection states should feature a soft, diffused outer glow using the primary gold color (#D4A03C) at 15-20% opacity to simulate light emitting from the element.

## Shapes
The shape language is sophisticated and modern, avoiding the "bubbly" look of consumer apps in favor of structured elegance.

- **Standard Cards:** 16px corner radius.
- **Interactive Elements:** Buttons and input fields follow the 16px standard.
- **Modals & Sheets:** 20px corner radius for top corners to create a distinct "encapsulated" feel when appearing over the main UI.
- **Chips/Tags:** Should remain slightly less rounded (8px) to maintain a technical, dashboard-inspired look.

## Components
- **Buttons:** Primary buttons are solid Gold (#D4A03C) with Black text. Secondary buttons are ghost-style with the 6% white border and Gold text.
- **Cards:** Must include the 1px white border (0.06 opacity). Backgrounds should be slightly translucent if an image or gradient is behind them.
- **Chips/Club Tags:** Use the Soft Green (#52B788) for the background at 10% opacity, with solid green text and a 1px green border.
- **Inputs:** Darker than the surface color (#0F0F12) with a 1px border that turns Gold on focus.
- **Lists:** Use 1px #FFFFFF (0.04 opacity) dividers between items.
- **Dashboard Widgets:** Use circular progress indicators for loyalty points, utilizing the Gold glow effect for the progress bar.