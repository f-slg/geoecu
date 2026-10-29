# Comprueba que los seis ejemplos de la galería del README sean
# autónomos, se puedan interpretar y produzcan mapas sin errores.
#
# Uso desde la raíz del repositorio:
#   Rscript data-raw/06_validar_readme.R
#
# Requiere geoecu, ggplot2, patchwork, pobecu y GeoPackages disponibles o internet.
stopifnot(
  requireNamespace("geoecu", quietly = TRUE),
  requireNamespace("ggplot2", quietly = TRUE),
  requireNamespace("patchwork", quietly = TRUE),
  requireNamespace("pobecu", quietly = TRUE)
)

lineas <- readLines("README.md", warn = FALSE, encoding = "UTF-8")
comienzos <- grep("^### [1-6][.] ", lineas)

if (length(comienzos) != 6L) {
  stop("Se esperaban seis ejemplos cartográficos en el README.")
}

for (i in seq_along(comienzos)) {
  ini <- comienzos[[i]]
  siguientes <- c(comienzos[comienzos > ini], grep("^## ", lineas))
  siguientes <- siguientes[siguientes > ini]
  fin <- if (length(siguientes)) min(siguientes) - 1L else length(lineas)
  bloque <- lineas[ini:fin]
  apertura <- grep("^\x60\x60\x60r$", bloque)
  if (length(apertura) != 1L) {
    stop("El ejemplo ", i, " debe tener un único bloque de código R.")
  }
  despues <- bloque[(apertura + 1L):length(bloque)]
  cierre <- match("\x60\x60\x60", despues)
  if (is.na(cierre)) stop("Falta cierre de código en el ejemplo ", i)

  codigo <- despues[seq_len(cierre - 1L)]
  expresiones <- parse(text = codigo)
  grafico <- tempfile(pattern = paste0("geoecu-", i, "-"), fileext = ".pdf")

  grDevices::pdf(grafico, width = 10.5, height = 8, onefile = TRUE)
  tryCatch(
    eval(expresiones, envir = new.env(parent = .GlobalEnv)),
    finally = grDevices::dev.off()
  )
  if (!file.exists(grafico) || file.size(grafico) < 1000L) {
    stop("El ejemplo ", i, " no generó una figura válida.")
  }
  message("Mapa ", i, ": OK (", round(file.size(grafico) / 1024),
          " KB PDF)")
  unlink(grafico)
}

message("Los seis ejemplos del README se ejecutaron correctamente.")
