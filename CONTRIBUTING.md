# Cómo contribuir a geoecu

¡Gracias por tu interés! Toda ayuda es bienvenida, desde avisar de un
error hasta proponer una función nueva.

## Preguntas

Si tienes una duda de uso (“¿cómo calculo…?”, “¿qué significa…?”),
pregunta en [Discussions ›
Q&A](https://github.com/f-slg/geoecu/discussions/categories/q-a). Así la
respuesta queda disponible para todos.

## Reportar un problema

Abre un [issue](https://github.com/f-slg/geoecu/issues/new/choose) y
elige la plantilla que corresponda:

- **Reportar un error:** una función falla o da un resultado incorrecto.
  Incluye un ejemplo mínimo que se pueda copiar y ejecutar.
- **Problema con los datos:** un límite, código o nombre no coincide con
  la Organización Territorial del Estado (CONALI) vigente. Indica la
  fuente con la que comparas (por ejemplo, el Registro Oficial de
  creación).
- **Proponer una mejora:** cuéntanos qué necesitas hacer.

## Enviar cambios

1.  Haz un *fork* y crea una rama para tu cambio.
2.  Si cambias funciones, actualiza la documentación con
    `roxygen2::roxygenise()` y agrega o ajusta tests en
    `tests/testthat/`.
3.  Verifica que el paquete pase `R CMD check` sin errores ni
    advertencias.
4.  Abre un *pull request* explicando qué cambia y por qué.

Los datos se generan con los scripts de
[`data-raw/`](https://github.com/f-slg/geoecu/tree/main/data-raw/): si
propones un cambio en los datos, modifica el script y no los archivos
generados.

## Actualizar las figuras del README

Cuando cambien los estilos o ejemplos de los mapas:

1.  Trabaja en una rama y ejecuta desde la raíz:

    ``` bash
    Rscript data-raw/03_figuras_readme.R
    Rscript data-raw/06_validar_readme.R
    ```

2.  Revisa visualmente las seis figuras `man/figures/README-*.png` para
    comprobar márgenes, títulos, etiquetas y leyendas. Actualiza los
    ejemplos del README si cambia la composición.

3.  Registra en **tu rama** los PNG y el código con un commit; abre un
    PR.

4.  El workflow **Render detailed map gallery** regenera las seis
    figuras y las sube como artefacto para revisar, pero **no hace push,
    commit ni publica cambios automáticamente**. Los archivos que
    quieras integrar en `main` deben figurar en el PR.

Este procedimiento mantiene separados los cambios cartográficos de la
revisión y evita que GitHub Actions escriba directamente en ramas
protegidas.

## Actualizar los datos

Cuando el CONALI publique una nueva versión de la Organización
Territorial del Estado (por ejemplo, tras la creación de un cantón o una
parroquia):

1.  Descarga la capa `ORGANIZACION_TERRITORIAL_PARROQUIAL` del [portal
    de datos
    abiertos](https://www.datosabiertos.gob.ec/dataset/organizacion-territorial-parroquial)
    y guárdala en `data-raw/insumos/` (carpeta ignorada por git). Revisa
    en sus metadatos la fecha, la licencia y la cita requerida.

2.  Simplifica y construye los niveles (requiere Node.js y mapshaper):

    ``` bash
    bash data-raw/01_simplificar.sh data-raw/insumos/ORGANIZACION_TERRITORIAL_PARROQUIAL.shp
    ```

3.  Genera los GeoPackages y el catálogo `dpa`. El script imprime la
    huella MD5 de cada GeoPackage:

    ``` bash
    Rscript data-raw/02_construir_datos.R
    ```

4.  Si cambian los códigos, actualiza `dpa_equivalencias` con
    `data-raw/04_equivalencias.R` (compara con la versión anterior de
    los datos, que debes copiar en `data-raw/insumos/`).

5.  En `R/zzz.R`, cambia `.geoecu_version_datos` a la nueva etiqueta
    (por ejemplo, `datos-v0.3.0`) y `.geoecu_md5` a las huellas del paso
    3.

6.  Publica el release de datos con esa etiqueta y los dos GeoPackages:

    ``` bash
    gh release create datos-v0.3.0 data-raw/release/geoecu_dpa_baja.gpkg data-raw/release/geoecu_dpa_alta.gpkg --title "Datos geoecu 0.3.0"
    ```

7.  Actualiza la fecha de la versión de origen y los conteos en
    `R/datos.R`, `inst/COPYRIGHTS`, `inst/CITATION`, el README, los
    artículos de `vignettes/articles/` y las pruebas de
    `tests/testthat/`.

8.  Regenera la documentación y las figuras, y verifica el paquete:

    ``` bash
    Rscript -e 'roxygen2::roxygenise()'
    Rscript data-raw/03_figuras_readme.R
    Rscript data-raw/05_logo.R
    R CMD build . && R CMD check --as-cran geoecu_*.tar.gz
    ```

Los releases de datos anteriores no se borran: así las versiones
anteriores del paquete siguen funcionando con sus datos.

## Publicar una versión en CRAN

1.  Actualiza `Version` en `DESCRIPTION`, `NEWS.md` y
    `cran-comments.md`.
2.  Verifica con `devtools::check(remote = TRUE, manual = TRUE)`,
    `devtools::check_win_devel()` y `urlchecker::url_check()`.
3.  Envía con `devtools::submit_cran()` y, cuando CRAN lo acepte, crea
    una etiqueta `vX.Y.Z` y un release en GitHub.

La documentación y los mensajes del paquete están en español.

## Código de conducta

Este proyecto sigue un [código de
conducta](https://github.com/f-slg/geoecu/blob/main/.github/CODE_OF_CONDUCT.md)
(Contributor Covenant 2.1). Al participar, te comprometes a respetarlo.
