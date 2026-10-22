# Repositorio de GitHub donde se publican los datos como assets de un release.
# Para usar otro repositorio, cambia este valor (y las URL de DESCRIPTION y README).
.geoecu_repo <- "f-slg/geoecu"

# Etiqueta del release que contiene los GeoPackages de esta versión de datos.
.geoecu_version_datos <- "datos-v0.2.0"

# Huellas MD5 de los GeoPackages del release. Se comprueban tras cada descarga
# para detectar archivos incompletos o modificados. Se actualizan junto con
# `.geoecu_version_datos` (02_construir_datos.R las imprime).
.geoecu_md5 <- c(baja = "b57cc807151b57c86cbef13c07c1d8dc",
                 alta = "d7b884ec3ded05ee1c7d6dc0df5fb6c9")

.geoecu_resoluciones <- c("baja", "alta")

.geoecu_niveles <- c(provincia = "provincias",
                     canton    = "cantones",
                     parroquia = "parroquias")
