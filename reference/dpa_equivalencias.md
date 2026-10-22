# Equivalencias con los códigos de parroquia de versiones anteriores

Relaciona los códigos de parroquia de los datos de geoecu 0.3.0 y
anteriores (release `datos-v0.1.0`) con los de la versión actual, según
la superposición de sus áreas. Útil para actualizar tablas codificadas
con la versión anterior; para hacerlo directamente, usa
[`actualizar_codigo()`](https://f-slg.github.io/geoecu/reference/actualizar_codigo.md).

## Usage

``` r
dpa_equivalencias
```

## Format

Un `data.frame` con 7 columnas:

- dpa_parroq_anterior:

  Código de la parroquia en la versión anterior.

- parroquia_anterior:

  Nombre en la versión anterior.

- dpa_parroq:

  Código de la parroquia actual.

- parroquia:

  Nombre de la parroquia actual.

- proporcion:

  Proporción del área de la parroquia anterior que cae en la actual (0 a
  1).

- principal:

  `TRUE` en la parroquia actual con mayor superposición.

- cambio:

  `"sin cambio"`, `"integrada en la cabecera cantonal"` o
  `"código distinto"`.

## Source

Elaborado en `data-raw/04_equivalencias.R` a partir de las capas de alta
resolución de ambas versiones.

## Details

Los cambios principales son: las parroquias urbanas pasan a formar parte
de su cabecera cantonal; las parroquias del nuevo cantón Borbón (antes
en Eloy Alfaro) y la cabecera de Sevilla Don Bosco cambian de código; y
algunas parroquias cambian de límites o se integran en otras.

Una parroquia anterior puede repartirse entre varias actuales: hay una
fila por cada parte que cubre al menos el 1 % de su área, y `principal`
marca la de mayor superposición.

## Examples

``` r
# Parroquias que cambiaron de código
subset(dpa_equivalencias, principal & cambio == "código distinto")
#>      dpa_parroq_anterior                        parroquia_anterior dpa_parroq
#> 124               030157                                    RIVERA     900651
#> 357               071203              BALNEARIO JAMBELI (SATELITE)     071252
#> 399               080251                                 ANCHAYACU     080951
#> 400               080252             ATAHUALPA (CAB. EN CAMARONES)     080952
#> 401               080253                                    BORBON     080950
#> 403               080255 LUIS VARGAS TORRES (CAB. EN PLAYA DE ORO)     080953
#> 404               080256                                 MALDONADO     080954
#> 406               080258                   SAN FRANCISCO DE ONZOLE     080955
#> 407               080259                   SANTO DOMINGO DE ONZOLE     080956
#> 408               080260                              SELVA ALEGRE     080957
#> 409               080261                                   TELEMBI     080958
#> 410               080262                      COLON ELOY DEL MARIA     080959
#> 411               080263                       SAN JOSE DE CAYAPAS     080960
#> 412               080264                                   TIMBIRE     080961
#> 860               140157                         SEVILLA DON BOSCO     141350
#> 951               160162       SIMON BOLIVAR (CAB. EN MUSHULLACTA)     160167
#> 1035              170203                             JUAN MONTALVO     170257
#> 1036              170250                                   CAYAMBE     170257
#> 1180              200353                               BELLA VISTA     200351
#> 1240              220254                                  TIPUTINI     220250
#>                                      parroquia proporcion principal
#> 124  ZONA EN ESTUDIO: JUVAL (CAÑAR-CHIMBORAZO)      0.591      TRUE
#> 357                                    JAMBELÍ      0.999      TRUE
#> 399                                  ANCHAYACU      1.000      TRUE
#> 400                                  ATAHUALPA      1.000      TRUE
#> 401                                     BORBÓN      0.999      TRUE
#> 403                         LUIS VARGAS TORRES      0.999      TRUE
#> 404                                  MALDONADO      1.000      TRUE
#> 406                    SAN FRANCISCO DE ONZOLE      1.000      TRUE
#> 407                    SANTO DOMINGO DE ONZOLE      1.000      TRUE
#> 408                               SELVA ALEGRE      1.000      TRUE
#> 409                                    TELEMBÍ      1.000      TRUE
#> 410                       COLÓN ELOY DEL MARÍA      1.000      TRUE
#> 411                        SAN JOSÉ DE CAYAPAS      1.000      TRUE
#> 412                                    TIMBIRÉ      1.000      TRUE
#> 860                          SEVILLA DON BOSCO      0.991      TRUE
#> 951                              SHUAR PASTAZA      0.724      TRUE
#> 1035                             JUAN MONTALVO      0.997      TRUE
#> 1036                             JUAN MONTALVO      0.864      TRUE
#> 1180                               BELLA VISTA      0.998      TRUE
#> 1240                          NUEVO ROCAFUERTE      0.820      TRUE
#>               cambio
#> 124  código distinto
#> 357  código distinto
#> 399  código distinto
#> 400  código distinto
#> 401  código distinto
#> 403  código distinto
#> 404  código distinto
#> 406  código distinto
#> 407  código distinto
#> 408  código distinto
#> 409  código distinto
#> 410  código distinto
#> 411  código distinto
#> 412  código distinto
#> 860  código distinto
#> 951  código distinto
#> 1035 código distinto
#> 1036 código distinto
#> 1180 código distinto
#> 1240 código distinto
```
