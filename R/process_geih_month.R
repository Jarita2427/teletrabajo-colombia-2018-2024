# ------------------------------------------------------------
# Procesamiento mensual GEIH (2018-2024) con soporte de 2 formatos:
#   - 2018-2019: módulos separados en Área/Cabecera/Resto (3 CSV por módulo)
#   - 2020+: un CSV por módulo (sin dominios)
#
# Construye base mensual de personas ocupadas (Personas + Ocupados),
# deduplicando por persona, creando variables clave y filtrando mujeres 18-65.
# ------------------------------------------------------------

library(data.table)

# ---- Helpers: meses ----
month_to_int <- function(x) {
  m <- tolower(x)
  mapa <- c(
    "enero" = 1, "febrero" = 2, "marzo" = 3, "abril" = 4, "mayo" = 5, "junio" = 6,
    "julio" = 7, "agosto" = 8, "septiembre" = 9, "setiembre" = 9,
    "octubre" = 10, "noviembre" = 11, "diciembre" = 12
  )
  if (!m %in% names(mapa)) stop("Mes no reconocido: ", x)
  unname(mapa[[m]])
}

# ---- Helpers: inferir año/mes desde carpeta ----
# Soporta:
#   - ".../2024/Mayo_2024"   -> mes=5, anio=2024
#   - ".../2019/Enero"       -> mes=1, anio=2019 (infiriendo anio desde carpeta padre)
#   - ".../2019/Abril_2019"  -> mes=4, anio=2019
infer_year_month <- function(month_dir, anio = NULL, mes = NULL) {
  base <- basename(month_dir)
  
  # Caso Mes_YYYY
  parts <- strsplit(base, "_")[[1]]
  if (length(parts) >= 2 && grepl("^\\d{4}$", parts[length(parts)])) {
    yr <- as.integer(parts[length(parts)])
    mn <- month_to_int(parts[1])
    return(list(anio = yr, mes = mn))
  }
  
  # Caso solo Mes (Enero, Febrero...)
  parent <- basename(dirname(month_dir))
  if (grepl("^\\d{4}$", parent)) {
    yr <- as.integer(parent)
    mn <- month_to_int(base)
    return(list(anio = yr, mes = mn))
  }
  
  # Fallback: si el usuario pasó anio/mes manualmente
  if (!is.null(anio) && !is.null(mes)) {
    return(list(anio = as.integer(anio), mes = as.integer(mes)))
  }
  
  stop("No pude inferir (anio, mes) desde: ", month_dir,
       "\nPásame anio y mes manualmente o revisa el nombre de la carpeta.")
}

# ---- Files: filtrar CSV ----
list_csv_files <- function(month_dir) {
  list.files(month_dir, pattern = "\\.csv$", full.names = TRUE, ignore.case = TRUE)
}

# ---- Encontrar archivos por módulo (regex) con exclusión opcional ----
find_module_files <- function(month_dir, module_regex, exclude_regex = NULL) {
  all_files <- list_csv_files(month_dir)
  hits <- all_files[grepl(module_regex, basename(all_files), ignore.case = TRUE)]
  
  if (!is.null(exclude_regex) && length(hits) > 0) {
    hits <- hits[!grepl(exclude_regex, basename(hits), ignore.case = TRUE)]
  }
  
  hits
}

# ---- Leer módulo soportando ambos formatos ----
# Formato B (2018-2019): Área/Cabecera/Resto - <módulo>
# Formato A (2020+): un archivo por módulo (ej. "Ocupados.csv")
leer_modulo_mes <- function(month_dir, module_regex, exclude_regex = NULL) {
  files <- find_module_files(month_dir, module_regex, exclude_regex)
  
  if (length(files) == 0) {
    stop("No encontré archivos para módulo: ", module_regex,
         "\nCarpeta: ", month_dir)
  }
  
  # Detectar si existen archivos con prefijo Área/Cabecera/Resto
  has_dom <- any(grepl("^(Área|Cabecera|Resto)\\s*-", basename(files), ignore.case = TRUE))
  
  if (has_dom) {
    files_dom <- files[grepl("^(Área|Cabecera|Resto)\\s*-", basename(files), ignore.case = TRUE)]
    lst <- lapply(files_dom, function(f) {
      dt <- fread(f, showProgress = FALSE)
      dt[, dominio := sub(" - .*", "", basename(f))] # Área/Cabecera/Resto
      dt
    })
    return(rbindlist(lst, use.names = TRUE, fill = TRUE))
  }
  
  # Formato A: uno (o varios) archivos del módulo -> apilar por seguridad
  lst <- lapply(files, function(f) {
    dt <- fread(f, showProgress = FALSE)
    dt[, dominio := "Total"]
    dt
  })
  rbindlist(lst, use.names = TRUE, fill = TRUE)
}

