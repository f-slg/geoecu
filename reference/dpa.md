# Catálogo de la División Político-Administrativa (DPA) del Ecuador

Una fila por parroquia, con sus códigos y nombres en los tres niveles.
Sirve para buscar códigos, validar tablas antes de unirlas con las capas
o agregar datos parroquiales a cantón o provincia sin necesidad de
geometrías.

## Usage

``` r
dpa
```

## Format

Un `data.frame` con 1262 filas y 7 columnas:

- dpa_parroq:

  Código DPA de la parroquia (6 dígitos, texto).

- parroquia:

  Nombre de la parroquia, en mayúsculas.

- area_dpa:

  `"urbana"` (sufijo de código \<= 50, incluye cabeceras cantonales) o
  `"rural"` (sufijo \> 50).

- dpa_canton:

  Código DPA del cantón (4 dígitos, texto).

- canton:

  Nombre del cantón.

- dpa_provin:

  Código DPA de la provincia (2 dígitos, texto).

- provincia:

  Nombre de la provincia.

## Source

Cartografía de libre acceso del Geoportal del Instituto Geográfico
Militar (IGM) del Ecuador. Ver `data-raw/` en el repositorio para el
procesamiento completo.

## Examples

``` r
head(dpa)
#>   dpa_parroq           parroquia area_dpa dpa_canton canton dpa_provin
#> 1     010101          BELLAVISTA   urbana       0101 CUENCA         01
#> 2     010102         CAÑARIBAMBA   urbana       0101 CUENCA         01
#> 3     010103            EL BATAN   urbana       0101 CUENCA         01
#> 4     010104         EL SAGRARIO   urbana       0101 CUENCA         01
#> 5     010105           EL VECINO   urbana       0101 CUENCA         01
#> 6     010106 GIL RAMIREZ DAVALOS   urbana       0101 CUENCA         01
#>   provincia
#> 1     AZUAY
#> 2     AZUAY
#> 3     AZUAY
#> 4     AZUAY
#> 5     AZUAY
#> 6     AZUAY
# Número de parroquias por provincia
table(dpa$provincia)
#> 
#>                          AZUAY                        BOLIVAR 
#>                             90                             26 
#>                         CARCHI                          CAÑAR 
#>                             36                             33 
#>                     CHIMBORAZO                       COTOPAXI 
#>                             62                             47 
#>                         EL ORO                     ESMERALDAS 
#>                             84                             68 
#>                      GALAPAGOS                         GUAYAS 
#>                              7                             81 
#>                       IMBABURA                           LOJA 
#>                             51                            107 
#>                       LOS RIOS                         MANABI 
#>                             54                            105 
#>                MORONA SANTIAGO                           NAPO 
#>                             60                             25 
#>                       ORELLANA                        PASTAZA 
#>                             33                             21 
#>                      PICHINCHA                    SANTA ELENA 
#>                             98                             17 
#> SANTO DOMINGO DE LOS TSACHILAS                      SUCUMBIOS 
#>                             19                             36 
#>                     TUNGURAHUA               ZAMORA CHINCHIPE 
#>                             64                             38 
```
