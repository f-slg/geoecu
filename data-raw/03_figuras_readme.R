# -----------------------------------------------------------------------------
# geoecu · Figuras del README
#
# Genera las imágenes de man/figures/ que muestra el README. Usa solo datos
# reales del paquete (catálogo dpa y áreas) y, para la densidad, la población
# del INEC que distribuye pobecu; nada simulado.
#
# Requisitos: geoecu, ggplot2, patchwork, pobecu
# Uso:        Rscript data-raw/03_figuras_readme.R
# -----------------------------------------------------------------------------
library(geoecu)
library(ggplot2)
library(patchwork)

dir_fig <- "man/figures"

azul   <- "#0F2233"
dorado <- "#F2B705"

tema <- theme_void(base_size = 12) +
  theme(plot.title = element_text(face = "bold", size = 13, color = azul,
                                  hjust = 0.5, margin = margin(t = 3, b = 7, l = 4, r = 4)),
        plot.subtitle = element_text(size = 9.5, color = "grey40",
                                     hjust = 0.5, margin = margin(b = 5, l = 4, r = 4)),
        legend.position = "bottom",
        legend.title = element_text(size = 9, color = "grey30"),
        legend.text = element_text(size = 8.5, color = "grey30"),
        plot.title.position = "plot",
        plot.margin = margin(t = 18, r = 20, b = 18, l = 22, unit = "pt"),
        plot.background = element_rect(fill = "white", color = NA))

marco <- function(capa) {
  geom_sf(data = marco_galapagos(capa), fill = NA, color = "grey78",
          linewidth = 0.3)
}

# Regiones naturales por código de provincia
region <- data.frame(
  dpa_provin = sprintf("%02d", 1:24),
  region = c("Sierra", "Sierra", "Sierra", "Sierra", "Sierra", "Sierra",
             "Costa", "Costa", "Costa", "Sierra", "Sierra", "Costa",
             "Costa", "Amazonía", "Amazonía", "Amazonía", "Sierra",
             "Sierra", "Amazonía", "Insular", "Amazonía", "Amazonía",
             "Costa", "Costa")
)
region <- rbind(region, data.frame(dpa_provin = "90", region = "Zona en estudio"))
region$region <- factor(region$region,
                        levels = c("Costa", "Sierra", "Amazonía", "Insular",
                                   "Zona en estudio"))

prov <- reubicar_galapagos(read_provincias(crs = 32717))
cant <- reubicar_galapagos(read_cantones(crs = 32717))
parr <- reubicar_galapagos(read_parroquias(crs = 32717))

# --- 1. Imagen principal: los tres niveles ----------------------------------
p_prov <- merge(prov, region, by = "dpa_provin")
g1 <- ggplot(p_prov) +
  geom_sf(aes(fill = region), color = "white", linewidth = 0.35) +
  marco(prov) +
  scale_fill_manual(values = c(Costa = "#E9A23B", Sierra = "#7B9E5A",
                               "Amazonía" = "#2E6E5C", Insular = "#4C8DB5",
                               "Zona en estudio" = "grey80"),
                    name = NULL) +
  labs(title = "24 provincias", subtitle = "por región natural") +
  tema

n_parr <- as.data.frame(table(dpa_canton = dpa$dpa_canton), stringsAsFactors = FALSE)
names(n_parr)[2] <- "parroquias"
c_parr <- merge(cant, n_parr, by = "dpa_canton")
g2 <- ggplot(c_parr) +
  geom_sf(aes(fill = parroquias), color = "white", linewidth = 0.12) +
  geom_sf(data = prov, fill = NA, color = azul, linewidth = 0.25) +
  marco(prov) +
  scale_fill_gradientn(colours = c("#FFF4D2", "#F2C14E", "#D9822B", "#8C3B12"),
                       trans = "log10", breaks = c(2, 5, 10, 25, 60),
                       name = "parroquias") +
  guides(fill = guide_colorbar(barwidth = 9, barheight = 0.5)) +
  labs(title = "223 cantones", subtitle = "número de parroquias") +
  tema

g3 <- ggplot(parr) +
  geom_sf(aes(fill = tipo), color = "white", linewidth = 0.05) +
  geom_sf(data = prov, fill = NA, color = azul, linewidth = 0.25) +
  marco(prov) +
  scale_fill_manual(values = c("cabecera cantonal" = "#C2410C",
                               "parroquia rural" = "#F6E7C8",
                               "zona en estudio" = "grey80"),
                    name = NULL) +
  labs(title = "1048 parroquias", subtitle = "cabeceras cantonales y rurales") +
  tema

