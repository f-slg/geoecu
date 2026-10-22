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
