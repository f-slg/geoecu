# Carpeta de caché de geoecu

Los GeoPackages descargados se guardan aquí para no volver a
descargarlos. La ubicación sigue las convenciones de cada sistema
operativo
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
#> [1] "/home/runner/.cache/R/geoecu/datos-v0.2.0"
```