principal <- (g1 | g2 | g3) +
  plot_annotation(theme = theme(plot.background = element_rect(fill = "white",
                                                               color = NA)))
ggsave(file.path(dir_fig, "README-niveles.png"), principal,
       width = 15, height = 6.3, dpi = 200)

# --- 2. Ejemplo de geoecu_unir(): mapa nacional por cantón -------------------
mapa <- geoecu_unir(n_parr, "dpa_canton", "canton", crs = 32717) |>
  reubicar_galapagos()

g_nac <- ggplot() +
  geom_sf(data = mapa, aes(fill = parroquias), color = "white", linewidth = 0.12) +
  geom_sf(data = prov, fill = NA, color = azul, linewidth = 0.3) +
  marco(prov) +
  scale_fill_gradientn(colours = c("#FFF4D2", "#F2C14E", "#D9822B", "#8C3B12"),
                       trans = "log10", breaks = c(2, 5, 10, 25, 60),
                       name = "Parroquias") +
  labs(title = "Número de parroquias por cantón",
       subtitle = "geoecu_unir() + reubicar_galapagos()") +
  tema + theme(legend.position = "right",
               plot.title = element_text(hjust = 0),
               plot.subtitle = element_text(hjust = 0, family = "mono"))
ggsave(file.path(dir_fig, "README-nacional.png"), g_nac,
       width = 9.5, height = 7.5, dpi = 200)

# --- 3. Acercamiento: parroquias de Loja en alta resolución ------------------
loja_p <- read_parroquias(provincia = "Loja", resolucion = "alta", crs = 32717)
loja_c <- read_cantones(provincia = "Loja", resolucion = "alta", crs = 32717)

loja_p$canton <- factor(loja_p$canton)
g_loja <- ggplot() +
  geom_sf(data = loja_p, aes(fill = canton), color = "white", linewidth = 0.2) +
  geom_sf(data = loja_c, fill = NA, color = azul, linewidth = 0.5) +
  geom_sf_label(data = loja_c, aes(label = canton), size = 2.3, color = azul,
                fontface = "bold", fill = scales::alpha("white", 0.8),
                linewidth = 0, label.padding = unit(0.12, "lines")) +
  scale_fill_manual(values = grDevices::hcl.colors(16, "Set 3"), guide = "none") +
  labs(title = sprintf("Provincia de Loja: %d cantones y %d parroquias",
                       nrow(loja_c), nrow(loja_p)),
       subtitle = "read_parroquias(provincia = \"Loja\", resolucion = \"alta\")") +
  tema + theme(plot.title = element_text(hjust = 0),
               plot.subtitle = element_text(hjust = 0, family = "mono"),
               plot.margin = margin(t = 18, r = 20, b = 18, l = 22, unit = "pt"))
ggsave(file.path(dir_fig, "README-loja.png"), g_loja,
       width = 8, height = 8, dpi = 200)

message("Figuras escritas en ", dir_fig)


# --- 4. Galería detallada por nivel ------------------------------------------
# Imágenes nuevas para README y pkgdown, generadas solo con los datos de geoecu.
# Se usa la resolución baja para vistas nacionales y alta para acercamientos.

# Mapa provincial con regiones naturales y nombres (24 provincias).
prov_etiquetas <- prov[prov$tipo == "provincia" & prov$dpa_provin != "20", ]
p_provincias <- ggplot() +
  geom_sf(data = p_prov, aes(fill = region), color = "white", linewidth = 0.4) +
  geom_sf_text(data = prov_etiquetas, aes(label = provincia),
               color = azul, size = 2.1, fontface = "bold",
               check_overlap = TRUE) +
  marco(prov) +
  scale_fill_manual(values = c(Costa = "#E9A23B", Sierra = "#7B9E5A",
                               "Amazonía" = "#2E6E5C", Insular = "#4C8DB5",
                               "Zona en estudio" = "grey80"),
                    name = "Región natural", drop = FALSE,
                    guide = guide_legend(nrow = 1)) +
  labs(title = "Ecuador | Provincias",
       subtitle = "24 provincias y una zona en estudio · División Político-Administrativa",
       caption = "Galápagos reubicado únicamente para visualización") +
  tema +
  theme(legend.position = "bottom",
        plot.title = element_text(hjust = 0, face = "bold", size = 17),
        plot.subtitle = element_text(hjust = 0, size = 10),
        plot.caption = element_text(size = 8, color = "grey45"))
