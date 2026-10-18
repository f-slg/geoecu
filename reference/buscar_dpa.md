# Buscar en el catálogo DPA

Busca por nombre (sin importar tildes ni mayúsculas) o por código en el
catálogo [dpa](https://f-slg.github.io/geoecu/reference/dpa.md).

## Usage

``` r
buscar_dpa(texto, nivel = c("parroquia", "canton", "provincia"))
```

## Arguments

- texto:

  Texto a buscar: parte de un nombre o un código.

- nivel:

  Nivel en el que buscar: `"parroquia"`, `"canton"` o `"provincia"`.

## Value

Un `data.frame` con las coincidencias en el nivel indicado.

## Examples

``` r
buscar_dpa("arenal")
#>   dpa_parroq parroquia area_dpa dpa_canton  canton dpa_provin provincia
#> 1     111052 EL ARENAL    rural       1110 PUYANGO         11      LOJA
buscar_dpa("puyango", nivel = "canton")
#>   dpa_canton  canton dpa_provin provincia
#> 1       1110 PUYANGO         11      LOJA
buscar_dpa("11", nivel = "provincia")
#>   dpa_provin provincia
#> 1         11      LOJA
```
