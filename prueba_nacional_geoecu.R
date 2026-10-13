# =============================================================================
#  geoecu · Prueba integral a escala nacional
#  ---------------------------------------------------------------------------
#  Recorre todo el paquete con un escenario de vigilancia SIMULADO:
#    1. Carga de los tres niveles y tiempos de lectura
#    2. Control de calidad: anidamiento y códigos
#    3. Datos "sucios" estilo Excel (códigos sin ceros, nombres sin tildes)
#    4. Agregación parroquia -> cantón -> provincia con el catálogo dpa
#    5. Mapa nacional por parroquia con Galápagos reubicado
#    6. Comparación de los tres niveles en un solo gráfico
#    7. Clasificación por cuantiles (estilo boletín epidemiológico)
#    8. Autocorrelación espacial (I de Moran) sin paquetes adicionales
#    9. Ranking de cantones
#   10. Exportación: PNG, CSV y GeoPackage
#   11. Mapa interactivo (si tienes leaflet instalado)
#
#  IMPORTANTE: los casos son SIMULADOS. No representan datos reales.
#  Ejecuta bloque por bloque (Ctrl + Enter) o todo con Ctrl + Shift + S.
# =============================================================================

# --- 0. Preparación ----------------------------------------------------------
for (p in c("ggplot2")) if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
if (!requireNamespace("geoecu", quietly = TRUE) ||
    utils::packageVersion("geoecu") < "0.2.0") {
  remotes::install_github("f-slg/geoecu")
}
library(geoecu)
library(ggplot2)

dir_salida <- "salidas_geoecu"
dir.create(dir_salida, showWarnings = FALSE)

# Paleta y tema comunes para todos los mapas
tema_mapa <- theme_void(base_size = 11) +
  theme(plot.title    = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(color = "grey35"),
        plot.caption  = element_text(color = "grey45", size = 8),
        legend.position = "right",
        plot.background = element_rect(fill = "white", color = NA))
nota <- "Datos SIMULADOS con fines de prueba · Capas: geoecu"

# Regiones naturales por código de provincia (para la simulación)
region <- data.frame(
  dpa_provin = sprintf("%02d", 1:24),
  region = c("Sierra", "Sierra", "Sierra", "Sierra", "Sierra", "Sierra",
             "Costa", "Costa", "Costa", "Sierra", "Sierra", "Costa",
             "Costa", "Amazonía", "Amazonía", "Amazonía", "Sierra",
             "Sierra", "Amazonía", "Insular", "Amazonía", "Amazonía",
             "Costa", "Costa")
)

# --- 1. Carga de los tres niveles (en UTM 17S, metros) -----------------------
tiempos <- system.time({
  prov <- read_provincias(crs = 32717)
  cant <- read_cantones(crs = 32717)
  parr <- read_parroquias(crs = 32717)
})
cat(sprintf("Cargados: %d provincias, %d cantones, %d parroquias en %.2f s\n",
            nrow(prov), nrow(cant), nrow(parr), tiempos[["elapsed"]]))

# --- 2. Control de calidad ---------------------------------------------------
# a) Las áreas deben cuadrar entre niveles (los niveles se construyeron
#    disolviendo parroquias, así que la diferencia debe ser ~0)
area_parr_por_cant <- tapply(parr$area_km2, parr$dpa_canton, sum)
dif_cant <- max(abs(area_parr_por_cant[cant$dpa_canton] - cant$area_km2))
area_cant_por_prov <- tapply(cant$area_km2, cant$dpa_provin, sum)
dif_prov <- max(abs(area_cant_por_prov[prov$dpa_provin] - prov$area_km2))
cat(sprintf("Máxima diferencia de área parroquia->cantón: %.3f km²\n", dif_cant))
cat(sprintf("Máxima diferencia de área cantón->provincia: %.3f km²\n", dif_prov))

# b) Todas las parroquias de la capa están en el catálogo y viceversa
stopifnot(setequal(parr$dpa_parroq, dpa$dpa_parroq))
cat("Catálogo dpa y capa de parroquias: coinciden 100 %\n")

# c) Resumen nacional por región
resumen_region <- merge(
  aggregate(area_km2 ~ dpa_provin, data = sf::st_drop_geometry(prov), FUN = sum),
  region, by = "dpa_provin")
print(aggregate(area_km2 ~ region, data = resumen_region, FUN = sum))

# --- 3. Datos de vigilancia simulados, "sucios" como vienen de Excel ---------
set.seed(2026)
base <- merge(dpa, region, by = "dpa_provin")
riesgo <- c(Costa = 2.2, "Amazonía" = 1.8, Sierra = 0.4, Insular = 0.6)
base$lambda <- exp(riesgo[base$region] + rnorm(nrow(base), 0, 0.6))
casos_excel <- data.frame(
  COD_PARROQUIA = as.numeric(base$dpa_parroq),        # se pierden los ceros
  PARROQUIA     = tolower(base$parroquia),            # nombres en minúsculas
  CASOS         = rpois(nrow(base), base$lambda)
)
head(casos_excel)          # p. ej. 10151 en lugar de "010151"

