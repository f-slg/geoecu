# Estas pruebas necesitan los GeoPackages. Se ejecutan si ya están en caché o
# si la variable de entorno GEOECU_CARPETA apunta a una carpeta que los tenga.
skip_if_not(geoecu_datos_disponibles("baja"), "Datos geoecu no disponibles")

test_that("read_* devuelven el n\u00famero correcto de elementos", {
  expect_equal(nrow(read_provincias()), 25)
  expect_equal(nrow(read_cantones()), 225)
  expect_equal(nrow(read_parroquias()), 1051)
  expect_equal(sum(read_provincias()$tipo == "provincia"), 24)
  expect_equal(sum(read_cantones()$tipo == "cant\u00f3n"), 223)
})

test_that("las capas son sf en WGS84 con las columnas esperadas", {
  x <- read_cantones()
  expect_s3_class(x, "sf")
  expect_equal(sf::st_crs(x)$epsg, 4326L)
  expect_equal(names(x),
               c("dpa_canton", "canton", "tipo", "dpa_provin", "provincia",
                 "area_km2", "geometry"))
  expect_true(all(sf::st_is_valid(x)))
})

test_that("los filtros funcionan por nombre, c\u00f3digo y tipo", {
  expect_equal(nrow(read_provincias("Loja")), 1)
  expect_equal(unique(read_cantones(provincia = 11)$provincia), "LOJA")
  p <- read_parroquias(canton = "Puyango", tipo = "rural")
  expect_true(all(p$dpa_canton == "1110"))
  expect_true(all(p$tipo == "parroquia rural"))
  expect_equal(nrow(read_parroquias(tipo = "zona")), 3)
  expect_equal(nrow(read_parroquias(tipo = c("cabecera", "rural"))), 1048)
  expect_warning(a <- read_parroquias(canton = "Puyango", area = "rural"), "obsoleto")
  expect_equal(nrow(a), nrow(p))
})

test_that("crs transforma la salida", {
  x <- read_provincias("Galapagos", crs = 32717)
  expect_equal(sf::st_crs(x)$epsg, 32717L)
})

test_that("geoecu_unir une por c\u00f3digo y conserva todos los pol\u00edgonos", {
  datos <- data.frame(cod = c(1101, 1110), casos = c(10, 2))
  m <- geoecu_unir(datos, "cod", "canton", provincia = "Loja")
  expect_s3_class(m, "sf")
  expect_equal(nrow(m), nrow(read_cantones(provincia = "Loja")))
  expect_equal(m$casos[m$dpa_canton == "1110"], 2)
  expect_true(any(is.na(m$casos)))
  expect_warning(geoecu_unir(data.frame(cod = 9999, x = 1), "cod", "canton"),
                 "no est\u00e1n en la capa")
})

test_that("la descarga rechaza archivos que no coinciden con la huella", {
  skip_on_cran()
  skip_if_offline("github.com")
  carpeta <- tempfile(); dir.create(carpeta)
  withr_cache <- Sys.getenv("R_USER_CACHE_DIR")
  Sys.setenv(R_USER_CACHE_DIR = carpeta)
  on.exit(Sys.setenv(R_USER_CACHE_DIR = withr_cache), add = TRUE)
  md5 <- geoecu:::.geoecu_md5
  assignInNamespace(".geoecu_md5", c(baja = "0", alta = "0"), "geoecu")
  on.exit(assignInNamespace(".geoecu_md5", md5, "geoecu"), add = TRUE)
  expect_error(geoecu:::.descargar("baja"), "no coincide")
})
