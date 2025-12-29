library(data.table)
library(fst)

source("R/process_geih_month.R")

anio_objetivo <- 2020L
year_dir <- file.path("data_raw", "geih", as.character(anio_objetivo))

month_dirs <- list.dirs(year_dir, recursive = FALSE, full.names = TRUE)

lst <- list()
fallos <- data.table(mes_dir = character(), error = character())

for (md in month_dirs) {
  message("Procesando: ", md)
  out <- tryCatch(
    process_geih_month(md),
    error = function(e) e
  )
  
  if (inherits(out, "error")) {
    fallos <- rbind(fallos, data.table(mes_dir = basename(md), error = conditionMessage(out)))
  } else {
    lst[[basename(md)]] <- out
  }
}

geih_year <- rbindlist(lst, use.names = TRUE, fill = TRUE)

dir.create("data_int", showWarnings = FALSE)

out_path <- file.path("data_int", paste0("geih_mujeres_ocupadas_", anio_objetivo, ".fst"))
fst::write_fst(geih_year, out_path)

message("Listo -> ", out_path)
message("Filas totales: ", nrow(geih_year))

if (nrow(fallos) > 0) {
  print(fallos)
  fwrite(fallos, file.path("logs", paste0("fallos_build_", anio_objetivo, ".csv")))
  message("Log de fallos -> logs/fallos_build_", anio_objetivo, ".csv")
}
message("Proceso completado.")