# Actualizar códigos de parroquia de versiones anteriores

Convierte códigos de parroquia de los datos de geoecu 0.3.0 y anteriores
(por ejemplo, de parroquias urbanas o del antiguo cantón Eloy Alfaro) al
código actual, usando la equivalencia principal de
[dpa_equivalencias](https://f-slg.github.io/geoecu/reference/dpa_equivalencias.md).
Los códigos vigentes se devuelven igual, aunque sus límites hayan
cambiado.

## Usage

``` r
actualizar_codigo(x)
```

## Arguments

- x:

  Vector de códigos de parroquia (número o texto).

## Value

Vector de texto con los códigos actuales. Los códigos que no existen en
ninguna versión se devuelven como `NA` con una advertencia.

## Details

Cuando menos del 90 % de una parroquia anterior quedó en una sola
parroquia actual, se usa la de mayor superposición y se avisa: revisa
[dpa_equivalencias](https://f-slg.github.io/geoecu/reference/dpa_equivalencias.md)
si necesitas repartir los datos.

## Examples

``` r
# Parroquia urbana de Cuenca, Borbón (antes en Eloy Alfaro) y una sin cambios
actualizar_codigo(c("010101", "080253", "110152"))
#> [1] "010150" "080950" "110152"

# Agregar una tabla antigua al código actual
casos <- data.frame(cod = c("010101", "010102", "010150"), casos = c(3, 4, 1))
casos$cod <- actualizar_codigo(casos$cod)
aggregate(casos ~ cod, data = casos, FUN = sum)
#>      cod casos
#> 1 010150     8
```
