## Submission

This is an update of 'geoecu' (0.3.0 -> 0.4.0), submitted shortly after the
first release because it corrects an error in the attribution of the data
source: version 0.3.0 attributed the geographic layers to the Geographic
Military Institute of Ecuador (IGM), which was not correct. The layers and the bundled `dpa`
catalogue are now rebuilt from the open data of the Territorial Organization
of the State published by the National Committee of Internal Boundaries
(CONALI, Ministry of Government of Ecuador) under a CC BY licence. The source
and licence of the data are documented in `inst/COPYRIGHTS` (declared in the
`Copyright` field of DESCRIPTION) and in `inst/CITATION`.

## Test environments

* local Ubuntu 26.04, R 4.5.2
* GitHub Actions: windows-latest, macos-latest, ubuntu-latest (R release),
  with the data-dependent tests enabled
* win-builder: R-devel

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
