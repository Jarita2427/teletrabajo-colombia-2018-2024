library(data.table)

# Ruta a la carpeta
month_dir <- "data_raw/geih/2019/Enero"

leer_modulo_mes <- function(month_dir, patron_modulo) {
  files <- list.files(month_dir, pattern = patron_modulo, full.names = TRUE)
  
  if (length(files) == 0) {
    stop("No encontré archivos con patrón: ", patron_modulo,
         "\nRevisa la ruta month_dir = ", month_dir,
         "\nY revisa el patrón (patron_modulo).")
  }
  
  lst <- lapply(files, function(f) {
    dt <- fread(f, showProgress = FALSE)
    dt[, dominio := sub(" - .*", "", basename(f))]  # "Área", "Cabecera", "Resto"
    dt
  })
  
  rbindlist(lst, use.names = TRUE, fill = TRUE)
}

# 1) Personas (Características generales)
personas <- leer_modulo_mes(month_dir, "Caracteristicas generales")

# 2) Ocupados
ocupados <- leer_modulo_mes(month_dir, "Ocupados")

# 3) Llaves de merge esperadas
candidatas_llave <- c("DIRECTORIO", "SECUENCIA_P", "ORDEN", "REGIS")

cat("\nLlaves en personas:\n")
print(intersect(names(personas), candidatas_llave))

cat("\nLlaves en ocupados:\n")
print(intersect(names(ocupados), candidatas_llave))

if (!all(candidatas_llave %in% names(personas))) {
  stop("En PERSONAS no están todas las llaves: ", paste(candidatas_llave, collapse = ", "))
}
if (!all(candidatas_llave %in% names(ocupados))) {
  stop("En OCUPADOS no están todas las llaves: ", paste(candidatas_llave, collapse = ", "))
}

# 4) Merge por persona
dt <- merge(
  personas,
  ocupados,
  by = candidatas_llave,
  all.x = TRUE,
  suffixes = c("_per", "_ocu")
)

# 5) Chequeos
cat("\nFilas personas:", nrow(personas), "\n")
cat("Filas ocupados:", nrow(ocupados), "\n")
cat("Filas merge dt:", nrow(dt), "\n")

cat("\nPrimeras columnas de dt:\n")
print(names(dt)[1:30])

cat("\nVista rápida llaves:\n")
print(head(dt[, ..candidatas_llave]))

# 6) Guardar output de prueba
dir.create("data_int", showWarnings = FALSE)
fwrite(dt, "data_int/enero_2019_personas_ocupados_merge.csv")
cat("\nGuardado: data_int/enero_2019_personas_ocupados_merge.csv\n")
