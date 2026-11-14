# geoecu (versión de desarrollo)

* `geoecu_unir()` ya no elimina las columnas de `datos` que se llaman igual
  que una de la capa (por ejemplo, `tipo` o `area_km2`): se conservan con el
  sufijo `_datos` y se avisa con una advertencia.
* `normalizar_nombre()` y las búsquedas por nombre reconocen los textos con
  tildes como caracteres combinados (Unicode NFD), habituales al copiar de
  algunos sistemas: "Cañar" ya no se convierte en `CAN AR`.
* `geoecu_unir()` tampoco sobrescribe una columna de `datos` que se llame
  como la clave de la capa (por ejemplo, `dpa_canton`) cuando el código está
  en otra columna: se conserva como `dpa_canton_datos`, con una advertencia.
* `actualizar_codigo()` avisa cuando conserva un código vigente cuya
  parroquia anterior quedó en su mayor parte en otra parroquia actual
  (`"030157"`, `"160162"` y `"170250"`). El resultado no cambia.
* `formatear_codigo()` devuelve `NA`, con advertencia, en lugar de inventar
  la provincia `"00"`: `"01"` como cantón ya no se convierte en `"0001"`.
  Además, los números grandes ya no pasan por notación científica
  (`100000` se mostraba como `1e+05`).
* Los filtros de `read_provincias()`, `read_cantones()` y
  `read_parroquias()` explican el error cuando reciben `NA` o un texto
  vacío, y `buscar_dpa(NA)` devuelve una tabla sin filas.
* `normalizar_nombre()` conserva la letra base de otras vocales acentuadas y
  de la cedilla (`à`, `ê`, `ã`, `ç`...), que antes se convertían en espacios.
* Caché más robusta: la descarga se guarda con un nombre temporal y se
  renombra al terminar, y la huella del archivo en caché se comprueba la
  primera vez que se usa en cada sesión; si no coincide, se descarga de
  nuevo. Los archivos de `geoecu_usar_carpeta()` no se verifican.
* `geoecu_unir()`, `reubicar_galapagos()` y `marco_galapagos()` validan
  `codigo`, `separacion` y `margen` y explican el error.
* Documentación: `sf::st_area()` sobre las capas en WGS84 calcula sobre una
  esfera y da superficies un 0,45 % mayores que `area_km2`; se advierte en
  `read_provincias()` y en el artículo **Datos y fuente**.
