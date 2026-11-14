# Pruebas de la cach\u00e9 y la descarga que no necesitan internet: usan una
# cach\u00e9 temporal y una "fuente" local con `geoecu.url_base`.

cache_temporal <- function(env = parent.frame()) {
  carpeta <- tempfile("geoecu-cache-")
  dir.create(carpeta)
  anterior <- Sys.getenv("R_USER_CACHE_DIR", unset = NA)
  Sys.setenv(R_USER_CACHE_DIR = carpeta)
  do.call(on.exit, list(substitute({
    if (is.na(anterior)) Sys.unsetenv("R_USER_CACHE_DIR") else
      Sys.setenv(R_USER_CACHE_DIR = anterior)
    unlink(carpeta, recursive = TRUE)
  }, list(anterior = anterior, carpeta = carpeta)), add = TRUE), envir = env)
  carpeta
}

fuente_local <- function(env = parent.frame()) {
  carpeta <- tempfile("geoecu-fuente-")
  dir.create(carpeta)
  writeBin(as.raw(rep(1:50, 40)), file.path(carpeta, "geoecu_dpa_baja.gpkg"))
  ruta <- normalizePath(carpeta, winslash = "/")
  url <- paste0(if (startsWith(ruta, "/")) "file://" else "file:///", ruta)
  anterior <- options(geoecu.url_base = url)
  do.call(on.exit, list(substitute({
    options(anterior)
    unlink(carpeta, recursive = TRUE)
  }, list(anterior = anterior, carpeta = carpeta)), add = TRUE), envir = env)
  carpeta
}

test_that("la URL de los datos respeta geoecu.url_base", {
  anterior <- options(geoecu.url_base = NULL)
  on.exit(options(anterior), add = TRUE)
  expect_match(geoecu:::.url_datos("alta"),
               "^https://github.com/f-slg/geoecu/releases/download/datos-v[0-9.]+/geoecu_dpa_alta.gpkg$")
  options(geoecu.url_base = "https://ejemplo.org/datos/")
  expect_equal(geoecu:::.url_datos("baja"),
               "https://ejemplo.org/datos/geoecu_dpa_baja.gpkg")
})

test_that("geoecu_usar_carpeta valida la carpeta y devuelve la anterior", {
  inicial <- getOption("geoecu.carpeta")
  on.exit(options(geoecu.carpeta = inicial), add = TRUE)
  expect_error(geoecu_usar_carpeta(file.path(tempdir(), "no-existe-geoecu")),
               "No existe la carpeta")
  geoecu_usar_carpeta(tempdir())
  expect_equal(geoecu_usar_carpeta(NULL), normalizePath(tempdir(), winslash = "/"))
  expect_null(getOption("geoecu.carpeta"))
})

test_that("la descarga guarda el archivo en la cach\u00e9 sin dejar temporales", {
  cache_temporal()
  fuente <- fuente_local()
  anterior <- options(geoecu.carpeta = NULL)
  on.exit(options(anterior), add = TRUE)
  env <- Sys.getenv("GEOECU_CARPETA", unset = NA)
  Sys.unsetenv("GEOECU_CARPETA")
  on.exit(if (!is.na(env)) Sys.setenv(GEOECU_CARPETA = env), add = TRUE)

  expect_false(geoecu_datos_disponibles("baja"))
  expect_message(destino <- geoecu:::.descargar("baja"), "Descargando")
  expect_equal(destino, file.path(geoecu_cache_dir(), "geoecu_dpa_baja.gpkg"))
  expect_true(geoecu_datos_disponibles("baja"))
  expect_equal(list.files(geoecu_cache_dir()), "geoecu_dpa_baja.gpkg")
  expect_identical(unname(tools::md5sum(destino)),
                   unname(tools::md5sum(file.path(fuente, "geoecu_dpa_baja.gpkg"))))
  # Ya está en caché: no se vuelve a descargar
  expect_no_message(expect_equal(geoecu:::.ruta_datos("baja"), destino))

  expect_message(geoecu_limpiar_cache(), "eliminada")
  expect_false(geoecu_datos_disponibles("baja"))
  expect_length(ls(geoecu:::.cache_verificada, all.names = TRUE), 0L)
})

test_that("la descarga falla con un mensaje claro si la fuente no existe", {
  cache_temporal()
  anterior <- options(geoecu.url_base = paste0("file://", tempfile("no-existe-")))
  on.exit(options(anterior), add = TRUE)
  expect_error(suppressMessages(geoecu:::.descargar("baja")),
               "No se pudieron descargar")
  expect_equal(length(list.files(geoecu_cache_dir())), 0L)
})

test_that("un archivo de cach\u00e9 que no es el oficial se detecta", {
  falso <- tempfile(fileext = ".gpkg")
  writeLines("no es un GeoPackage", falso)
  on.exit(unlink(falso), add = TRUE)
  anterior <- options(geoecu.url_base = NULL)
  on.exit(options(anterior), add = TRUE)
  expect_false(geoecu:::.cache_integra(falso, "baja"))
  # Con otra fuente configurada no hay huella que comparar
  options(geoecu.url_base = "https://ejemplo.org")
  expect_true(geoecu:::.cache_integra(falso, "baja"))
})

test_that("una cach\u00e9 da\u00f1ada se repara descargando de nuevo", {
  skip_on_cran()
  skip_if_offline("github.com")
  cache_temporal()
  anterior <- options(geoecu.url_base = NULL, geoecu.carpeta = NULL)
  on.exit(options(anterior), add = TRUE)
  env <- Sys.getenv("GEOECU_CARPETA", unset = NA)
  Sys.unsetenv("GEOECU_CARPETA")
  on.exit(if (!is.na(env)) Sys.setenv(GEOECU_CARPETA = env), add = TRUE)

  dir.create(geoecu_cache_dir(), recursive = TRUE)
  ruta <- file.path(geoecu_cache_dir(), "geoecu_dpa_baja.gpkg")
  writeLines("descarga interrumpida", ruta)
  expect_message(x <- read_provincias(), "se descarga de nuevo")
  expect_equal(nrow(x), 25)
  expect_identical(unname(tools::md5sum(ruta)), unname(geoecu:::.geoecu_md5[["baja"]]))
})
