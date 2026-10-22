#' Leer las capas de provincias, cantones o parroquias
#'
#' Devuelven un objeto `sf` con los límites del nivel solicitado y sus códigos
#' DPA, según la Organización Territorial del Estado (CONALI). Los tres niveles
#' encajan exactamente: cada cantón es la unión de sus parroquias y cada
#' provincia la unión de sus cantones.
#'
#' Además de las circunscripciones, las capas incluyen las zonas en estudio
#' (territorios con límites aún no resueltos), identificadas en la columna
#' `tipo`, para que el mapa nacional no tenga huecos. Para excluirlas, filtra
#' `tipo != "zona en estudio"`. Las parroquias son las de la división
#' político-administrativa: cabeceras cantonales y parroquias rurales. Las
#' parroquias urbanas forman parte de su cabecera cantonal.
#'
#' La primera vez se descarga el GeoPackage de la resolución pedida y se
#' guarda en caché; las siguientes veces se lee directamente del disco.
#'
#' @param provincia Provincias a incluir, por nombre (sin importar tildes ni
#'   mayúsculas) o código: `"Loja"`, `"11"` o `11`. `NULL` (por defecto)
#'   devuelve todo el país.
#' @param canton Cantones a incluir, por nombre o código. Si un nombre se
#'   repite en varias provincias (por ejemplo, Bolívar u Olmedo), usa el
#'   código o indica también `provincia`.
#' @param tipo Solo para parroquias: `"cabecera"` (cabeceras cantonales),
#'   `"rural"` (parroquias rurales), `"zona"` (zonas en estudio) o `NULL`
#'   (todas). Se pueden combinar, por ejemplo `c("cabecera", "rural")`.
#' @param area Obsoleto. Usa `tipo`. `"rural"` equivale a
#'   `tipo = "rural"` y `"urbana"` a `tipo = "cabecera"`.
#' @param resolucion `"baja"` (por defecto; liviana, para mapas y tableros) o
#'   `"alta"` (detallada, para análisis espacial).
#' @param crs Sistema de coordenadas de salida. Por defecto WGS84
#'   (EPSG:4326). Usa `32717` (UTM 17S) para calcular áreas o distancias en
#'   metros.
#'
#' @return Un objeto `sf` de polígonos con las columnas:
#'   * `read_provincias()`: `dpa_provin`, `provincia`, `tipo`, `area_km2`.
#'   * `read_cantones()`: `dpa_canton`, `canton`, `tipo`, `dpa_provin`,
#'     `provincia`, `area_km2`.
#'   * `read_parroquias()`: `dpa_parroq`, `parroquia`, `tipo`, `dpa_canton`,
#'     `canton`, `dpa_provin`, `provincia`, `area_km2`.
#'
#'   `tipo` vale `"provincia"`, `"cantón"`, `"cabecera cantonal"` o
#'   `"parroquia rural"` según el nivel, o `"zona en estudio"`.
#' @source Organización Territorial del Estado, Comité Nacional de Límites
#'   Internos (CONALI), Ministerio de Gobierno del Ecuador. Datos abiertos,
#'   licencia CC BY: <https://www.datosabiertos.gob.ec/dataset/organizacion-territorial-parroquial>.
#'
#' @name read_dpa
#' @examplesIf geoecu_datos_disponibles()
#' provincias <- read_provincias()
#' plot(sf::st_geometry(provincias))
#'
#' # Cantones de una provincia, en UTM 17S
#' loja <- read_cantones(provincia = "Loja", crs = 32717)
#'
#' # Parroquias rurales de un cantón
#' read_parroquias(canton = "Puyango", tipo = "rural")
NULL

#' @rdname read_dpa
#' @export
read_provincias <- function(provincia = NULL, resolucion = c("baja", "alta"),
                            crs = 4326) {
  resolucion <- match.arg(resolucion)
  cod_prov <- .resolver_codigos(provincia, "provincia")
  x <- .leer_capa("provincias", resolucion)
  if (!is.null(cod_prov)) x <- x[x$dpa_provin %in% cod_prov, ]
  .finalizar(x, crs)
}

#' @rdname read_dpa
#' @export
read_cantones <- function(provincia = NULL, canton = NULL,
                          resolucion = c("baja", "alta"), crs = 4326) {
  resolucion <- match.arg(resolucion)
  cod_prov <- .resolver_codigos(provincia, "provincia")
  cod_cant <- .resolver_codigos(canton, "canton", dentro = cod_prov)
  x <- .leer_capa("cantones", resolucion)
  if (!is.null(cod_prov)) x <- x[x$dpa_provin %in% cod_prov, ]
  if (!is.null(cod_cant)) x <- x[x$dpa_canton %in% cod_cant, ]
  .finalizar(x, crs)
}

#' @rdname read_dpa
#' @export
read_parroquias <- function(provincia = NULL, canton = NULL, tipo = NULL,
                            resolucion = c("baja", "alta"), crs = 4326,
                            area = NULL) {
  resolucion <- match.arg(resolucion)
  tipo <- .resolver_tipo(tipo, area)
  cod_prov <- .resolver_codigos(provincia, "provincia")
  cod_cant <- .resolver_codigos(canton, "canton", dentro = cod_prov)
  x <- .leer_capa("parroquias", resolucion)
  if (!is.null(cod_prov)) x <- x[x$dpa_provin %in% cod_prov, ]
  if (!is.null(cod_cant)) x <- x[x$dpa_canton %in% cod_cant, ]
  if (!is.null(tipo))     x <- x[x$tipo %in% tipo, ]
  .finalizar(x, crs)
}

