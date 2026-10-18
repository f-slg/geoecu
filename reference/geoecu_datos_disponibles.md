# ¿Están disponibles los datos sin descargar?

Comprueba si el GeoPackage de la resolución indicada ya está en la
carpeta local configurada o en la caché.

## Usage

``` r
geoecu_datos_disponibles(resolucion = "baja")
```

## Arguments

- resolucion:

  `"baja"` o `"alta"`.

## Value

`TRUE` o `FALSE`.

## Examples

``` r
geoecu_datos_disponibles()
#> [1] TRUE
```
