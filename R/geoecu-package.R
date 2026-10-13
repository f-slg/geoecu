#' geoecu: capas geográficas de la DPA del Ecuador
#'
#' Provincias, cantones y parroquias del Ecuador con códigos DPA,
#' listos para mapear y unir con datos propios.
#'
#' ## Funciones principales
#'
#' * [read_provincias()], [read_cantones()] y [read_parroquias()] devuelven
#'   objetos `sf` con los límites de cada nivel.
#' * [geoecu_unir()] une una tabla propia (por ejemplo, casos o tasas) con la
#'   capa correspondiente usando el código DPA.
#' * [dpa] es el catálogo de códigos y nombres; [buscar_dpa()] busca en él.
#' * [formatear_codigo()] y [normalizar_nombre()] limpian códigos y nombres
#'   antes de unir tablas.
#'
#' ## Datos
#'
#' Las geometrías no vienen dentro del paquete: se descargan la primera vez
#' desde los releases del repositorio en GitHub y se guardan en caché
#' ([geoecu_cache_dir()]). También puedes usar archivos locales con
#' [geoecu_usar_carpeta()].
#'
#' @keywords internal
"_PACKAGE"
