#' Catálogo de la División Político-Administrativa (DPA) del Ecuador
#'
#' Una fila por parroquia, con sus códigos y nombres en los tres niveles.
#' Sirve para buscar códigos, validar tablas antes de unirlas con las capas o
#' agregar datos parroquiales a cantón o provincia sin necesidad de geometrías.
#'
#' @format Un `data.frame` con 1262 filas y 7 columnas:
#' \describe{
#'   \item{dpa_parroq}{Código DPA de la parroquia (6 dígitos, texto).}
#'   \item{parroquia}{Nombre de la parroquia, en mayúsculas.}
#'   \item{area_dpa}{`"urbana"` (sufijo de código <= 50, incluye cabeceras
#'     cantonales) o `"rural"` (sufijo > 50).}
#'   \item{dpa_canton}{Código DPA del cantón (4 dígitos, texto).}
#'   \item{canton}{Nombre del cantón.}
#'   \item{dpa_provin}{Código DPA de la provincia (2 dígitos, texto).}
#'   \item{provincia}{Nombre de la provincia.}
#' }
#'
#' @source Cartografía de libre acceso del Geoportal del Instituto Geográfico
#'   Militar (IGM) del Ecuador. Ver `data-raw/` en el repositorio para el
#'   procesamiento completo.
#'
#' @examples
#' head(dpa)
#' # Número de parroquias por provincia
#' table(dpa$provincia)
"dpa"
