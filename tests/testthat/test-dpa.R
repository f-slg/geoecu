test_that("el cat\u00e1logo dpa es consistente", {
  expect_equal(nrow(dpa), 1262)
  expect_equal(length(unique(dpa$dpa_canton)), 221)
  expect_equal(length(unique(dpa$dpa_provin)), 24)
  expect_false(anyDuplicated(dpa$dpa_parroq) > 0)
  expect_true(all(grepl("^[0-9]{6}$", dpa$dpa_parroq)))
  expect_true(all(substr(dpa$dpa_parroq, 1, 4) == dpa$dpa_canton))
  expect_true(all(substr(dpa$dpa_canton, 1, 2) == dpa$dpa_provin))
  expect_setequal(unique(dpa$area_dpa), c("urbana", "rural"))
})

test_that("cada c\u00f3digo de cant\u00f3n y provincia tiene un \u00fanico nombre", {
  expect_equal(nrow(unique(dpa[c("dpa_canton", "canton")])), 221)
  expect_equal(nrow(unique(dpa[c("dpa_provin", "provincia")])), 24)
})