* `citation("geoecu")` incluye el DOI del paquete en CRAN
  (<https://doi.org/10.32614/CRAN.package.geoecu>) y el ORCID del autor, que
  también figura en `DESCRIPTION`. Nuevo `CITATION.cff` en el repositorio.

# geoecu 0.4.1

## Datos

* Se corrige `area_km2` (nuevo release de datos `datos-v0.3.0`). La
  superficie se calculaba en UTM 17S, que no conserva áreas: Galápagos, en el
  huso 15, salía inflada en un 3 % (unos 240 km²) y las provincias de la
  Amazonía oriental entre 0,2 % y 0,6 %. Ahora se calcula sobre el elipsoide
  WGS84 con una proyección de igual área (EPSG:6933). La superficie total del
  Ecuador pasa de 257 205 a 256 505 km². Las geometrías y los códigos no
  cambian.

## Documentación

* El artículo **Datos y fuente** tiene una nueva sección *Superficie* con un
  gráfico del error de UTM 17S por provincia.
* La documentación de `crs` en `read_provincias()` y la Guía de uso ya no
  recomiendan UTM 17S para medir áreas.
* Nuevo ejemplo en la galería del README: densidad poblacional por provincia,
  cantón y parroquia, con `area_km2` y la población 2026 del INEC (paquete
  pobecu).

# geoecu 0.4.0

## Datos

* Las capas se reconstruyen a partir de la **Organización Territorial del
  Estado** del Comité Nacional de Límites Internos (CONALI), Ministerio de
  Gobierno del Ecuador, versión del 17 de julio de 2026, publicada como datos
  abiertos con licencia CC BY (nuevo release de datos `datos-v0.2.0`).
* Se corrige la atribución de la fuente: las versiones 0.2.1 a 0.3.0
  atribuían los datos al Instituto Geográfico Militar (IGM), lo que no era
  correcto. Los datos anteriores (`datos-v0.1.0`) quedan reemplazados.
* Cobertura: 24 provincias, 223 cantones (incluye los nuevos cantones Borbón
  y Sevilla Don Bosco) y 1048 parroquias (223 cabeceras cantonales y 825
  rurales, incluidas Sosote, Shuar Pastaza, Juan Montalvo, La Magdalena, La
  Primavera y Miss Ecuador), más 3 zonas en estudio.
* **Cambio incompatible:** el CONALI no subdivide las cabeceras cantonales en
  parroquias urbanas; ahora forman parte de su cabecera. La columna
  `area_dpa` (`"urbana"`/`"rural"`) se reemplaza por `tipo`
  (`"cabecera cantonal"`, `"parroquia rural"`, `"zona en estudio"`), presente
  también en provincias y cantones.
* Nuevo catálogo `dpa_equivalencias` y nueva función `actualizar_codigo()`
  para convertir códigos de parroquia de versiones anteriores.

## Funciones

* `read_parroquias()` tiene el nuevo argumento `tipo` (`"cabecera"`,
  `"rural"`, `"zona"`). El argumento `area` queda obsoleto: sigue funcionando
  con una advertencia.
* Las descargas se verifican con una huella MD5 antes de guardarse en caché.
* El ejemplo de `reubicar_galapagos()` solo se ejecuta si ggplot2 está
  instalado.

## Documentación

* `inst/COPYRIGHTS` y `inst/CITATION` con la fuente de los datos y cómo
  citarla; `LICENSE.md` aclara que el catálogo `dpa` va dentro del paquete.
* Las pruebas que necesitan las capas se ejecutan en GitHub Actions.
* Nuevos artículos en el sitio web: una **Guía de uso** detallada (leer,
  filtrar, unir, mapear, Galápagos, agregar, códigos anteriores, uso sin
  conexión) y **Datos y fuente** (origen, licencia, procesamiento, zonas en
  estudio y cambios).
* Logo, favicons y figuras del README regenerados con los datos nuevos
  (`data-raw/05_logo.R`).
* README con más detalle y guía de contribución con el procedimiento para
  actualizar los datos y publicar en CRAN.

# geoecu 0.3.0

* Primera versión enviada a CRAN.
* `DESCRIPTION` en inglés, con el título también en español.
* Los ejemplos ya no usan `\dontrun{}`.

# geoecu 0.2.1

* Se documenta la fuente de las geometrías: cartografía de libre acceso del
  Geoportal del Instituto Geográfico Militar (IGM) del Ecuador.
* README: aclaración de que geoecu es un paquete independiente.

# geoecu 0.2.0

* Nuevas funciones `reubicar_galapagos()` y `marco_galapagos()` para mapas
  nacionales: trasladan Galápagos a la esquina superior izquierda, junto al
  continente, y devuelven un recuadro para dibujarlo. Funcionan con los tres
  niveles y con capas unidas con `geoecu_unir()`.
* README: instrucciones para instalar `sf` rápidamente en Linux.

# geoecu 0.1.0

* Primera versión.
* `read_provincias()`, `read_cantones()` y `read_parroquias()` con filtros por
  nombre o código, resolución `"baja"`/`"alta"` y cambio de sistema de
  coordenadas.
* `geoecu_unir()` para unir datos propios con las capas por código DPA.
* Catálogo `dpa` (1262 parroquias, 221 cantones, 24 provincias) y utilidades
  `buscar_dpa()`, `formatear_codigo()` y `normalizar_nombre()`.
* Descarga con caché desde los releases de GitHub (`datos-v0.1.0`) y uso de
  archivos locales con `geoecu_usar_carpeta()`.