# Recuperar códigos y comprobar nombres
casos_excel$dpa_parroq <- formatear_codigo(casos_excel$COD_PARROQUIA, "parroquia")
control_nombres <- merge(casos_excel, dpa[c("dpa_parroq", "parroquia")], by = "dpa_parroq")
cat(sprintf("Nombres que coinciden tras normalizar: %d de %d\n",
            sum(normalizar_nombre(control_nombres$PARROQUIA) ==
                normalizar_nombre(control_nombres$parroquia)),
            nrow(control_nombres)))

# --- 4. Agregación por niveles usando solo el catálogo ----------------------
casos <- merge(casos_excel[c("dpa_parroq", "CASOS")], dpa, by = "dpa_parroq")
casos_cant <- aggregate(CASOS ~ dpa_canton, data = casos, FUN = sum)
casos_prov <- aggregate(CASOS ~ dpa_provin, data = casos, FUN = sum)
cat(sprintf("Total nacional: %s casos simulados\n", format(sum(casos$CASOS), big.mark = ".", decimal.mark = ",")))

# Unir a las capas (geoecu_unir conserva todos los polígonos)
m_parr <- geoecu_unir(casos[c("dpa_parroq", "CASOS")], "dpa_parroq", "parroquia", crs = 32717)
m_cant <- geoecu_unir(casos_cant, "dpa_canton", "canton", crs = 32717)
m_prov <- geoecu_unir(casos_prov, "dpa_provin", "provincia", crs = 32717)

# Densidad: casos por 100 km² (sin población; las tasas llegarán con pobecu)
for (nm in c("m_parr", "m_cant", "m_prov")) {
  x <- get(nm); x$dens <- x$CASOS / x$area_km2 * 100; assign(nm, x)
}

# --- 5. Mapa nacional con Galápagos reubicado --------------------------------
# reubicar_galapagos() traslada las islas a la esquina superior izquierda y
# marco_galapagos() da el recuadro. Solo para visualizar, no para medir.
# (Requiere geoecu >= 0.2.0)
estilo_marco <- list(fill = NA, color = "grey80", linewidth = 0.3)

p_parr <- reubicar_galapagos(m_parr)
p_prov <- reubicar_galapagos(prov)

g_nacional <- ggplot() +
  geom_sf(data = p_parr, aes(fill = dens), color = NA) +
  geom_sf(data = p_prov, fill = NA, color = "white", linewidth = 0.35) +
  geom_sf(data = marco_galapagos(p_prov), fill = estilo_marco$fill,
          color = estilo_marco$color, linewidth = estilo_marco$linewidth) +
  scale_fill_viridis_c(option = "magma", direction = -1, trans = "log1p",
                       breaks = c(0, 5, 25, 100, 400), name = "Casos por\n100 km²") +
  labs(title = "Densidad de casos por parroquia · Ecuador",
       subtitle = "1262 parroquias",
       caption = nota) +
  tema_mapa
g_nacional
ggsave(file.path(dir_salida, "01_nacional_parroquias.png"), g_nacional,
       width = 8, height = 8, dpi = 200)

# --- 6. Los tres niveles lado a lado ----------------------------------------
cols <- c("nivel", "dens", "geometry")
tres <- rbind(
  transform(reubicar_galapagos(m_prov), nivel = "Provincias (24)")[, cols],
  transform(reubicar_galapagos(m_cant), nivel = "Cantones (221)")[, cols],
  transform(reubicar_galapagos(m_parr), nivel = "Parroquias (1262)")[, cols]
)
tres$nivel <- factor(tres$nivel, levels = unique(tres$nivel))

g_tres <- ggplot(tres) +
  geom_sf(aes(fill = dens), color = NA) +
  facet_wrap(~ nivel) +
  scale_fill_viridis_c(option = "magma", direction = -1, trans = "log1p",
                       breaks = c(0, 5, 25, 100, 400), name = "Casos por\n100 km²") +
  labs(title = "El mismo fenómeno a tres escalas",
       subtitle = "Cuanto más fino el nivel, más visible la heterogeneidad",
       caption = nota) +
  tema_mapa + theme(strip.text = element_text(face = "bold", size = 11),
                    plot.subtitle = element_text(color = "grey35",
                                                 margin = margin(b = 12)))
g_tres
ggsave(file.path(dir_salida, "02_tres_niveles.png"), g_tres,
       width = 13, height = 5.5, dpi = 200)

# --- 7. Clasificación por cuantiles (estilo boletín) -------------------------
m_cant$clase <- cut(m_cant$CASOS,
                    breaks = unique(quantile(m_cant$CASOS, probs = seq(0, 1, 0.2))),
                    include.lowest = TRUE, dig.lab = 5)

