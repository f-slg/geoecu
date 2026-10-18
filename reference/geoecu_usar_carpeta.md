# Usar GeoPackages desde una carpeta local

Indica a geoecu una carpeta que contiene `geoecu_dpa_baja.gpkg` y/o
`geoecu_dpa_alta.gpkg`. Útil para trabajar sin conexión, en servidores
institucionales o con datos que aún no se han publicado.

## Usage

``` r
geoecu_usar_carpeta(carpeta)
```

## Arguments

- carpeta:

  Ruta a la carpeta. Usa `NULL` para volver al comportamiento por
  defecto (caché y descarga).

## Value

La carpeta anterior, de forma invisible.

## Details

También puedes definir la variable de entorno `GEOECU_CARPETA` (por
ejemplo, en tu `.Renviron`) para que la carpeta se use siempre.

## Examples

``` r
# Usar una carpeta propia y luego volver a la configuración anterior
anterior <- geoecu_usar_carpeta(tempdir())
geoecu_datos_disponibles()
#> [1] TRUE
geoecu_usar_carpeta(anterior)
```
