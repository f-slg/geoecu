## Submission

This is the first submission of 'geoecu'.

## Test environments

* local Ubuntu 26.04, R 4.5.2
* GitHub Actions: windows-latest, macos-latest, ubuntu-latest (R release)
* win-builder: R-devel, R-release, R-oldrelease

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Notes for the reviewers

* The geographic layers (GeoPackage files, 3 MB and 38 MB) are not shipped
  with the package. They are downloaded on first use from the package's
  GitHub release and cached with `tools::R_user_dir("geoecu", "cache")`.
  Users can also point the package to local copies with
  `geoecu_usar_carpeta()`.
* Functions that need the data fail with an informative message when the
  internet is not available. Examples that need the data are wrapped in
  `@examplesIf geoecu_datos_disponibles()`, and the corresponding tests are
  skipped when the data are not available, so checks do not require internet
  access.
* The documentation is in Spanish (`Language: es`) because the package is
  aimed at users in Ecuador; the Title and Description are in English.