g_quintiles <- ggplot(reubicar_galapagos(m_cant)) +
  geom_sf(aes(fill = clase), color = "white", linewidth = 0.1) +
  geom_sf(data = p_prov, fill = NA, color = "grey20", linewidth = 0.3) +
  geom_sf(data = marco_galapagos(p_prov), fill = estilo_marco$fill,
          color = estilo_marco$color, linewidth = estilo_marco$linewidth) +
  scale_fill_brewer(palette = "YlOrRd", name = "Casos\n(quintiles)") +
  labs(title = "Casos por cantón, clasificados en quintiles",
       caption = nota) +
  tema_mapa
g_quintiles
ggsave(file.path(dir_salida, "03_cantones_quintiles.png"), g_quintiles,
       width = 8, height = 8, dpi = 200)

# --- 8. I de Moran global (vecindad por contigüidad, sin paquetes extra) ----
moran_global <- function(x, valores, n_perm = 999) {
  vecinos <- sf::st_touches(x)
  n <- length(valores)
  z <- valores - mean(valores)
  calcular <- function(z) {
    num <- sum(vapply(seq_len(n), function(i) {
      v <- vecinos[[i]]; if (!length(v)) return(0)
      z[i] * mean(z[v])                       # pesos estandarizados por fila
    }, numeric(1)))
    s0 <- sum(lengths(vecinos) > 0)           # suma de pesos (filas con vecinos)
    (n / s0) * num / sum(z^2)
  }
  obs <- calcular(z)
  sim <- replicate(n_perm, calcular(sample(z)))
  list(I = obs, p_valor = (sum(sim >= obs) + 1) / (n_perm + 1),
       esperado = -1 / (n - 1))
}
mi <- moran_global(m_cant, m_cant$dens)
cat(sprintf("I de Moran (cantones, densidad): %.3f  | esperado: %.4f | p = %.3f\n",
            mi$I, mi$esperado, mi$p_valor))
cat("Un I positivo y significativo indica agrupamiento espacial:",
    "la simulación concentra casos en Costa y Amazonía.\n")

# --- 9. Ranking de cantones --------------------------------------------------
top <- sf::st_drop_geometry(m_cant)
top <- top[order(-top$CASOS), ][1:15, ]
top$etiqueta <- paste0(top$canton, " (", top$provincia, ")")

g_top <- ggplot(top, aes(x = CASOS, y = reorder(etiqueta, CASOS))) +
  geom_col(fill = "#B8860B", width = 0.7) +
  geom_text(aes(label = CASOS), hjust = -0.2, size = 3.2) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(title = "15 cantones con más casos", x = "Casos", y = NULL,
       caption = nota) +
  theme_minimal(base_size = 11) +
  theme(plot.title = element_text(face = "bold"),
        panel.grid.major.y = element_blank())
g_top
ggsave(file.path(dir_salida, "04_top_cantones.png"), g_top,
       width = 7, height = 5.5, dpi = 200)

# --- 10. Exportación ---------------------------------------------------------
write.csv(sf::st_drop_geometry(m_cant[, c("dpa_canton", "canton", "provincia",
                                           "CASOS", "area_km2", "dens")]),
          file.path(dir_salida, "resumen_cantones.csv"), row.names = FALSE)
gpkg <- file.path(dir_salida, "resultados_geoecu.gpkg")
if (file.exists(gpkg)) file.remove(gpkg)
sf::st_write(sf::st_transform(m_parr, 4326), gpkg, layer = "parroquias", quiet = TRUE)
sf::st_write(sf::st_transform(m_cant, 4326), gpkg, layer = "cantones",   quiet = TRUE)
sf::st_write(sf::st_transform(m_prov, 4326), gpkg, layer = "provincias", quiet = TRUE)
cat("Archivos generados en", normalizePath(dir_salida), ":\n")
print(list.files(dir_salida))
# El GeoPackage se abre directamente en QGIS con sus tres capas.

# --- 11. Mapa interactivo (opcional) -----------------------------------------
if (requireNamespace("leaflet", quietly = TRUE)) {
  web <- sf::st_transform(m_cant, 4326)
  pal <- leaflet::colorNumeric("YlOrRd", domain = web$CASOS)
  leaflet::leaflet(web) |>
    leaflet::addProviderTiles("CartoDB.Positron") |>
    leaflet::addPolygons(
      fillColor = ~pal(CASOS), fillOpacity = 0.8, color = "white", weight = 0.6,
      label = ~paste0(canton, " (", provincia, "): ", CASOS, " casos"),
      highlightOptions = leaflet::highlightOptions(weight = 2, color = "#333",
                                                   bringToFront = TRUE)) |>
    leaflet::addLegend(pal = pal, values = ~CASOS, title = "Casos (simulados)")
} else {
  message("Para el mapa interactivo instala leaflet: install.packages('leaflet')")
}
