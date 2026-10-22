#' Normalizar nombres geográficos
#'
#' Convierte nombres a una forma comparable: mayúsculas, sin tildes ni
#' diéresis, `Ñ` como `N`, sin signos de puntuación y con espacios simples.
#' Útil para unir tablas que escriben los nombres de forma distinta
#' ("Cañar", "CANAR", "cañar ").
#'
#' @param x Vector de texto.
#' @return Vector de texto normalizado.
#' @export
#' @examples
#' normalizar_nombre(c("Cañar", "  san  José de Chimbo", "CHECA (JIDCAY)"))
normalizar_nombre <- function(x) {
  x <- as.character(x)
  latin <- !is.na(x) & Encoding(x) == "latin1"
  x[latin] <- enc2utf8(x[latin])
  # Se trabaja con puntos de codigo Unicode para que el resultado sea el mismo
  # en cualquier configuracion regional (Windows, macOS, Linux, locale "C").
  con <- c(0xe1, 0xe9, 0xed, 0xf3, 0xfa, 0xfc, 0xf1,
           0xc1, 0xc9, 0xcd, 0xd3, 0xda, 0xdc, 0xd1)
  sin <- utf8ToInt("aeiouunAEIOUUN")
  limpiar <- function(s) {
    if (is.na(s)) return(NA_character_)
    cp <- utf8ToInt(s)
    if (anyNA(cp)) cp <- utf8ToInt(iconv(s, "latin1", "UTF-8"))
    if (anyNA(cp)) return(NA_character_)
    i <- match(cp, con)
    cp[!is.na(i)] <- sin[i[!is.na(i)]]
    cp[cp > 127L] <- 32L
    intToUtf8(cp)
  }
  x <- vapply(x, limpiar, character(1), USE.NAMES = FALSE)
  x <- gsub("[^A-Za-z0-9 ]", " ", x)
  x <- toupper(x)
  x <- gsub(" +", " ", x)
  trimws(x)
}

#' Formatear códigos DPA
#'
#' Devuelve códigos DPA como texto con el número correcto de dígitos,
#' recuperando los ceros a la izquierda que se pierden cuando un código se
#' guarda como número en Excel (por ejemplo, `1101` en lugar de `"1101"`, o
#' `701` en lugar de `"0701"`).
#'
#' @param x Vector de códigos (número o texto).
#' @param nivel `"provincia"` (2 dígitos), `"canton"` (4) o `"parroquia"` (6).
#' @return Vector de texto. Los valores que no son códigos válidos se
#'   devuelven como `NA` con una advertencia.
#' @export
#' @examples
#' formatear_codigo(c(1, 11, "7"), "provincia")
#' formatear_codigo(c(701, 1101), "canton")
#' formatear_codigo(110150, "parroquia")
formatear_codigo <- function(x, nivel = c("parroquia", "canton", "provincia")) {
  nivel <- match.arg(nivel)
  ancho <- c(provincia = 2L, canton = 4L, parroquia = 6L)[[nivel]]
  original <- x
  x <- trimws(as.character(x))
  x <- sub("\\.0+$", "", x)
  invalido <- !is.na(x) & (!grepl("^[0-9]+$", x) | nchar(x) > ancho)
  x[invalido] <- NA_character_
  ok <- !is.na(x)
  x[ok] <- formatC(as.integer(x[ok]), width = ancho, flag = "0")
  if (any(invalido)) {
    warning(sum(invalido), " valor(es) no son c\u00f3digos de ", .etiqueta(nivel),
            " v\u00e1lidos y se devolvieron como NA: ",
            paste(utils::head(unique(original[invalido]), 5), collapse = ", "),
            call. = FALSE)
  }
  x
}

#' Buscar en el catálogo DPA
#'
#' Busca por nombre (sin importar tildes ni mayúsculas) o por código en el
#' catálogo [dpa].
#'
#' @param texto Texto a buscar: parte de un nombre o un código.
#' @param nivel Nivel en el que buscar: `"parroquia"`, `"canton"` o
#'   `"provincia"`.
#' @return Un `data.frame` con las coincidencias en el nivel indicado.
#' @export
#' @examples
#' buscar_dpa("arenal")
#' buscar_dpa("puyango", nivel = "canton")
#' buscar_dpa("11", nivel = "provincia")
buscar_dpa <- function(texto, nivel = c("parroquia", "canton", "provincia")) {
  nivel <- match.arg(nivel)
  tabla <- .tabla_nivel(nivel)
  cols <- .columnas_nivel(nivel)
  texto <- as.character(texto)[1]

  if (grepl("^[0-9]+$", trimws(texto))) {
    hit <- startsWith(tabla[[cols$codigo]], trimws(texto))
  } else {
    hit <- grepl(normalizar_nombre(texto), normalizar_nombre(tabla[[cols$nombre]]),
                 fixed = TRUE)
  }
  res <- tabla[hit, , drop = FALSE]
  rownames(res) <- NULL
  res
}

