# -----------------------------------------------------------------------------
# geoecu · Paso 4: equivalencias entre códigos de parroquia
#
# Relaciona cada parroquia de los datos anteriores (release datos-v0.1.0) con
# las parroquias de la versión actual, según la superposición de sus áreas.
# Sirve para actualizar tablas que usan los códigos anteriores (por ejemplo,
# parroquias urbanas, que ahora forman parte de la cabecera cantonal, o las
# parroquias del nuevo cantón Borbón).
#
# Requiere:
#   - data-raw/insumos/geoecu_datos-v0.1.0/geoecu_dpa_alta.gpkg
#     (descargable desde el release datos-v0.1.0)
#   - data-raw/release/geoecu_dpa_alta.gpkg (salida de 02_construir_datos.R)
#
# Salida: data/dpa_equivalencias.rda
# Uso:    Rscript data-raw/04_equivalencias.R
# -----------------------------------------------------------------------------
library(sf)
sf_use_s2(FALSE)

anterior <- st_read("data-raw/insumos/geoecu_datos-v0.1.0/geoecu_dpa_alta.gpkg",
                    "parroquias", quiet = TRUE)
actual <- st_read("data-raw/release/geoecu_dpa_alta.gpkg", "parroquias", quiet = TRUE)

anterior <- st_transform(anterior[c("dpa_parroq", "parroquia", "area_dpa")], 32717)
actual <- st_transform(actual[c("dpa_parroq", "parroquia", "tipo")], 32717)
names(anterior)[1:3] <- c("dpa_parroq_anterior", "parroquia_anterior", "area_anterior")

anterior$km2_anterior <- as.numeric(st_area(anterior)) / 1e6
inter <- st_intersection(anterior, actual)
inter$km2 <- as.numeric(st_area(inter)) / 1e6
inter <- st_drop_geometry(inter)
inter$proporcion <- inter$km2 / inter$km2_anterior

# Se descartan astillas por diferencias de trazado (< 1 % del área anterior),
# salvo que sean la única coincidencia de la parroquia anterior.
inter <- inter[order(inter$dpa_parroq_anterior, -inter$proporcion), ]
inter$principal <- !duplicated(inter$dpa_parroq_anterior)
inter <- inter[inter$principal | inter$proporcion >= 0.01, ]

inter$cambio <- with(inter, ifelse(
  dpa_parroq_anterior == dpa_parroq, "sin cambio",
  ifelse(area_anterior == "urbana" & tipo == "cabecera cantonal" &
           substr(dpa_parroq_anterior, 1, 4) == substr(dpa_parroq, 1, 4),
         "integrada en la cabecera cantonal", "código distinto")))

dpa_equivalencias <- data.frame(
  dpa_parroq_anterior = inter$dpa_parroq_anterior,
  parroquia_anterior  = enc2utf8(inter$parroquia_anterior),
  dpa_parroq          = inter$dpa_parroq,
  parroquia           = enc2utf8(inter$parroquia),
  proporcion          = round(inter$proporcion, 3),
  principal           = inter$principal,
  cambio              = enc2utf8(inter$cambio),
  stringsAsFactors = FALSE
)
rownames(dpa_equivalencias) <- NULL

stopifnot(setequal(dpa_equivalencias$dpa_parroq_anterior[dpa_equivalencias$principal],
                   anterior$dpa_parroq_anterior))
save(dpa_equivalencias, file = "data/dpa_equivalencias.rda", compress = "xz")
message("Escrito: data/dpa_equivalencias.rda (", nrow(dpa_equivalencias), " filas)")
print(table(dpa_equivalencias$cambio[dpa_equivalencias$principal]))