# ---- Deduplicación 1 fila por persona usando REGIS si existe ----
dedup_by_person <- function(dt, llave_persona = c("DIRECTORIO","SECUENCIA_P","ORDEN")) {
  stopifnot(all(llave_persona %in% names(dt)))
  
  if ("REGIS" %in% names(dt)) {
    setorder(dt, DIRECTORIO, SECUENCIA_P, ORDEN, REGIS)
  } else {
    setorder(dt, DIRECTORIO, SECUENCIA_P, ORDEN)
  }
  
  dt[, .SD[1], by = llave_persona]
}

# ---- Selección flexible de variable (elige la primera disponible) ----
pick_first_existing <- function(dt, candidates) {
  found <- candidates[candidates %in% names(dt)]
  if (length(found) == 0) return(NA_character_)
  found[1]
}

# ============================================================
# Función principal
# ============================================================
process_geih_month <- function(month_dir, anio = NULL, mes = NULL,
                               filter_women_18_65 = TRUE) {
  ym <- infer_year_month(month_dir, anio, mes)
  anio <- ym$anio
  mes  <- ym$mes
  
  # 1) Leer módulos esenciales
  # Personas: en 2024 es "Características generales, seguridad socia..." -> matchea "Caracter"
  personas <- leer_modulo_mes(month_dir, module_regex = "Caracter")
  
  # Ocupados: en 2024 existe "No ocupados" -> hay que excluirlo
  ocupados <- leer_modulo_mes(
    month_dir,
    module_regex  = "\\bOcupados\\b",
    exclude_regex = "No\\s+ocupados"
  )
  
  llave <- c("DIRECTORIO","SECUENCIA_P","ORDEN")
  stopifnot(all(llave %in% names(personas)))
  stopifnot(all(llave %in% names(ocupados)))
  
  # 2) Deduplicar por persona en ambos módulos
  personas_1 <- dedup_by_person(personas, llave)
  ocupados_1 <- dedup_by_person(ocupados, llave)
  
  # 3) Merge: solo ocupadas (inner join)
  dt <- merge(
    personas_1,
    ocupados_1,
    by = llave,
    all = FALSE,
    suffixes = c("_per","_ocu")
  )
  
  # 4) Variables base (sexo/edad/horas) con mapeo por formatos
  # Sexo:
  #  - 2018-2019 suele ser P6020
  #  - 2020+ (en tu diccionario 2023/2024) es P3271 (sexo al nacer)
  sexo_var <- pick_first_existing(dt, c("P6020", "P3271"))
  if (is.na(sexo_var)) {
    stop("No encontré variable de sexo (probé P6020 y P3271) en: ", month_dir)
  }
  
  # Edad
  edad_var <- pick_first_existing(dt, c("P6040"))
  if (is.na(edad_var)) {
    stop("No encontré variable de edad (P6040) en: ", month_dir)
  }
  
  # Horas: en tus ejemplos existe P6800
  horas_var <- pick_first_existing(dt, c("P6800", "P6810", "P6850"))
  if (is.na(horas_var)) {
    stop("No encontré variable de horas (probé P6800/P6810/P6850) en: ", month_dir)
  }
  
  # 5) Factor de expansión (varía por formato/año)
  fex_var <- pick_first_existing(dt, c(
    "FEX_C18_per","FEX_C18_ocu","FEX_C18",
    "FEX_C_per","FEX_C_ocu","FEX_C",
    "fex_c_2011_per","fex_c_2011_ocu","fex_c_2011"
  ))
  # Si no existe, queda NA (pero avisa)
  if (is.na(fex_var)) {
    warning("No encontré factor de expansión típico en: ", month_dir, " (factor_exp quedará NA).")
  }
  
  # 6) Crear variables estandarizadas
  dt[, `:=`(
    anio = as.integer(anio),
    mes  = as.integer(mes),
    sexo = as.integer(get(sexo_var)),
    edad = as.integer(get(edad_var)),
    horas_trab = as.numeric(get(horas_var)),
    factor_exp = if (!is.na(fex_var)) as.numeric(get(fex_var)) else NA_real_,
    id_hogar   = paste0(DIRECTORIO, "_", SECUENCIA_P),
    id_persona = paste0(DIRECTORIO, "_", SECUENCIA_P, "_", ORDEN)
  )]
  
  # 7) Filtros
  # (si sexo == 2 es femenino tanto para P6020 como para P3271, como viste en el diccionario)
  if (filter_women_18_65) {
    dt <- dt[sexo == 2 & edad >= 18 & edad <= 65]
  } else {
    dt <- dt[edad >= 18 & edad <= 65]
  }
  
  # 8) Chequeo duplicados por persona
  dups <- dt[, .N, by = llave][N > 1]
  if (nrow(dups) > 0) {
    warning("Quedaron duplicados por persona (", nrow(dups), ") en: ", month_dir)
  }
  
  return(dt)
}
