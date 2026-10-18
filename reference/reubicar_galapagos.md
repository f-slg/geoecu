# Reubicar Galápagos junto al continente para mapas nacionales

Traslada las islas Galápagos (provincia `"20"`) a la esquina superior
izquierda del mapa, junto al Ecuador continental, como se hace en la
cartografía nacional para no desperdiciar espacio. Funciona con
cualquier capa de geoecu (provincias, cantones o parroquias) y con capas
unidas con
[`geoecu_unir()`](https://f-slg.github.io/geoecu/reference/geoecu_unir.md),
porque usa la columna `dpa_provin`.

## Usage

``` r
reubicar_galapagos(x, separacion = 0.06)
```

## Arguments

- x:

  Objeto `sf` de geoecu con la columna `dpa_provin` y polígonos del
  continente y de Galápagos. Se recomienda un sistema proyectado, como
  UTM 17S (`crs = 32717`).

- separacion:

  Separación entre Galápagos y el continente, como proporción del ancho
  del Ecuador continental. Por defecto `0.06`.

## Value

El mismo objeto `sf`, con Galápagos trasladado. Si `x` no contiene
Galápagos o no contiene el continente, se devuelve sin cambios.

## Details

El traslado es **solo para visualizar**: no uses el resultado para medir
áreas o distancias de Galápagos. Si reubicas varias capas para
superponerlas (por ejemplo, parroquias y límites provinciales), todas
quedan alineadas porque comparten la misma geometría de origen.

## See also

[`marco_galapagos()`](https://f-slg.github.io/geoecu/reference/marco_galapagos.md)
para dibujar el recuadro.

## Examples

``` r
library(ggplot2)
prov <- reubicar_galapagos(read_provincias(crs = 32717))
ggplot(prov) +
  geom_sf() +
  geom_sf(data = marco_galapagos(prov), fill = NA, color = "grey70") +
  theme_void()
```
