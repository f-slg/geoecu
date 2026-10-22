# -----------------------------------------------------------------------------
# geoecu · Logo y favicons
#
# Dibuja el logo hexagonal con los datos del paquete (provincias y parroquias,
# Galápagos reubicado y línea equinoccial en su posición real) y genera los
# favicons del sitio pkgdown a partir del mismo diseño.
#
# Requisitos: geoecu, ggplot2, ragg (degradados), jsonlite (base64 del SVG) y
#             la fuente Inter instalada en el sistema.
# Uso:        Rscript data-raw/05_logo.R
# Salida:     man/figures/logo.png y pkgdown/favicon/*
# -----------------------------------------------------------------------------
library(geoecu)
library(ggplot2)
library(sf)

azul   <- "#0F2233"
azul_c <- "#1E3A57"
dorado <- "#F2B705"
fuente <- "Inter"

# --- Geometría en coordenadas del hexágono (radio 1, punta arriba) ----------
prov <- reubicar_galapagos(read_provincias(crs = 32717), separacion = 0.05)
parr <- reubicar_galapagos(read_parroquias(crs = 32717), separacion = 0.05)
marco <- marco_galapagos(prov, margen = 0.08)

caja <- st_bbox(st_union(st_geometry(prov), marco))
# El mapa ocupa la franja superior del hexágono, centrado en x
destino <- c(xmin = -0.66, xmax = 0.66, ymin = -0.22, ymax = 0.62)
escala <- min((destino[["xmax"]] - destino[["xmin"]]) / (caja[["xmax"]] - caja[["xmin"]]),
              (destino[["ymax"]] - destino[["ymin"]]) / (caja[["ymax"]] - caja[["ymin"]]))
cx <- (caja[["xmin"]] + caja[["xmax"]]) / 2
cy <- (caja[["ymin"]] + caja[["ymax"]]) / 2
dy <- (destino[["ymin"]] + destino[["ymax"]]) / 2

a_hex <- function(g) {
  g <- (st_geometry(g) - c(cx, cy)) * escala + c(0, dy)
  st_set_crs(g, NA)
}
prov_h  <- a_hex(prov)
parr_h  <- a_hex(parr)
marco_h <- a_hex(marco)
# Latitud 0 en UTM 17S: norte = 10 000 000 m
y_ecuador <- (10e6 - cy) * escala + dy

hexagono <- function(r) {
  ang <- pi / 2 + (0:5) * pi / 3
  data.frame(x = r * cos(ang), y = r * sin(ang))
}
fondo <- grid::radialGradient(c(azul_c, azul), cx1 = 0.5, cy1 = 0.55, r2 = 0.6)

logo <- function(texto = TRUE, borde = 0.055) {
  ext <- hexagono(1); int <- hexagono(1 - borde); linea <- hexagono(1 - borde - 0.025)
  ggplot() +
    geom_polygon(data = ext, aes(x, y), fill = dorado) +
    geom_polygon(data = int, aes(x, y), fill = fondo) +
    geom_polygon(data = linea, aes(x, y), fill = NA,
                 color = scales::alpha(dorado, 0.35), linewidth = 0.4) +
    annotate("segment", x = -0.84, xend = 0.84, y = y_ecuador, yend = y_ecuador,
             color = scales::alpha(dorado, 0.55), linewidth = 0.5,
             linetype = "22") +
    {if (texto) annotate("text", x = 0.76, y = y_ecuador + 0.035, label = "0°",
                         hjust = 1, vjust = 0, family = fuente,
                         color = scales::alpha(dorado, 0.75), size = 9)} +
    geom_sf(data = marco_h, fill = scales::alpha(azul, 0.6),
            color = scales::alpha("white", 0.25), linewidth = 0.5) +
    geom_sf(data = parr_h, fill = dorado, color = scales::alpha(azul, 0.35),
            linewidth = 0.12) +
    geom_sf(data = prov_h, fill = NA, color = azul, linewidth = 0.55) +
    {if (texto) annotate("text", x = 0, y = -0.47, label = "geo", hjust = 1,
                         family = fuente, color = "white", size = 52)} +
    {if (texto) annotate("text", x = 0, y = -0.47, label = "ecu", hjust = 0,
                         family = fuente, fontface = "bold", color = dorado,
                         size = 52)} +
    coord_sf(xlim = c(-0.8661, 0.8661), ylim = c(-1, 1), expand = FALSE,
             datum = NA) +
    theme_void() +
    theme(plot.background = element_rect(fill = "transparent", color = NA),
          panel.background = element_rect(fill = "transparent", color = NA))
}

