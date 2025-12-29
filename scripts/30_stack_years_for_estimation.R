library(data.table)
library(fst)

# Años a apilar
anios <- 2018:2024

# Leer y apilar
lst <- list()
faltantes <- character()

for (yy in anios) {
  f <- file.path("data_int", paste0("geih_mujeres_ocupadas_", yy, ".fst"))
  if (!file.exists(f)) {
    faltantes <- c(faltantes, f)
    next
  }
  message("Leyendo: ", f)
  lst[[as.character(yy)]] <- fst::read_fst(f, as.data.table = TRUE)
}

if (length(faltantes) > 0) {
  message("Archivos faltantes (no se apilaron):")
  print(faltantes)
}

panel <- rbindlist(lst, use.names = TRUE, fill = TRUE)

# Guardar panel completo para estimación
dir.create("data_out", showWarnings = FALSE)
out_path <- file.path("data_out", "geih_mujeres_ocupadas_2018_2024.fst")
fst::write_fst(panel, out_path)

message("Panel listo -> ", out_path)
message("Filas totales: ", nrow(panel))
message("Años en panel: ", paste(sort(unique(panel$anio)), collapse = ", "))
