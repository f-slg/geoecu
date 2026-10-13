test_that("normalizar_nombre quita tildes, signos y espacios", {
  expect_equal(normalizar_nombre("Ca\u00f1ar"), "CANAR")
  expect_equal(normalizar_nombre("  san  Jos\u00e9 de Chimbo "), "SAN JOSE DE CHIMBO")
  expect_equal(normalizar_nombre("CHECA (JIDCAY)"), "CHECA JIDCAY")
  expect_equal(normalizar_nombre(NA), NA_character_)
})

test_that("formatear_codigo recupera ceros a la izquierda", {
  expect_equal(formatear_codigo(c(1, 11, "7"), "provincia"), c("01", "11", "07"))
  expect_equal(formatear_codigo(c(701, 1101), "canton"), c("0701", "1101"))
  expect_equal(formatear_codigo("110150", "parroquia"), "110150")
  expect_equal(formatear_codigo(1101.0, "canton"), "1101")
  expect_equal(formatear_codigo(NA, "canton"), NA_character_)
})

test_that("formatear_codigo avisa ante valores inv\u00e1lidos", {
  expect_warning(x <- formatear_codigo(c("01", "abc", "12345"), "canton"),
                 "no son c\u00f3digos")
  expect_equal(x, c("0001", NA, NA))
})

test_that("buscar_dpa encuentra por nombre y por c\u00f3digo", {
  r <- buscar_dpa("arenal")
  expect_true("EL ARENAL" %in% r$parroquia)
  expect_equal(nrow(buscar_dpa("puyango", nivel = "canton")), 1)
  expect_equal(buscar_dpa("11", nivel = "provincia")$provincia, "LOJA")
  expect_equal(nrow(buscar_dpa("xyzxyz")), 0)
})

test_that(".resolver_codigos acepta nombres, c\u00f3digos y n\u00fameros", {
  expect_equal(geoecu:::.resolver_codigos("Loja", "provincia"), "11")
  expect_equal(geoecu:::.resolver_codigos(11, "provincia"), "11")
  expect_equal(geoecu:::.resolver_codigos(c("loja", "AZUAY"), "provincia"), c("11", "01"))
  expect_equal(geoecu:::.resolver_codigos("Puyango", "canton"), "1110")
})

test_that(".resolver_codigos explica errores y ambig\u00fcedades", {
  expect_error(geoecu:::.resolver_codigos("Lojja", "provincia"), "Quisiste decir")
  expect_error(geoecu:::.resolver_codigos(99, "provincia"), "No existe")
  amb <- names(which(table(unique(dpa[c("dpa_canton", "canton")])$canton) > 1))
  skip_if(length(amb) == 0)
  expect_error(geoecu:::.resolver_codigos(amb[1], "canton"), "varios")
  # con provincia se resuelve
  prov <- unique(dpa$dpa_provin[dpa$canton == amb[1]])[1]
  expect_length(geoecu:::.resolver_codigos(amb[1], "canton", dentro = prov), 1)
})
