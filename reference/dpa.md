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

Un `data.frame` con 1051 filas y 7 columnas:

- dpa_parroq:

  Código DPA de la parroquia (6 dígitos, texto).

- parroquia:

  Nombre de la parroquia, en mayúsculas.

- tipo:

  `"cabecera cantonal"`, `"parroquia rural"` o `"zona en estudio"`.

- dpa_canton:

  Código DPA del cantón (4 dígitos, texto).

- canton:

  Nombre del cantón.

- dpa_provin:

  Código DPA de la provincia (2 dígitos, texto).

- provincia:

  Nombre de la provincia.

## Source

Organización Territorial del Estado, Comité Nacional de Límites Internos
(CONALI), Ministerio de Gobierno del Ecuador, versión del 17 de julio de
2026. Datos abiertos, licencia CC BY:
<https://www.datosabiertos.gob.ec/dataset/organizacion-territorial-parroquial>.
Ver `data-raw/` en el repositorio para el procesamiento completo.

## Details

Incluye 1048 parroquias (223 cabeceras cantonales y 825 parroquias
rurales) de 223 cantones y 24 provincias, más 3 zonas en estudio
(territorios con límites aún no resueltos): Jaramijó-Manta (código
`"139090"`), Sinaí-Cuchaentza (`"140190"`) y Juval (`"900651"`,
provincia `"90"`). Las parroquias urbanas forman parte de su cabecera
cantonal.

## See also

[dpa_equivalencias](https://f-slg.github.io/geoecu/reference/dpa_equivalencias.md)
para actualizar códigos de versiones anteriores de geoecu.

## Examples

``` r
head(dpa)
#>   dpa_parroq  parroquia              tipo dpa_canton canton dpa_provin
#> 1     010150     CUENCA cabecera cantonal       0101 CUENCA         01
#> 2     010151      BAÑOS   parroquia rural       0101 CUENCA         01
#> 3     010152      CUMBE   parroquia rural       0101 CUENCA         01
#> 4     010153    CHAUCHA   parroquia rural       0101 CUENCA         01
#> 5     010154      CHECA   parroquia rural       0101 CUENCA         01
#> 6     010155 CHIQUINTAD   parroquia rural       0101 CUENCA         01
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
#>                                     AZUAY 
#>                                        76 
#>                                   BOLÍVAR 
#>                                        26 
#>                                    CARCHI 
#>                                        32 
#>                                     CAÑAR 
#>                                        33 
#>                                CHIMBORAZO 
#>                                        55 
#>                                  COTOPAXI 
#>                                        40 
#>                                    EL ORO 
#>                                        64 
#>                                ESMERALDAS 
#>                                        64 
#>                                 GALÁPAGOS 
#>                                         8 
#>                                    GUAYAS 
#>                                        54 
#>                                  IMBABURA 
#>                                        42 
#>                                      LOJA 
#>                                        94 
#>                                  LOS RÍOS 
#>                                        30 
#>                                    MANABÍ 
#>                                        79 
#>                           MORONA SANTIAGO 
#>                                        59 
#>                                      NAPO 
#>                                        25 
#>                                  ORELLANA 
#>                                        32 
#>                                   PASTAZA 
#>                                        22 
#>                                 PICHINCHA 
#>                                        62 
#>                               SANTA ELENA 
#>                                        11 
#>            SANTO DOMINGO DE LOS TSÁCHILAS 
#>                                        12 
#>                                 SUCUMBÍOS 
#>                                        39 
#>                                TUNGURAHUA 
#>                                        53 
#>                          ZAMORA CHINCHIPE 
#>                                        38 
#> ZONA EN ESTUDIO: JUVAL (CAÑAR-CHIMBORAZO) 
#>                                         1 
```
