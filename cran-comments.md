## Submission

This is a patch release of 'geoecu' (0.4.1 -> 0.4.2). It fixes a defect in
`geoecu_unir()` that silently dropped columns of the user's table, and several
smaller problems in the handling of codes, names, filters and the download
cache. See NEWS.md for details. The geographic data are unchanged (data
release `datos-v0.3.0`).

## Reason for the early update

We apologise for submitting again so soon after 0.4.1 (published 2026-10-30).
Version 0.4.1 has a defect that silently loses user data: `geoecu_unir()`,
which joins a user's table to the boundaries, drops without any warning the
columns of the user's table whose names coincide with a column of the layer
(for example `tipo`, `canton` or `provincia`), and overwrites a column named
like the key of the layer. Such columns are common in the case tables of
epidemiological surveillance, one of the uses the package is intended for.
Ecuador has been under a national red alert for the El Niño phenomenon since
29 August 2026, so we would rather not leave this defect in place for another
month in the function meant for joining case and rate tables to the map.
Version 0.4.2 keeps those columns, with the suffix `_datos`, and warns. We do
not plan another update in the coming months.

## Test environments

* local Ubuntu 26.04, R 4.5.2 (`R CMD check --as-cran` on the built tarball)
* GitHub Actions: windows-latest, macos-latest and ubuntu-latest (R release)
  and ubuntu-latest (R-devel), with the data-dependent tests enabled

## R CMD check results

0 errors | 0 warnings | 0 notes

## Notes for the reviewers

* The geographic layers (GeoPackage files, 3 MB and 39 MB) are not shipped
  with the package. They are downloaded on first use from the package's
  GitHub release, verified with an MD5 checksum and cached with
  `tools::R_user_dir("geoecu", "cache")`. Users can also point the package to
  local copies with `geoecu_usar_carpeta()`.
* Functions that need the data fail with an informative message when the
  internet is not available. Examples that need the data are wrapped in
  `@examplesIf geoecu_datos_disponibles()`, and the corresponding tests are
  skipped when the data are not available, so checks do not require internet
  access.
* The new tests of the download and cache code do not use the internet or the
  user's cache: they download from a local `file://` source into a temporary
  directory set through `R_USER_CACHE_DIR`.
* The documentation is in Spanish (`Language: es`) because the package is
  aimed at users in Ecuador; the Title and Description are in English.