#' Unir datos propios con una capa geográfica
#'
#' Une una tabla (casos, tasas, coberturas, etc.) con la capa del nivel
#' indicado usando el código DPA. Los códigos se formatean automáticamente,
#' así que funciona aunque vengan como número desde Excel. Se conservan todos
#' los polígonos de la capa: los territorios sin datos quedan con `NA`, lo
#' que permite mapearlos.
#'
#' @param datos Un `data.frame` con una columna de código DPA.
#' @param codigo Nombre de la columna de `datos` que contiene el código.
#' @param nivel `"provincia"`, `"canton"` o `"parroquia"`.
#' @param ... Otros argumentos para la función `read_*()` correspondiente
#'   (por ejemplo, `provincia`, `resolucion` o `crs`).
#'
#' @return Un objeto `sf` con las columnas de la capa más las de `datos`.
#'   Si hay códigos en `datos` que no existen en la capa, se avisa con una
#'   advertencia.
#' @export
#' @examplesIf geoecu_datos_disponibles()
#' casos <- data.frame(cod = c(1101, 1102, 1103), casos = c(12, 3, 7))
#' mapa <- geoecu_unir(casos, codigo = "cod", nivel = "canton",
#'                     provincia = "Loja")
#' plot(mapa["casos"])
geoecu_unir <- function(datos, codigo, nivel = c("canton", "provincia", "parroquia"),
                        ...) {
  nivel <- match.arg(nivel)
  if (!is.data.frame(datos)) stop("`datos` debe ser un data.frame.", call. = FALSE)
  if (!codigo %in% names(datos)) {
    stop("La columna '", codigo, "' no est\u00e1 en `datos`.", call. = FALSE)
  }
  capa <- switch(nivel,
    provincia = read_provincias(...),
    canton    = read_cantones(...),
    parroquia = read_parroquias(...)
  )
  clave <- .columnas_nivel(nivel)$codigo

  if (inherits(datos, "sf")) datos <- sf::st_drop_geometry(datos)
  datos <- as.data.frame(datos)
  datos[[clave]] <- formatear_codigo(datos[[codigo]], nivel)
  if (codigo != clave) datos[[codigo]] <- NULL
  repetidas <- setdiff(intersect(names(datos), names(capa)), clave)
  if (length(repetidas)) {
    datos <- datos[, setdiff(names(datos), repetidas), drop = FALSE]
  }
  if (anyDuplicated(datos[[clave]][!is.na(datos[[clave]])])) {
    warning("Hay c\u00f3digos repetidos en `datos`: la uni\u00f3n duplicar\u00e1 pol\u00edgonos. ",
            "Agrega tus datos por c\u00f3digo antes de unir.", call. = FALSE)
  }

  sin_match <- setdiff(stats::na.omit(datos[[clave]]), capa[[clave]])
  if (length(sin_match)) {
    warning(length(sin_match), " c\u00f3digo(s) de `datos` no est\u00e1n en la capa: ",
            paste(utils::head(sin_match, 10), collapse = ", "), call. = FALSE)
  }

  res <- merge(capa, datos, by = clave, all.x = TRUE, sort = FALSE)
  res <- res[order(res[[clave]]), ]
  rownames(res) <- NULL
  sf::st_as_sf(res)
}

# --- internas ----------------------------------------------------------------

# Traduce `tipo` (y el argumento obsoleto `area`) a los valores de la columna
# `tipo` de la capa de parroquias.
.resolver_tipo <- function(tipo, area = NULL) {
  valores <- c(cabecera = "cabecera cantonal", rural = "parroquia rural",
               zona = "zona en estudio")
  if (!is.null(area)) {
    area <- match.arg(area, c("urbana", "rural"))
    warning("`area` est\u00e1 obsoleto; usa `tipo = \"",
            if (area == "rural") "rural" else "cabecera", "\"`. ",
            "Las parroquias urbanas ahora forman parte de su cabecera cantonal.",
            call. = FALSE)
    if (is.null(tipo)) tipo <- if (area == "rural") "rural" else "cabecera"
  }
  if (is.null(tipo)) return(NULL)
  tipo <- match.arg(tipo, names(valores), several.ok = TRUE)
  unname(valores[tipo])
}

.leer_capa <- function(capa, resolucion) {
  ruta <- .ruta_datos(resolucion)
  sf::st_read(ruta, layer = capa, quiet = TRUE, stringsAsFactors = FALSE)
}

.finalizar <- function(x, crs) {
  geom <- attr(x, "sf_column")
  if (geom != "geometry") {
    names(x)[names(x) == geom] <- "geometry"
    sf::st_geometry(x) <- "geometry"
  }
  if (!is.null(crs) && !isTRUE(sf::st_crs(x) == sf::st_crs(crs))) {
    x <- sf::st_transform(x, crs)
  }
  rownames(x) <- NULL
  x
}
