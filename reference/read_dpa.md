# Leer las capas de provincias, cantones o parroquias

Devuelven un objeto `sf` con los límites del nivel solicitado y sus
códigos DPA. Los tres niveles encajan exactamente: cada cantón es la
unión de sus parroquias y cada provincia la unión de sus cantones.

## Usage

``` r
read_provincias(provincia = NULL, resolucion = c("baja", "alta"), crs = 4326)

read_cantones(
  provincia = NULL,
  canton = NULL,
  resolucion = c("baja", "alta"),
  crs = 4326
)

read_parroquias(
  provincia = NULL,
  canton = NULL,
  area = NULL,
  resolucion = c("baja", "alta"),
  crs = 4326
)
```

## Arguments

- provincia:

  Provincias a incluir, por nombre (sin importar tildes ni mayúsculas) o
  código: `"Loja"`, `"11"` o `11`. `NULL` (por defecto) devuelve todo el
  país.

- resolucion:

  `"baja"` (por defecto; liviana, para mapas y tableros) o `"alta"`
  (detallada, para análisis espacial).

- crs:

  Sistema de coordenadas de salida. Por defecto WGS84 (EPSG:4326). Usa
  `32717` (UTM 17S) para calcular áreas o distancias en metros.

- canton:

  Cantones a incluir, por nombre o código. Si un nombre se repite en
  varias provincias (por ejemplo, Bolívar u Olmedo), usa el código o
  indica también `provincia`.

- area:

  Solo para parroquias: `"urbana"`, `"rural"` o `NULL` (ambas).

## Value

Un objeto `sf` de polígonos con las columnas:

- `read_provincias()`: `dpa_provin`, `provincia`, `area_km2`.

- `read_cantones()`: `dpa_canton`, `canton`, `dpa_provin`, `provincia`,
  `area_km2`.

- `read_parroquias()`: `dpa_parroq`, `parroquia`, `area_dpa`,
  `dpa_canton`, `canton`, `dpa_provin`, `provincia`, `area_km2`.

## Details

La primera vez se descarga el GeoPackage de la resolución pedida y se
guarda en caché; las siguientes veces se lee directamente del disco.

## Examples

``` r
provincias <- read_provincias()
plot(sf::st_geometry(provincias))


# Cantones de una provincia, en UTM 17S
loja <- read_cantones(provincia = "Loja", crs = 32717)

# Parroquias rurales de un cantón
read_parroquias(canton = "Puyango", area = "rural")
#> Simple feature collection with 5 features and 8 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: -80.29568 ymin: -4.0664 xmax: -79.87598 ymax: -3.85613
#> Geodetic CRS:  WGS 84
#>   dpa_parroq                  parroquia area_dpa dpa_canton  canton dpa_provin
#> 1     111051                      CIANO    rural       1110 PUYANGO         11
#> 2     111052                  EL ARENAL    rural       1110 PUYANGO         11
#> 3     111053 EL LIMO (MARIANA DE JESUS)    rural       1110 PUYANGO         11
#> 4     111054                 MERCADILLO    rural       1110 PUYANGO         11
#> 5     111055                  VICENTINO    rural       1110 PUYANGO         11
#>   provincia area_km2                       geometry
#> 1      LOJA   79.937 MULTIPOLYGON (((-80.03762 -...
#> 2      LOJA   27.715 MULTIPOLYGON (((-79.98415 -...
#> 3      LOJA  203.758 MULTIPOLYGON (((-80.16189 -...
#> 4      LOJA   28.082 MULTIPOLYGON (((-79.88239 -...
#> 5      LOJA   56.299 MULTIPOLYGON (((-79.91506 -...
```