guardar <- function(p, archivo, ancho, alto, escala_texto = 1) {
  ragg::agg_png(archivo, width = ancho, height = alto, background = "transparent",
                res = 72 * escala_texto)
  print(p)
  grDevices::dev.off()
}

# --- Logo ---------------------------------------------------------------------
guardar(logo(), "man/figures/logo.png", 1036, 1200)
message("Escrito: man/figures/logo.png")

# --- Favicons -------------------------------------------------------------------
# Versión sin texto (ilegible a tamaño pequeño), centrada en un cuadrado.
dir_fav <- "pkgdown/favicon"
dir.create(dir_fav, showWarnings = FALSE, recursive = TRUE)
icono <- logo(texto = FALSE, borde = 0.08) +
  coord_sf(xlim = c(-1, 1), ylim = c(-1, 1), expand = FALSE, datum = NA)
tam <- c("favicon-96x96.png" = 96, "apple-touch-icon.png" = 180,
         "web-app-manifest-192x192.png" = 192, "web-app-manifest-512x512.png" = 512)
for (f in names(tam)) {
  guardar(icono, file.path(dir_fav, f), tam[[f]], tam[[f]], escala_texto = tam[[f]] / 512)
}

# favicon.ico con imágenes PNG embebidas (formato admitido desde Windows Vista)
png_bytes <- function(n) {
  tmp <- tempfile(fileext = ".png")
  guardar(icono, tmp, n, n, escala_texto = n / 512)
  readBin(tmp, "raw", file.size(tmp))
}
ico <- function(archivo, tamanos) {
  imgs <- lapply(tamanos, png_bytes)
  con <- file(archivo, "wb"); on.exit(close(con))
  writeBin(as.integer(c(0, 1, length(imgs))), con, size = 2, endian = "little")
  offset <- 6 + 16 * length(imgs)
  for (i in seq_along(imgs)) {
    n <- tamanos[[i]] %% 256
    writeBin(as.raw(c(n, n, 0, 0)), con)
    writeBin(as.integer(c(1, 32)), con, size = 2, endian = "little")
    writeBin(as.integer(c(length(imgs[[i]]), offset)), con, size = 4, endian = "little")
    offset <- offset + length(imgs[[i]])
  }
  for (img in imgs) writeBin(img, con)
}
ico(file.path(dir_fav, "favicon.ico"), c(48, 32, 16))

# favicon.svg con la imagen PNG de 512 px embebida
b64 <- jsonlite::base64_enc(readBin(file.path(dir_fav, "web-app-manifest-512x512.png"),
                                    "raw", 1e7))
writeLines(sprintf(paste0(
  '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" ',
  'width="512" height="512" viewBox="0 0 512 512"><image width="512" height="512" ',
  'xlink:href="data:image/png;base64,%s"/></svg>'), gsub("\n", "", b64)),
  file.path(dir_fav, "favicon.svg"))

writeLines(jsonlite::toJSON(list(
  name = "geoecu", short_name = "geoecu",
  icons = list(
    list(src = "/web-app-manifest-192x192.png", sizes = "192x192",
         type = "image/png", purpose = "maskable"),
    list(src = "/web-app-manifest-512x512.png", sizes = "512x512",
         type = "image/png", purpose = "maskable")),
  theme_color = azul, background_color = "#ffffff", display = "standalone"),
  auto_unbox = TRUE, pretty = TRUE), file.path(dir_fav, "site.webmanifest"))
message("Escritos los favicons en ", dir_fav)
