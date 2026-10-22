test_that("el catálogo dpa es consistente", {
  expect_equal(nrow(dpa), 1051)
  expect_equal(sum(dpa$tipo == "cabecera cantonal"), 223)
  expect_equal(sum(dpa$tipo == "parroquia rural"), 825)
  expect_equal(sum(dpa$tipo == "zona en estudio"), 3)
  expect_equal(length(unique(dpa$dpa_canton)), 225)
  expect_equal(length(unique(dpa$dpa_provin)), 25)
  expect_false(anyDuplicated(dpa$dpa_parroq) > 0)
  expect_true(all(grepl("^[0-9]{6}$", dpa$dpa_parroq)))
  expect_true(all(substr(dpa$dpa_parroq, 1, 4) == dpa$dpa_canton))
  expect_true(all(substr(dpa$dpa_canton, 1, 2) == dpa$dpa_provin))
  expect_setequal(unique(dpa$tipo),
                  c("cabecera cantonal", "parroquia rural", "zona en estudio"))
})

test_that("cada código de cantón y provincia tiene un único nombre", {
  expect_equal(nrow(unique(dpa[c("dpa_canton", "canton")])), 225)
  expect_equal(nrow(unique(dpa[c("dpa_provin", "provincia")])), 25)
})

test_that("cada cantón tiene una sola cabecera", {
  cab <- dpa[dpa$tipo == "cabecera cantonal", ]
  expect_false(anyDuplicated(cab$dpa_canton) > 0)
  expect_true(all(substr(cab$dpa_parroq, 5, 6) == "50"))
})
