#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# geoecu · Paso 1: simplificación topológica y construcción de niveles
#
# Parte de la capa ORGANIZACION_TERRITORIAL_PARROQUIAL de la Organización
# Territorial del Estado (CONALI, Ministerio de Gobierno; datos abiertos,
# licencia CC BY, EPSG:32717) y construye cantones y provincias disolviendo
# por código DPA. Así los tres niveles encajan exactamente (sin huecos ni
# traslapes).
#
# Se excluye el polígono sin código numérico ("ISLA"). Las zonas en estudio se
# conservan con sus códigos para que el mapa nacional no tenga huecos.
#
# Requisitos: Node.js y mapshaper (npm install -g mapshaper)
# Uso:        bash data-raw/01_simplificar.sh ruta/a/ORGANIZACION_TERRITORIAL_PARROQUIAL.shp
# Salida:     data-raw/build/{alta,baja}/{provincias,cantones,parroquias}.json
# -----------------------------------------------------------------------------
set -euo pipefail

ENTRADA="${1:?Indica la ruta a ORGANIZACION_TERRITORIAL_PARROQUIAL.shp}"
SALIDA="data-raw/build"
MS="${MAPSHAPER:-mapshaper-xl}"

construir () {
  local resolucion="$1" tolerancia="$2" precision="$3"
  mkdir -p "$SALIDA/$resolucion"
  $MS -i "$ENTRADA" encoding=utf8 name=parroquias \
    -filter 'DPA_PARROQ != "ISLA"' \
    -clean \
    -simplify interval="$tolerancia" keep-shapes planar \
    -dissolve DPA_CANTON copy-fields=DPA_DESCAN,DPA_PROVIN,DPA_DESPRO + name=cantones \
    -dissolve DPA_PROVIN copy-fields=DPA_DESPRO target=parroquias + name=provincias \
    -proj wgs84 target=* \
    -o "$SALIDA/$resolucion/" format=geojson precision="$precision" target=*
}

# alta: tolerancia de 10 m (análisis espacial)
construir alta 10 0.000001
# baja: tolerancia de 250 m (mapas, tableros Shiny)
construir baja 250 0.00001