ggsave(file.path(dir_fig, "README-provincias.png"), p_provincias,
       width = 10.5, height = 8, dpi = 200)

# Mapa cantonal: número de unidades parroquiales por cantón.
p_cantones <- ggplot() +
  geom_sf(data = c_parr, aes(fill = parroquias),
          color = "white", linewidth = 0.08) +
  geom_sf(data = prov, fill = NA, color = azul, linewidth = 0.42) +
  marco(prov) +
  scale_fill_gradientn(
    colours = c("#FFF4D2", "#F2C14E", "#D9822B", "#8C3B12"),
    trans = "log10", breaks = c(1, 2, 5, 10, 25, 50),
    name = "Parroquias por cantón", na.value = "grey85"
  ) +
  labs(title = "Ecuador | Cantones",
       subtitle = "223 cantones y dos zonas en estudio · número de parroquias",
       caption = "Escala logarítmica · límites provinciales resaltados") +
  tema +
  theme(legend.position = "right",
        plot.title = element_text(hjust = 0, face = "bold", size = 17),
        plot.subtitle = element_text(hjust = 0, size = 10),
        plot.caption = element_text(size = 8, color = "grey45"))
ggsave(file.path(dir_fig, "README-cantones.png"), p_cantones,
       width = 10.5, height = 8, dpi = 200)

# Mapa parroquial: país completo + acercamiento a Puyango (alta resolución).
p_parroquias <- ggplot() +
  geom_sf(data = parr, aes(fill = tipo), color = "white", linewidth = 0.04) +
  geom_sf(data = prov, fill = NA, color = azul, linewidth = 0.3) +
  marco(prov) +
  scale_fill_manual(values = c("cabecera cantonal" = "#C2410C",
                               "parroquia rural" = "#F6E7C8",
                               "zona en estudio" = "grey80"),
                    name = "Tipo de unidad") +
  labs(title = "Ecuador | Parroquias",
       subtitle = "1048 parroquias y tres zonas en estudio") +
  tema +
  theme(plot.title = element_text(hjust = 0, face = "bold", size = 14),
        plot.subtitle = element_text(hjust = 0, size = 9))

puyango <- read_parroquias(provincia = "Loja", canton = "Puyango",
                           resolucion = "alta", crs = 32717)
p_detalle <- ggplot(puyango) +
  geom_sf(aes(fill = tipo), color = azul, linewidth = 0.55) +
  geom_sf_text(aes(label = parroquia), color = azul,
               size = 2.6, fontface = "bold", check_overlap = TRUE) +
  scale_fill_manual(values = c("cabecera cantonal" = "#C2410C",
                               "parroquia rural" = "#F6E7C8"),
                    name = "Tipo de unidad") +
  labs(title = "Detalle | Puyango (Loja)",
       subtitle = "Límites y nombres parroquiales · alta resolución") +
  tema +
  theme(plot.title = element_text(hjust = 0, face = "bold", size = 14),
        plot.subtitle = element_text(hjust = 0, size = 9))

panel_parroquial <- (p_parroquias | p_detalle) +
  plot_layout(widths = c(1.55, 1), guides = "collect") &
  theme(legend.position = "bottom")
ggsave(file.path(dir_fig, "README-parroquias.png"), panel_parroquial,
       width = 15, height = 7.6, dpi = 200)

# Densidad poblacional por provincia, cantón y parroquia: población del INEC
# (vía pobecu) / area_km2, con una escala logarítmica común.
anio <- 2026
prov <- reubicar_galapagos(read_provincias(crs = 32717))
cant <- reubicar_galapagos(read_cantones(crs = 32717))
parr <- reubicar_galapagos(read_parroquias(crs = 32717))

# Habitantes por km². `grupo` es el código de la unidad en la población del
# INEC (pobecu): las unidades creadas después se suman a la de origen.
densidad <- function(capa, grupo, pob) {
  area <- tapply(capa$area_km2, grupo, sum)
  hab <- pob$poblacion[match(names(area), pob$codigo)]
  unname((hab / area)[grupo])
}

