# -----------------------------------------------------------------------------
# geoecu · Paso 2: atributos, GeoPackages de publicación y catálogo DPA
#
# Toma la salida de 01_simplificar.sh y genera:
#   - geoecu_dpa_alta.gpkg y geoecu_dpa_baja.gpkg  (assets del release de GitHub)
#   - data/dpa.rda                                  (catálogo incluido en el paquete)
#
# Uso: Rscript data-raw/02_construir_datos.R [carpeta_salida_release]
# -----------------------------------------------------------------------------
library(sf)

args <- commandArgs(trailingOnly = TRUE)
dir_release <- if (length(args)) args[[1]] else "data-raw/release"
dir.create(dir_release, showWarnings = FALSE, recursive = TRUE)
dir_build <- "data-raw/build"

leer <- function(res, capa) {
  x <- st_read(file.path(dir_build, res, paste0(capa, ".json")), quiet = TRUE)
  st_crs(x) <- 4326
  x
}

renombrar <- function(x) {
  mapa <- c(DPA_PROVIN = "dpa_provin", DPA_DESPRO = "provincia",
            DPA_CANTON = "dpa_canton", DPA_DESCAN = "canton",
            DPA_PARROQ = "dpa_parroq", DPA_DESPAR = "parroquia")
  nm <- names(x)
  names(x)[nm %in% names(mapa)] <- mapa[nm[nm %in% names(mapa)]]
  x
}

# Área sobre el elipsoide WGS84 con una proyección de igual área (EPSG:6933,
# Lambert cilíndrica elipsoidal). UTM 17S no conserva áreas: infla Galápagos
# (huso 15) en ~3 % y la Amazonía oriental hasta ~0,6 %. Tampoco se usa s2,
# que calcula sobre una esfera y sobreestima ~0,45 % en el ecuador.
area_km2 <- function(x) {
  round(as.numeric(st_area(st_transform(x, 6933))) / 1e6, 3)
}

texto_utf8 <- function(x) {
  for (v in names(x)) if (is.character(x[[v]])) x[[v]] <- enc2utf8(x[[v]])
  x
}

# Tipo de circunscripción según el campo `txt` de la capa de origen.
# "NO APLICA" corresponde a la zona en estudio Jaramijó-Manta.
tipo_parroquia <- function(txt) {
  tipo <- c("CABECERA CANTONAL" = "cabecera cantonal",
            "PARROQUIA RURAL"   = "parroquia rural",
            "ZONA EN ESTUDIO"   = "zona en estudio",
            "NO APLICA"         = "zona en estudio")[txt]
  if (anyNA(tipo)) stop("Valores de `txt` no previstos: ",
                        paste(unique(txt[is.na(tipo)]), collapse = ", "))
  unname(tipo)
}

# Las zonas en estudio llevan "ZONA EN ESTUDIO" en el nombre en la capa de origen
tipo_nivel <- function(nombre, normal) {
  ifelse(grepl("ZONA EN ESTUDIO", nombre, fixed = TRUE), "zona en estudio", normal)
}

# Las áreas se calculan una sola vez, sobre la versión de alta resolución
areas <- list()

for (res in c("alta", "baja")) {
  prov <- renombrar(leer(res, "provincias"))
  cant <- renombrar(leer(res, "cantones"))
  parr <- renombrar(leer(res, "parroquias"))

  parr$tipo <- tipo_parroquia(parr$txt)
  cant$tipo <- tipo_nivel(cant$canton, "cantón")
  prov$tipo <- tipo_nivel(prov$provincia, "provincia")

  if (res == "alta") {
    areas$prov <- setNames(area_km2(prov), prov$dpa_provin)
    areas$cant <- setNames(area_km2(cant), cant$dpa_canton)
    areas$parr <- setNames(area_km2(parr), parr$dpa_parroq)
  }
  prov$area_km2 <- unname(areas$prov[prov$dpa_provin])
  cant$area_km2 <- unname(areas$cant[cant$dpa_canton])
  parr$area_km2 <- unname(areas$parr[parr$dpa_parroq])

  prov <- prov[order(prov$dpa_provin), c("dpa_provin", "provincia", "tipo", "area_km2")]
  cant <- cant[order(cant$dpa_canton),
               c("dpa_canton", "canton", "tipo", "dpa_provin", "provincia", "area_km2")]
  parr <- parr[order(parr$dpa_parroq),
               c("dpa_parroq", "parroquia", "tipo", "dpa_canton", "canton",
                 "dpa_provin", "provincia", "area_km2")]

  capas <- list(provincias = prov, cantones = cant, parroquias = parr)
  destino <- file.path(dir_release, paste0("geoecu_dpa_", res, ".gpkg"))
  if (file.exists(destino)) file.remove(destino)
  for (nm in names(capas)) {
    capa <- texto_utf8(st_make_valid(capas[[nm]]))
    st_write(capa, destino, layer = nm, quiet = TRUE)
  }
  message("Escrito: ", destino, " (md5 ", unname(tools::md5sum(destino)), ")")

  if (res == "baja") {
    dpa <- texto_utf8(st_drop_geometry(parr))
    dpa$area_km2 <- NULL
    rownames(dpa) <- NULL
    save(dpa, file = "data/dpa.rda", compress = "xz")
    message("Escrito: data/dpa.rda (", nrow(dpa), " filas)")
  }
}
