# geoecu: capas geográficas de la DPA del Ecuador

Provincias, cantones y parroquias del Ecuador con códigos DPA, listos
para mapear y unir con datos propios.

## Details

### Funciones principales

- [`read_provincias()`](https://f-slg.github.io/geoecu/reference/read_dpa.md),
  [`read_cantones()`](https://f-slg.github.io/geoecu/reference/read_dpa.md)
  y
  [`read_parroquias()`](https://f-slg.github.io/geoecu/reference/read_dpa.md)
  devuelven objetos `sf` con los límites de cada nivel.

- [`geoecu_unir()`](https://f-slg.github.io/geoecu/reference/geoecu_unir.md)
  une una tabla propia (por ejemplo, casos o tasas) con la capa
  correspondiente usando el código DPA.

- [dpa](https://f-slg.github.io/geoecu/reference/dpa.md) es el catálogo
  de códigos y nombres;
  [`buscar_dpa()`](https://f-slg.github.io/geoecu/reference/buscar_dpa.md)
  busca en él.

- [`formatear_codigo()`](https://f-slg.github.io/geoecu/reference/formatear_codigo.md)
  y
  [`normalizar_nombre()`](https://f-slg.github.io/geoecu/reference/normalizar_nombre.md)
  limpian códigos y nombres antes de unir tablas.

### Datos

Las geometrías no vienen dentro del paquete: se descargan la primera vez
desde los releases del repositorio en GitHub y se guardan en caché
([`geoecu_cache_dir()`](https://f-slg.github.io/geoecu/reference/geoecu_cache_dir.md)).
También puedes usar archivos locales con
[`geoecu_usar_carpeta()`](https://f-slg.github.io/geoecu/reference/geoecu_usar_carpeta.md).

## See also

Useful links:

- <https://github.com/f-slg/geoecu>

- Report bugs at <https://github.com/f-slg/geoecu/issues>

## Author

**Maintainer**: Ronald Fabricio Salas Guerrero
<fabriciosalasguerrero@gmail.com> \[copyright holder\]
