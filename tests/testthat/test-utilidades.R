test_that("normalizar_nombre quita tildes, signos y espacios", {
  expect_equal(normalizar_nombre("Ca\u00f1ar"), "CANAR")
  expect_equal(normalizar_nombre("  san  Jos\u00e9 de Chimbo "), "SAN JOSE DE CHIMBO")
  expect_equal(normalizar_nombre("CHECA (JIDCAY)"), "CHECA JIDCAY")
  expect_equal(normalizar_nombre(NA), NA_character_)
  # Misma palabra con la tilde como carácter combinado (forma NFD)
  expect_equal(normalizar_nombre("Can\u0303ar"), "CANAR")
  expect_equal(normalizar_nombre("Jose\u0301"), "JOSE")
  # Otras vocales acentuadas y la cedilla conservan su letra base
  expect_equal(normalizar_nombre(c("S\u00e3o Jo\u00e3o", "Cura\u00e7ao", "voil\u00e0", "\u00c0\u00ca\u00c7")),
               c("SAO JOAO", "CURACAO", "VOILA", "AEC"))
})

test_that("formatear_codigo recupera ceros a la izquierda", {
  expect_equal(formatear_codigo(c(1, 11, "7"), "provincia"), c("01", "11", "07"))
  expect_equal(formatear_codigo(c(701, 1101), "canton"), c("0701", "1101"))
  expect_equal(formatear_codigo("110150", "parroquia"), "110150")
  expect_equal(formatear_codigo(1101.0, "canton"), "1101")
  expect_equal(formatear_codigo(NA, "canton"), NA_character_)
})

test_that("formatear_codigo avisa ante valores inv\u00e1lidos", {
  expect_warning(x <- formatear_codigo(c("0101", "abc", "12345"), "canton"),
                 "no son c\u00f3digos")
  expect_equal(x, c("0101", NA, NA))
})

test_that("formatear_codigo no inventa la provincia 00", {
  # "01" como cantón o 0 como provincia quedarían "0001" y "00"
  expect_warning(x <- formatear_codigo(c("01", "101"), "canton"), "no son c\u00f3digos")
  expect_equal(x, c(NA, "0101"))
  expect_warning(expect_equal(formatear_codigo(0, "provincia"), NA_character_))
  expect_warning(expect_equal(formatear_codigo(150, "parroquia"), NA_character_))
})

test_that("formatear_codigo no usa notaci\u00f3n cient\u00edfica con n\u00fameros", {
  expect_equal(formatear_codigo(c(100000, 110150, NA), "parroquia"),
               c("100000", "110150", NA))
  expect_equal(formatear_codigo(c(701, 1000), "canton"), c("0701", "1000"))
  expect_warning(x <- formatear_codigo(c(701, 1101.5), "canton"), "1101.5")
  expect_equal(x, c("0701", NA))
})

test_that("buscar_dpa encuentra por nombre y por c\u00f3digo", {
  r <- buscar_dpa("arenal")
  expect_true("EL ARENAL" %in% r$parroquia)
  expect_equal(nrow(buscar_dpa("puyango", nivel = "canton")), 1)
  expect_equal(buscar_dpa("11", nivel = "provincia")$provincia, "LOJA")
  expect_equal(nrow(buscar_dpa("xyzxyz")), 0)
  expect_equal(nrow(buscar_dpa(NA)), 0)
  expect_identical(names(buscar_dpa(NA)), names(dpa))
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
  expect_error(geoecu:::.resolver_codigos(NA, "provincia"), "no admite NA")
  expect_error(geoecu:::.resolver_codigos(c("Loja", ""), "provincia"), "no admite NA")
  expect_error(geoecu:::.resolver_codigos(" ", "canton"), "cant\u00f3n no admite")
  amb <- names(which(table(unique(dpa[c("dpa_canton", "canton")])$canton) > 1))
  skip_if(length(amb) == 0)
  expect_error(geoecu:::.resolver_codigos(amb[1], "canton"), "varios")
  # con provincia se resuelve
  prov <- unique(dpa$dpa_provin[dpa$canton == amb[1]])[1]
  expect_length(geoecu:::.resolver_codigos(amb[1], "canton", dentro = prov), 1)
})
