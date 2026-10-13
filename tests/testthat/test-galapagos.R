skip_if_not(geoecu_datos_disponibles("baja"), "Datos geoecu no disponibles")

test_that("reubicar_galapagos traslada solo Galapagos, a la izquierda y arriba", {
  prov <- read_provincias(crs = 32717)
  mov <- reubicar_galapagos(prov)
  es_gal <- prov$dpa_provin == "20"

  # El continente no se mueve
  expect_equal(sf::st_bbox(mov[!es_gal, ]), sf::st_bbox(prov[!es_gal, ]))

  cont <- sf::st_bbox(prov[!es_gal, ])
  gal <- sf::st_bbox(mov[es_gal, ])
  expect_lt(gal[["xmax"]], cont[["xmin"]])                       # a la izquierda
  expect_equal(gal[["ymax"]], cont[["ymax"]], tolerance = 1e-6)   # alineado arriba
  expect_true(isTRUE(attr(mov, "galapagos_reubicado")))
})

test_that("todas las capas quedan alineadas entre niveles", {
  p <- reubicar_galapagos(read_provincias(crs = 32717))
  q <- reubicar_galapagos(read_parroquias(crs = 32717))
  bp <- sf::st_bbox(p[p$dpa_provin == "20", ])
  bq <- sf::st_bbox(q[q$dpa_provin == "20", ])
  expect_equal(as.numeric(bp), as.numeric(bq), tolerance = 1e-6)
})

test_that("reubicar_galapagos no se aplica dos veces y avisa si no hay Galapagos", {
  p <- reubicar_galapagos(read_provincias(crs = 32717))
  expect_identical(reubicar_galapagos(p), p)
  expect_message(reubicar_galapagos(read_provincias("Loja", crs = 32717)),
                 "sin cambios")
})

test_that("marco_galapagos devuelve un recuadro que contiene las islas", {
  p <- reubicar_galapagos(read_provincias(crs = 32717))
  m <- marco_galapagos(p)
  expect_s3_class(m, "sfc")
  expect_true(all(sf::st_within(p[p$dpa_provin == "20", ], m, sparse = FALSE)))
  expect_error(marco_galapagos(read_provincias("Loja")), "no contiene")
})
