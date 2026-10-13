# Cómo publicar geoecu en GitHub

Este archivo es solo una guía para ti; no forma parte del paquete (está en
`.Rbuildignore`). Puedes borrarlo después de publicar.

## 1. Usuario de GitHub

Ya está configurado como `f-slg` en `DESCRIPTION`, `README.md` y `R/zzz.R`.

## 2. Crea el repositorio y sube el código

Crea un repositorio **vacío** llamado `geoecu` en <https://github.com/new>
(sin README ni licencia, porque ya vienen en el paquete). Luego:

```bash
cd geoecu
git init
git add .
git commit -m "geoecu 0.1.0"
git branch -M main
git remote add origin https://github.com/f-slg/geoecu.git
git push -u origin main
```

## 3. Publica los datos como release

Las geometrías **no** van en el repositorio (el `.gitignore` excluye los
`.gpkg`): se publican como archivos adjuntos de un release, y el paquete los
descarga desde ahí.

**Desde la web:** en tu repositorio ve a *Releases → Draft a new release*.

- **Tag:** `datos-v0.1.0` (tiene que ser exactamente este, porque es el que
  busca el paquete).
- **Título:** `Datos geoecu 0.1.0`.
- **Adjuntos:** arrastra `geoecu_dpa_baja.gpkg` y `geoecu_dpa_alta.gpkg`.
- Publica.

**O con la terminal** (si tienes `gh` instalado):

```bash
gh release create datos-v0.1.0 geoecu_dpa_baja.gpkg geoecu_dpa_alta.gpkg \
  --title "Datos geoecu 0.1.0" \
  --notes "Provincias, cantones y parroquias del Ecuador (DPA). Fuente: MSP."
```

## 4. Prueba

```r
remotes::install_github("f-slg/geoecu")
library(geoecu)
geoecu_limpiar_cache()
plot(sf::st_geometry(read_provincias()))
```

Si aún no quieres publicar los datos, el repositorio puede ser público igual:
cada usuario puede apuntar a sus propios archivos con
`geoecu_usar_carpeta()`.

## Actualizar los datos en el futuro

1. Corre `data-raw/01_simplificar.sh` y `data-raw/02_construir_datos.R` con la
   nueva capa.
2. Cambia `.geoecu_version_datos` en `R/zzz.R` (por ejemplo, a
   `datos-v0.2.0`).
3. Publica un release nuevo con ese tag y los nuevos `.gpkg`.

Así las versiones anteriores del paquete siguen funcionando con sus datos.
