#' Catálogo de la División Político-Administrativa (DPA) del Ecuador
#'
#' Una fila por parroquia, con sus códigos y nombres en los tres niveles.
#' Sirve para buscar códigos, validar tablas antes de unirlas con las capas o
#' agregar datos parroquiales a cantón o provincia sin necesidad de geometrías.
#'
#' Incluye 1048 parroquias (223 cabeceras cantonales y 825 parroquias rurales)
#' de 223 cantones y 24 provincias, más 3 zonas en estudio (territorios con
#' límites aún no resueltos): Jaramijó-Manta (código `"139090"`),
#' Sinaí-Cuchaentza (`"140190"`) y Juval (`"900651"`, provincia `"90"`). Las
#' parroquias urbanas forman parte de su cabecera cantonal.
#'
#' @format Un `data.frame` con 1051 filas y 7 columnas:
#' \describe{
#'   \item{dpa_parroq}{Código DPA de la parroquia (6 dígitos, texto).}
#'   \item{parroquia}{Nombre de la parroquia, en mayúsculas.}
#'   \item{tipo}{`"cabecera cantonal"`, `"parroquia rural"` o
#'     `"zona en estudio"`.}
#'   \item{dpa_canton}{Código DPA del cantón (4 dígitos, texto).}
#'   \item{canton}{Nombre del cantón.}
#'   \item{dpa_provin}{Código DPA de la provincia (2 dígitos, texto).}
#'   \item{provincia}{Nombre de la provincia.}
#' }
#'
#' @source Organización Territorial del Estado, Comité Nacional de Límites
#'   Internos (CONALI), Ministerio de Gobierno del Ecuador, versión del 17 de
#'   julio de 2026. Datos abiertos, licencia CC BY:
#'   <https://www.datosabiertos.gob.ec/dataset/organizacion-territorial-parroquial>.
#'   Ver `data-raw/` en el repositorio para el procesamiento completo.
#'
#' @seealso [dpa_equivalencias] para actualizar códigos de versiones
#'   anteriores de geoecu.
#' @examples
#' head(dpa)
#' # Número de parroquias por provincia
#' table(dpa$provincia)
"dpa"

#' Equivalencias con los códigos de parroquia de versiones anteriores
#'
#' Relaciona los códigos de parroquia de los datos de geoecu 0.3.0 y
#' anteriores (release `datos-v0.1.0`) con los de la versión actual, según la
#' superposición de sus áreas. Útil para actualizar tablas codificadas con la
#' versión anterior; para hacerlo directamente, usa [actualizar_codigo()].
#'
#' Los cambios principales son: las parroquias urbanas pasan a formar parte
#' de su cabecera cantonal; las parroquias del nuevo cantón Borbón (antes en
#' Eloy Alfaro) y la cabecera de Sevilla Don Bosco cambian de código; y
#' algunas parroquias cambian de límites o se integran en otras.
#'
#' Una parroquia anterior puede repartirse entre varias actuales: hay una fila
#' por cada parte que cubre al menos el 1 % de su área, y `principal` marca la
#' de mayor superposición.
#'
#' @format Un `data.frame` con 7 columnas:
#' \describe{
#'   \item{dpa_parroq_anterior}{Código de la parroquia en la versión anterior.}
#'   \item{parroquia_anterior}{Nombre en la versión anterior.}
#'   \item{dpa_parroq}{Código de la parroquia actual.}
#'   \item{parroquia}{Nombre de la parroquia actual.}
#'   \item{proporcion}{Proporción del área de la parroquia anterior que cae
#'     en la actual (0 a 1).}
#'   \item{principal}{`TRUE` en la parroquia actual con mayor superposición.}
#'   \item{cambio}{`"sin cambio"`, `"integrada en la cabecera cantonal"` o
#'     `"código distinto"`.}
#' }
#'
#' @source Elaborado en `data-raw/04_equivalencias.R` a partir de las capas
#'   de alta resolución de ambas versiones.
#'
#' @examples
#' # Parroquias que cambiaron de código
#' subset(dpa_equivalencias, principal & cambio == "código distinto")
"dpa_equivalencias"
