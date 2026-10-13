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
