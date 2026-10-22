#' Reubicar Galápagos junto al continente para mapas nacionales
#'
#' Traslada las islas Galápagos (provincia `"20"`) a la esquina superior
#' izquierda del mapa, junto al Ecuador continental, como se hace en la
#' cartografía nacional para no desperdiciar espacio. Funciona con cualquier
#' capa de geoecu (provincias, cantones o parroquias) y con capas unidas con
#' [geoecu_unir()], porque usa la columna `dpa_provin`.
#'
#' El traslado es **solo para visualizar**: no uses el resultado para medir
#' áreas o distancias de Galápagos. Si reubicas varias capas para superponerlas
#' (por ejemplo, parroquias y límites provinciales), todas quedan alineadas
#' porque comparten la misma geometría de origen.
#'
#' @param x Objeto `sf` de geoecu con la columna `dpa_provin` y polígonos del
#'   continente y de Galápagos. Se recomienda un sistema proyectado, como UTM
#'   17S (`crs = 32717`).
#' @param separacion Separación entre Galápagos y el continente, como
#'   proporción del ancho del Ecuador continental. Por defecto `0.06`.
#'
#' @return El mismo objeto `sf`, con Galápagos trasladado. Si `x` no contiene
#'   Galápagos o no contiene el continente, se devuelve sin cambios.
#' @seealso [marco_galapagos()] para dibujar el recuadro.
#' @export
#' @examplesIf geoecu_datos_disponibles() && requireNamespace("ggplot2", quietly = TRUE)
#' library(ggplot2)
#' prov <- reubicar_galapagos(read_provincias(crs = 32717))
#' ggplot(prov) +
#'   geom_sf() +
#'   geom_sf(data = marco_galapagos(prov), fill = NA, color = "grey70") +
#'   theme_void()
reubicar_galapagos <- function(x, separacion = 0.06) {
  if (!inherits(x, "sf") || !"dpa_provin" %in% names(x)) {
    stop("`x` debe ser un objeto sf de geoecu con la columna `dpa_provin`.",
         call. = FALSE)
  }
  es_gal <- x$dpa_provin == "20"
  if (!any(es_gal) || all(es_gal)) {
    message("La capa no contiene Gal\u00e1pagos y el continente a la vez; ",
            "se devuelve sin cambios.")
    return(x)
  }
  if (isTRUE(attr(x, "galapagos_reubicado"))) return(x)

  cont <- sf::st_bbox(x[!es_gal, ])
  gal  <- sf::st_bbox(x[es_gal, ])
  ancho_cont <- cont[["xmax"]] - cont[["xmin"]]
  ancho_gal  <- gal[["xmax"]] - gal[["xmin"]]
  alto_gal   <- gal[["ymax"]] - gal[["ymin"]]

  # Esquina superior izquierda: borde superior de Galápagos alineado con el
  # extremo norte del continente, a la izquierda de la costa.
  destino <- c(cont[["xmin"]] - separacion * ancho_cont - ancho_gal / 2,
               cont[["ymax"]] - alto_gal / 2)
  origen  <- c((gal[["xmin"]] + gal[["xmax"]]) / 2,
               (gal[["ymin"]] + gal[["ymax"]]) / 2)

  crs <- sf::st_crs(x)
  geom <- sf::st_geometry(x)
  geom[es_gal] <- geom[es_gal] + (destino - origen)
  sf::st_geometry(x) <- sf::st_set_crs(geom, crs)
  attr(x, "galapagos_reubicado") <- TRUE
  x
}

#' Recuadro para Galápagos reubicado
#'
#' Devuelve un rectángulo alrededor de Galápagos, pensado para dibujarlo como
#' un recuadro tenue después de [reubicar_galapagos()].
#'
#' @param x Objeto `sf` de geoecu, normalmente ya pasado por
#'   [reubicar_galapagos()].
#' @param margen Margen alrededor de las islas, como proporción del ancho del
#'   archipiélago. Por defecto `0.06`.
#'
#' @return Un objeto `sfc` con un polígono, en el mismo sistema de coordenadas
#'   que `x`.
#' @export
#' @examplesIf geoecu_datos_disponibles()
#' prov <- reubicar_galapagos(read_provincias(crs = 32717))
#' marco_galapagos(prov)
marco_galapagos <- function(x, margen = 0.06) {
  if (!inherits(x, "sf") || !"dpa_provin" %in% names(x)) {
    stop("`x` debe ser un objeto sf de geoecu con la columna `dpa_provin`.",
         call. = FALSE)
  }
  es_gal <- x$dpa_provin == "20"
  if (!any(es_gal)) stop("La capa no contiene Gal\u00e1pagos.", call. = FALSE)
  bb <- sf::st_bbox(x[es_gal, ])
  m <- margen * (bb[["xmax"]] - bb[["xmin"]])
  caja <- c(xmin = bb[["xmin"]] - m, ymin = bb[["ymin"]] - m,
            xmax = bb[["xmax"]] + m, ymax = bb[["ymax"]] + m)
  sf::st_as_sfc(sf::st_bbox(caja, crs = sf::st_crs(x)))
}
