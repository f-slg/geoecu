# Pruebas contra el GeoPackage detallado oficial.
# En CRAN / máquinas sin datos se omiten para evitar descargas implícitas.
skip_if_not(geoecu_datos_disponibles("baja") &&
            geoecu_datos_disponibles("alta"),
            "Se requieren ambas resoluciones en caché o GEOECU_CARPETA")

test_that("baja y alta tienen los mismos códigos y atributos básicos", {
  niveles <- list(
    list(fn = read_provincias, clave = "dpa_provin", n = 25L),
    list(fn = read_cantones, clave = "dpa_canton", n = 225L),
    list(fn = read_parroquias, clave = "dpa_parroq", n = 1051L)
  )

  for (nivel in niveles) {
    baja <- nivel$fn(resolucion = "baja")
    alta <- nivel$fn(resolucion = "alta")

    expect_s3_class(alta, "sf")
    expect_equal(nrow(baja), nivel$n)
    expect_equal(nrow(alta), nivel$n)
    expect_identical(names(alta), names(baja))
    expect_setequal(baja[[nivel$clave]], alta[[nivel$clave]])
    expect_equal(sf::st_crs(alta)$epsg, 4326L)
    expect_true(all(sf::st_is_valid(alta)))

    for (campo in c("tipo", "dpa_provin")) {
      if (campo %in% names(alta)) {
        expect_equal(
          alta[[campo]][match(baja[[nivel$clave]], alta[[nivel$clave]])],
          baja[[campo]]
        )
      }
    }
  }
})

test_that("la resolución alta filtra Loja y Puyango y admite reproyección", {
  c <- read_cantones(provincia = "Loja", resolucion = "alta", crs = 32717)
  p <- read_parroquias(provincia = "Loja", resolucion = "alta", crs = 32717)
  puyango <- read_parroquias(canton = "Puyango", resolucion = "alta")

  expect_equal(nrow(c), 16L)
  expect_equal(nrow(p), 94L)
  expect_equal(nrow(puyango), 6L)
  expect_equal(sf::st_crs(c)$epsg, 32717L)
  expect_true(all(sf::st_is_valid(p)))
})

test_that("geoecu_unir conserva los cantones también en alta resolución", {
  conteo <- as.data.frame(table(dpa$dpa_canton), stringsAsFactors = FALSE)
  names(conteo) <- c("codigo", "n_parroquias")
  m <- geoecu_unir(conteo, codigo = "codigo", nivel = "canton",
                   resolucion = "alta", crs = 32717)

  expect_equal(nrow(m), 225L)
  expect_equal(anyDuplicated(m$dpa_canton), 0L)
  expect_false(anyNA(m$n_parroquias))
  expect_true(all(sf::st_is_valid(m)))
  expect_equal(sf::st_crs(m)$epsg, 32717L)
})

test_that("un archivo local que no es GeoPackage no se interpreta como mapa", {
  carpeta <- tempfile("geoecu-corrupto-")
  dir.create(carpeta)
  writeLines("Archivo de prueba: datos no válidos",
             file.path(carpeta, "geoecu_dpa_baja.gpkg"),
             useBytes = TRUE)

  anterior <- geoecu_usar_carpeta(carpeta)
  on.exit(geoecu_usar_carpeta(anterior), add = TRUE)
  on.exit(unlink(carpeta, recursive = TRUE), add = TRUE)

  expect_error(read_provincias(resolucion = "baja"))
})

test_that("los assets oficiales descargados por CI mantienen su checksum", {
  skip_if(Sys.getenv("GEOECU_VERIFICAR_RELEASE") != "1",
          "Verificación de release reservada al workflow de CI")
  carpeta <- Sys.getenv("GEOECU_CARPETA", unset = "")
  expect_true(nzchar(carpeta))
  for (resolucion in c("baja", "alta")) {
    ruta <- file.path(carpeta, paste0("geoecu_dpa_", resolucion, ".gpkg"))
    expect_true(file.exists(ruta))
    expect_identical(unname(tools::md5sum(ruta)),
                     unname(geoecu:::.geoecu_md5[[resolucion]]))
  }
})
