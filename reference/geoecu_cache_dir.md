# Carpeta de caché de geoecu

Los GeoPackages descargados se guardan aquí para no volver a
descargarlos. La primera vez que se usan en cada sesión se comprueba su
huella; si un archivo está incompleto o modificado, se descarga de
nuevo. Para usar archivos propios, indica otra carpeta con
[`geoecu_usar_carpeta()`](https://f-slg.github.io/geoecu/reference/geoecu_usar_carpeta.md).
La ubicación sigue las convenciones de cada sistema operativo
([`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html)).

## Usage

``` r
geoecu_cache_dir()
```

## Value

Ruta de la carpeta de caché (texto).

## Examples

``` r
geoecu_cache_dir()
#> [1] "/home/runner/.cache/R/geoecu/datos-v0.3.0"
```
