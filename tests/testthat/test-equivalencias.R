test_that("dpa_equivalencias cubre todos los códigos anteriores", {
  princ <- dpa_equivalencias[dpa_equivalencias$principal, ]
  expect_equal(nrow(princ), 1262)
  expect_false(anyDuplicated(princ$dpa_parroq_anterior) > 0)
  expect_true(all(dpa_equivalencias$dpa_parroq %in% dpa$dpa_parroq))
  expect_true(all(dpa_equivalencias$proporcion > 0 &
                    dpa_equivalencias$proporcion <= 1))
})

test_that("actualizar_codigo convierte códigos anteriores", {
  # urbana de Cuenca -> cabecera; Borbón (antes en Eloy Alfaro) -> cantón Borbón
  expect_equal(actualizar_codigo(c("010101", "080253")), c("010150", "080950"))
  # Sevilla Don Bosco y Bella Vista cambian de código
  expect_equal(actualizar_codigo(c(140157, 200353)), c("141350", "200351"))
  # los códigos vigentes no cambian
  expect_equal(actualizar_codigo(c("010150", "170250")), c("010150", "170250"))
  expect_equal(actualizar_codigo(NA), NA_character_)
})

test_that("actualizar_codigo avisa ante códigos desconocidos o repartidos", {
  expect_warning(x <- actualizar_codigo("999999"), "ninguna versión")
  expect_equal(x, NA_character_)
  expect_warning(actualizar_codigo("220254"), "repartida")
})
