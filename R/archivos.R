#' Carpeta de caché de geoecu
#'
#' Los GeoPackages descargados se guardan aquí para no volver a descargarlos.
#' La ubicación sigue las convenciones de cada sistema operativo
#' ([tools::R_user_dir()]).
#'
#' @return Ruta de la carpeta de caché (texto).
#' @export
#' @examples
#' geoecu_cache_dir()
geoecu_cache_dir <- function() {
  file.path(tools::R_user_dir("geoecu", which = "cache"), .geoecu_version_datos)
}

#' Borrar los datos descargados
#'
#' Elimina los GeoPackages guardados en la caché. Se volverán a descargar la
#' próxima vez que se necesiten.
#'
#' @return `TRUE` de forma invisible.
#' @export
#' @examplesIf interactive()
#' geoecu_limpiar_cache()
geoecu_limpiar_cache <- function() {
  carpeta <- tools::R_user_dir("geoecu", which = "cache")
  if (dir.exists(carpeta)) unlink(carpeta, recursive = TRUE)
  message("Cach\u00e9 de geoecu eliminada.")
  invisible(TRUE)
}

#' Usar GeoPackages desde una carpeta local
#'
#' Indica a geoecu una carpeta que contiene `geoecu_dpa_baja.gpkg` y/o
#' `geoecu_dpa_alta.gpkg`. Útil para trabajar sin conexión, en servidores
#' institucionales o con datos que aún no se han publicado.
#'
#' También puedes definir la variable de entorno `GEOECU_CARPETA` (por
#' ejemplo, en tu `.Renviron`) para que la carpeta se use siempre.
#'
#' @param carpeta Ruta a la carpeta. Usa `NULL` para volver al comportamiento
#'   por defecto (caché y descarga).
#' @return La carpeta anterior, de forma invisible.
#' @export
#' @examples
#' # Usar una carpeta propia y luego volver a la configuración anterior
#' anterior <- geoecu_usar_carpeta(tempdir())
#' geoecu_datos_disponibles()
#' geoecu_usar_carpeta(anterior)
geoecu_usar_carpeta <- function(carpeta) {
  if (!is.null(carpeta)) {
    if (!dir.exists(carpeta)) stop("No existe la carpeta: ", carpeta, call. = FALSE)
    carpeta <- normalizePath(carpeta, winslash = "/")
  }
  anterior <- getOption("geoecu.carpeta")
  options(geoecu.carpeta = carpeta)
  invisible(anterior)
}

#' ¿Están disponibles los datos sin descargar?
#'
#' Comprueba si el GeoPackage de la resolución indicada ya está en la carpeta
#' local configurada o en la caché.
#'
#' @param resolucion `"baja"` o `"alta"`.
#' @return `TRUE` o `FALSE`.
#' @export
#' @examples
#' geoecu_datos_disponibles()
geoecu_datos_disponibles <- function(resolucion = "baja") {
  resolucion <- match.arg(resolucion, .geoecu_resoluciones)
  !is.null(.ruta_local(resolucion))
}

# --- internas ----------------------------------------------------------------

.nombre_archivo <- function(resolucion) {
  paste0("geoecu_dpa_", resolucion, ".gpkg")
}

.carpeta_usuario <- function() {
  carpeta <- getOption("geoecu.carpeta")
  if (is.null(carpeta)) {
    env <- Sys.getenv("GEOECU_CARPETA", unset = "")
    if (nzchar(env)) carpeta <- env
  }
  carpeta
}

.ruta_local <- function(resolucion) {
  archivo <- .nombre_archivo(resolucion)
  carpeta <- .carpeta_usuario()
  candidatos <- c(
    if (!is.null(carpeta)) file.path(carpeta, archivo),
    file.path(geoecu_cache_dir(), archivo)
  )
  existe <- candidatos[file.exists(candidatos)]
  if (length(existe)) existe[[1]] else NULL
}

.url_datos <- function(resolucion) {
  base <- getOption(
    "geoecu.url_base",
    sprintf("https://github.com/%s/releases/download/%s",
            .geoecu_repo, .geoecu_version_datos)
  )
  paste0(sub("/$", "", base), "/", .nombre_archivo(resolucion))
}

.descargar <- function(resolucion) {
  destino_dir <- geoecu_cache_dir()
  dir.create(destino_dir, recursive = TRUE, showWarnings = FALSE)
  destino <- file.path(destino_dir, .nombre_archivo(resolucion))
  url <- .url_datos(resolucion)

  message("Descargando capas geoecu (resoluci\u00f3n ", resolucion,
          ") por \u00fanica vez...\n  ", url)
  tmp <- tempfile(fileext = ".gpkg")
  old <- options(timeout = max(600, getOption("timeout")))
  on.exit({ options(old); unlink(tmp) }, add = TRUE)

  ok <- tryCatch(
    utils::download.file(url, tmp, mode = "wb", quiet = TRUE) == 0,
    error = function(e) FALSE, warning = function(w) FALSE
  )
  if (!ok || !file.exists(tmp) || file.size(tmp) < 1000) {
    stop("No se pudieron descargar los datos desde:\n  ", url,
         "\nRevisa tu conexi\u00f3n o usa geoecu_usar_carpeta() con archivos locales.",
         call. = FALSE)
  }
  file.copy(tmp, destino, overwrite = TRUE)
  destino
}

.ruta_datos <- function(resolucion) {
  ruta <- .ruta_local(resolucion)
  if (is.null(ruta)) ruta <- .descargar(resolucion)
  ruta
}
