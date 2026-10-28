# -----------------------------------------------------------------------------
# geoecu · Figuras del README
#
# Genera las imágenes de man/figures/ que muestra el README. Usa solo datos
# reales del paquete (catálogo dpa y áreas), nada simulado.
#
# Requisitos: geoecu, ggplot2, patchwork
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
                                  hjust = 0.5, margin = margin(b = 4)),
        plot.subtitle = element_text(size = 9.5, color = "grey40", hjust = 0.5),
        legend.position = "bottom",
        legend.title = element_text(size = 9, color = "grey30"),
        legend.text = element_text(size = 8.5, color = "grey30"),
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
       width = 13, height = 5.6, dpi = 150)

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
       width = 8, height = 6.6, dpi = 150)

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
               plot.margin = margin(12, 12, 12, 12))
ggsave(file.path(dir_fig, "README-loja.png"), g_loja,
       width = 7, height = 7, dpi = 150)

message("Figuras escritas en ", dir_fig)