#' Actualizar códigos de parroquia de versiones anteriores
#'
#' Convierte códigos de parroquia de los datos de geoecu 0.3.0 y anteriores
#' (por ejemplo, de parroquias urbanas o del antiguo cantón Eloy Alfaro) al
#' código actual, usando la equivalencia principal de [dpa_equivalencias].
#' Los códigos vigentes se devuelven igual, aunque sus límites hayan cambiado.
#'
#' Cuando menos del 90 % de una parroquia anterior quedó en una sola parroquia
#' actual, se usa la de mayor superposición y se avisa: revisa
#' [dpa_equivalencias] si necesitas repartir los datos.
#'
#' @param x Vector de códigos de parroquia (número o texto).
#' @return Vector de texto con los códigos actuales. Los códigos que no
#'   existen en ninguna versión se devuelven como `NA` con una advertencia.
#' @export
#' @examples
#' # Parroquia urbana de Cuenca, Borbón (antes en Eloy Alfaro) y una sin cambios
#' actualizar_codigo(c("010101", "080253", "110152"))
#'
#' # Agregar una tabla antigua al código actual
#' casos <- data.frame(cod = c("010101", "010102", "010150"), casos = c(3, 4, 1))
#' casos$cod <- actualizar_codigo(casos$cod)
#' aggregate(casos ~ cod, data = casos, FUN = sum)
actualizar_codigo <- function(x) {
  cod <- suppressWarnings(formatear_codigo(x, "parroquia"))
  eq <- geoecu::dpa_equivalencias
  princ <- eq[eq$principal, ]
  actuales <- geoecu::dpa$dpa_parroq

  # Un código vigente se conserva aunque su territorio haya cambiado
  vigente <- cod %in% actuales
  res <- ifelse(vigente, cod, princ$dpa_parroq[match(cod, princ$dpa_parroq_anterior)])

  desconocidos <- unique(x[!is.na(cod) & is.na(res)])
  invalidos <- unique(x[!is.na(x) & is.na(cod)])
  if (length(c(desconocidos, invalidos))) {
    warning("C\u00f3digo(s) que no existen en ninguna versi\u00f3n se devolvieron como NA: ",
            paste(utils::head(c(desconocidos, invalidos), 5), collapse = ", "),
            call. = FALSE)
  }
  repartidas <- unique(cod[!vigente &
    cod %in% princ$dpa_parroq_anterior[princ$proporcion < 0.9]])
  if (length(repartidas)) {
    warning("Parroquia(s) repartida(s) entre varias actuales; se us\u00f3 la de mayor ",
            "superposici\u00f3n: ", paste(utils::head(repartidas, 5), collapse = ", "),
            ". Revisa `dpa_equivalencias`.", call. = FALSE)
  }
  unname(res)
}

# --- internas ----------------------------------------------------------------

.etiqueta <- function(nivel) {
  c(provincia = "provincia", canton = "cant\u00f3n", parroquia = "parroquia")[[nivel]]
}

.articulo <- function(nivel) {
  c(provincia = "la provincia", canton = "el cant\u00f3n",
    parroquia = "la parroquia")[[nivel]]
}

.columnas_nivel <- function(nivel) {
  switch(nivel,
    provincia = list(codigo = "dpa_provin", nombre = "provincia"),
    canton    = list(codigo = "dpa_canton", nombre = "canton"),
    parroquia = list(codigo = "dpa_parroq", nombre = "parroquia")
  )
}

.tabla_nivel <- function(nivel) {
  catalogo <- geoecu::dpa
  cols <- switch(nivel,
    provincia = c("dpa_provin", "provincia"),
    canton    = c("dpa_canton", "canton", "dpa_provin", "provincia"),
    parroquia = names(catalogo)
  )
  tabla <- unique(catalogo[, cols, drop = FALSE])
  tabla <- tabla[order(tabla[[cols[1]]]), , drop = FALSE]
  rownames(tabla) <- NULL
  tabla
}

# Convierte nombres o códigos a códigos DPA válidos del nivel indicado.
# `dentro` restringe la búsqueda a ciertas provincias (para cantones).
.resolver_codigos <- function(x, nivel, dentro = NULL) {
  if (is.null(x)) return(NULL)
  tabla <- .tabla_nivel(nivel)
  if (!is.null(dentro)) tabla <- tabla[tabla$dpa_provin %in% dentro, , drop = FALSE]
  cols <- .columnas_nivel(nivel)
  x <- as.character(x)

  codigos <- character(0)
  for (valor in x) {
    if (grepl("^\\s*[0-9]+(\\.0+)?\\s*$", valor)) {
      cod <- suppressWarnings(formatear_codigo(valor, nivel))
      if (is.na(cod) || !cod %in% tabla[[cols$codigo]]) {
        stop("No existe el c\u00f3digo de ", .etiqueta(nivel), " '", valor, "'.",
             call. = FALSE)
      }
    } else {
      hit <- normalizar_nombre(tabla[[cols$nombre]]) == normalizar_nombre(valor)
      cod <- tabla[[cols$codigo]][hit]
      if (length(cod) == 0) {
        cercanos <- unique(tabla[[cols$nombre]][agrep(
          normalizar_nombre(valor), normalizar_nombre(tabla[[cols$nombre]]),
          max.distance = 0.2)])
        stop("No se encontr\u00f3 ", .articulo(nivel), " '", valor, "'.",
             if (length(cercanos)) paste0(" \u00bfQuisiste decir: ",
               paste(utils::head(cercanos, 5), collapse = ", "), "?"),
             call. = FALSE)
      }
      if (length(cod) > 1) {
        opciones <- tabla[hit, , drop = FALSE]
        plural <- c(provincia = "provincias", canton = "cantones",
                    parroquia = "parroquias")[[nivel]]
        stop("El nombre '", valor, "' corresponde a varios/as ", plural, ": ",
             paste0(opciones[[cols$codigo]], " (", opciones$provincia, ")",
                    collapse = ", "),
             ". Usa el c\u00f3digo o filtra tambi\u00e9n por provincia.",
             call. = FALSE)
      }
    }
    codigos <- c(codigos, cod)
  }
  unique(codigos)
}
