# Changelog

## geoecu 0.3.0

CRAN release: 2026-10-22

- Primera versión enviada a CRAN.
- `DESCRIPTION` en inglés, con el título también en español.
- Los ejemplos ya no usan `\dontrun{}`.

## geoecu 0.2.1

- Se documenta la fuente de las geometrías: cartografía de libre acceso
  del Geoportal del Instituto Geográfico Militar (IGM) del Ecuador.
- README: aclaración de que geoecu es un paquete independiente.

## geoecu 0.2.0

- Nuevas funciones
  [`reubicar_galapagos()`](https://f-slg.github.io/geoecu/reference/reubicar_galapagos.md)
  y
  [`marco_galapagos()`](https://f-slg.github.io/geoecu/reference/marco_galapagos.md)
  para mapas nacionales: trasladan Galápagos a la esquina superior
  izquierda, junto al continente, y devuelven un recuadro para
  dibujarlo. Funcionan con los tres niveles y con capas unidas con
  [`geoecu_unir()`](https://f-slg.github.io/geoecu/reference/geoecu_unir.md).
- README: instrucciones para instalar `sf` rápidamente en Linux.

## geoecu 0.1.0

- Primera versión.
- [`read_provincias()`](https://f-slg.github.io/geoecu/reference/read_dpa.md),
  [`read_cantones()`](https://f-slg.github.io/geoecu/reference/read_dpa.md)
  y
  [`read_parroquias()`](https://f-slg.github.io/geoecu/reference/read_dpa.md)
  con filtros por nombre o código, resolución `"baja"`/`"alta"` y cambio
  de sistema de coordenadas.
- [`geoecu_unir()`](https://f-slg.github.io/geoecu/reference/geoecu_unir.md)
  para unir datos propios con las capas por código DPA.
- Catálogo `dpa` (1262 parroquias, 221 cantones, 24 provincias) y
  utilidades
  [`buscar_dpa()`](https://f-slg.github.io/geoecu/reference/buscar_dpa.md),
  [`formatear_codigo()`](https://f-slg.github.io/geoecu/reference/formatear_codigo.md)
  y
  [`normalizar_nombre()`](https://f-slg.github.io/geoecu/reference/normalizar_nombre.md).
- Descarga con caché desde los releases de GitHub (`datos-v0.1.0`) y uso
  de archivos locales con
  [`geoecu_usar_carpeta()`](https://f-slg.github.io/geoecu/reference/geoecu_usar_carpeta.md).