pob_prov <- pobecu::poblacion(nivel = "provincia", anio = anio)
pob_prov$codigo <- pob_prov$dpa_provin
prov$densidad <- densidad(prov, prov$dpa_provin, pob_prov)

# Borbón (0809) y Sevilla Don Bosco (1413) se separaron de Eloy Alfaro y Morona
pob_cant <- pobecu::poblacion(nivel = "canton", anio = anio)
pob_cant$codigo <- pob_cant$dpa_canton
grupo_cant <- c("0809" = "0802", "1413" = "1401")
cant$densidad <- densidad(
  cant, ifelse(cant$dpa_canton %in% names(grupo_cant),
               grupo_cant[cant$dpa_canton], cant$dpa_canton), pob_cant)

# Parroquias (estimación de pobecu, no oficial): los códigos del Censo 2022
# que cambiaron se actualizan, y las parroquias creadas después se suman a
# la parroquia de la que se separaron.
pob_parr <- pobecu::poblacion(nivel = "parroquia", anio = anio)
pob_parr$codigo <- ifelse(pob_parr$dpa_parroq %in% parr$dpa_parroq,
                          pob_parr$dpa_parroq,
                          actualizar_codigo(pob_parr$dpa_parroq))
grupo_parr <- c("131251" = "131250",   # Sosote -> Rocafuerte
                "160167" = "160162",   # Shuar Pastaza -> Simón Bolívar
                "170257" = "170250",   # Juan Montalvo -> Cayambe
                "210456" = "210450",   # La Magdalena -> Shushufindi
                "210457" = "210450",   # La Primavera -> Shushufindi
                "210458" = "210450")   # Miss Ecuador -> Shushufindi
parr$densidad <- densidad(
  parr, ifelse(parr$dpa_parroq %in% names(grupo_parr),
               grupo_parr[parr$dpa_parroq], parr$dpa_parroq), pob_parr)

# Una sola escala para comparar los tres niveles
limites <- range(c(prov$densidad, cant$densidad, parr$densidad), na.rm = TRUE)
escala <- scale_fill_gradientn(
  colours = c("#FFF4D2", "#F2C14E", "#D9822B", "#8C3B12"),
  trans = "log10", limits = limites,
  breaks = c(0.1, 1, 10, 100, 1000),
  labels = c("0,1", "1", "10", "100", "1.000"),
  name = "Habitantes por km²", na.value = "grey85"
)

mapa_densidad <- function(capa, titulo, borde) {
  ggplot() +
    geom_sf(data = capa, aes(fill = densidad), color = "white",
            linewidth = borde) +
    geom_sf(data = prov, fill = NA, color = azul, linewidth = 0.3) +
    marco(prov) +
    escala +
    labs(title = titulo) +
    tema +
    theme(plot.margin = margin(t = 6, r = 6, b = 6, l = 6, unit = "pt"))
}

panel_densidad <- (mapa_densidad(prov, "Provincias", 0.15) |
                     mapa_densidad(cant, "Cantones", 0.08) |
                     mapa_densidad(parr, "Parroquias", 0.03)) +
  plot_layout(guides = "collect") +
  plot_annotation(
    title = "Ecuador | Densidad poblacional",
    subtitle = sprintf("Población %d (INEC, vía pobecu) / area_km2 de geoecu", anio),
    caption = paste("Escala logarítmica común · parroquias: estimación de pobecu, no oficial",
                    "· gris: zonas en estudio, sin población asignada"),
    theme = theme(plot.title = element_text(face = "bold", size = 17, color = azul),
                  plot.subtitle = element_text(size = 10, color = "grey40"),
                  plot.caption = element_text(size = 8, color = "grey45"),
                  plot.margin = margin(t = 18, r = 20, b = 12, l = 22, unit = "pt"),
                  plot.background = element_rect(fill = "white", color = NA))
  ) &
  theme(legend.position = "bottom",
        legend.title.position = "top", legend.title = element_text(hjust = 0.5),
        legend.key.width = unit(2.2, "cm"), legend.key.height = unit(0.3, "cm"))

ggsave(file.path(dir_fig, "README-densidad.png"), panel_densidad,
       width = 15, height = 6.2, dpi = 200)

message("Galería detallada escrita en ", dir_fig)
