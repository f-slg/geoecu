## Submission

This is a minor update of 'geoecu' (0.4.0 -> 0.4.1) that corrects the
surface area of each unit (column `area_km2`). It was computed in UTM zone
17S, which does not preserve areas: the Galapagos Islands, which lie in UTM
zone 15, were overestimated by about 3 %. Areas are now computed on the WGS84
ellipsoid with an equal-area projection (EPSG:6933). The geometries and codes
are unchanged; the corrected GeoPackages are published as the new data
release `datos-v0.3.0`.

## Test environments

* local Ubuntu 26.04, R 4.5.2
* GitHub Actions: windows-latest, macos-latest, ubuntu-latest (R release),
  with the data-dependent tests enabled
* win-builder: R-devel (2026-10-21 r90733 ucrt)

## R CMD check results

0 errors | 0 warnings | 1 note

* Days since last update: the update corrects the data source attribution
  and updates the data to the current official version (new cantons and
  parishes created in July 2026), so we preferred not to wait.

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
* The documentation is in Spanish (`Language: es`) because the package is
  aimed at users in Ecuador; the Title and Description are in English.
