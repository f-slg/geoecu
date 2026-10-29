# Repositorio de GitHub donde se publican los datos como assets de un release.
# Para usar otro repositorio, cambia este valor (y las URL de DESCRIPTION y README).
.geoecu_repo <- "f-slg/geoecu"

# Etiqueta del release que contiene los GeoPackages de esta versión de datos.
.geoecu_version_datos <- "datos-v0.3.0"

# Huellas MD5 de los GeoPackages del release. Se comprueban tras cada descarga
# para detectar archivos incompletos o modificados. Se actualizan junto con
# `.geoecu_version_datos` (02_construir_datos.R las imprime).
.geoecu_md5 <- c(baja = "66e9f34f0f616ff8ee6e194f50072a31",
                 alta = "59ddf5f007f4e6a73e70069a958bc08a")

.geoecu_resoluciones <- c("baja", "alta")

.geoecu_niveles <- c(provincia = "provincias",
                     canton    = "cantones",
                     parroquia = "parroquias")
