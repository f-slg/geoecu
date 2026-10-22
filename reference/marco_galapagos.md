# Recuadro para Galápagos reubicado

Devuelve un rectángulo alrededor de Galápagos, pensado para dibujarlo
como un recuadro tenue después de
[`reubicar_galapagos()`](https://f-slg.github.io/geoecu/reference/reubicar_galapagos.md).

## Usage

``` r
marco_galapagos(x, margen = 0.06)
```

## Arguments

- x:

  Objeto `sf` de geoecu, normalmente ya pasado por
  [`reubicar_galapagos()`](https://f-slg.github.io/geoecu/reference/reubicar_galapagos.md).

- margen:

  Margen alrededor de las islas, como proporción del ancho del
  archipiélago. Por defecto `0.06`.

## Value

Un objeto `sfc` con un polígono, en el mismo sistema de coordenadas que
`x`.

## Examples

``` r
prov <- reubicar_galapagos(read_provincias(crs = 32717))
marco_galapagos(prov)
#> Geometry set for 1 feature 
#> Geometry type: POLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 130411.1 ymin: 9796680 xmax: 479280.9 ymax: 10181240
#> Projected CRS: WGS 84 / UTM zone 17S
#> POLYGON ((130411.1 9796680, 479280.9 9796680, 4...
```
