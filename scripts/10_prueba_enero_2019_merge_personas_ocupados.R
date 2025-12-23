# Objetivo: construir base mensual (Enero 2019) de mujeres ocupadas,
# uniendo Personas + Ocupados, resolviendo duplicados y dejando variables clave.

library(data.table)

# ---- 0) Ruta del mes ----
month_dir <- "data_raw/geih/2019/Enero"

# ---- 1) Función: lee un módulo (Área/Cabecera/Resto) y apila ----
leer_modulo_mes <- function(month_dir, patron_modulo) {
  files <- list.files(month_dir, pattern = patron_modulo, full.names = TRUE)
  if (length(files) == 0) {
    stop("No encontré archivos con patrón: ", patron_modulo,
         "\nRuta usada: ", month_dir,
         "\nRevisa nombres con: list.files(month_dir)")
  }
  
  lst <- lapply(files, function(f) {
    dt <- fread(f, showProgress = FALSE)
    dt[, dominio := sub(" - .*", "", basename(f))]  # Área/Cabecera/Resto
    dt
  })
  
  rbindlist(lst, use.names = TRUE, fill = TRUE)
}

# ---- 2) Leer módulos clave ----
# OJO: si tus archivos tienen tildes o texto distinto, ajusta el patrón
personas <- leer_modulo_mes(month_dir, "Caracter")   # Características generales (Personas)
ocupados <- leer_modulo_mes(month_dir, "Ocupados")

# ---- 3) Definir llaves ----
# Para unir módulos: NO usamos REGIS (no es común entre módulos para match exacto)
llave_merge <- c("DIRECTORIO", "SECUENCIA_P", "ORDEN")

# Verificación rápida de llaves
stopifnot(all(llave_merge %in% names(personas)))
stopifnot(all(llave_merge %in% names(ocupados)))

# ---- 4) Resolver duplicados: 1 fila por persona en PERSONAS y en OCUPADOS ----
# Definimos "persona" como DIRECTORIO + SECUENCIA_P + ORDEN
# Si existe REGIS, ordenamos por REGIS y tomamos el primer registro.

if ("REGIS" %in% names(personas)) {
  setorder(personas, DIRECTORIO, SECUENCIA_P, ORDEN, REGIS)
} else {
  setorder(personas, DIRECTORIO, SECUENCIA_P, ORDEN)
}
personas_1 <- personas[, .SD[1], by = llave_merge]

if ("REGIS" %in% names(ocupados)) {
  setorder(ocupados, DIRECTORIO, SECUENCIA_P, ORDEN, REGIS)
} else {
  setorder(ocupados, DIRECTORIO, SECUENCIA_P, ORDEN)
}
ocupados_1 <- ocupados[, .SD[1], by = llave_merge]

# ---- 5) Merge: solo ocupadas (inner join) ----
dt <- merge(personas_1, ocupados_1, by = llave_merge, all = FALSE, suffixes = c("_per","_ocu"))

# ---- 6) Construir variables clave ----
# Sexo y edad (confirmados en tu dt: P6020 y P6040)
stopifnot(all(c("P6020", "P6040") %in% names(dt)))

# Horas trabajadas: P6800 (confirmado)
stopifnot("P6800" %in% names(dt))

dt[, `:=`(
  anio = 2019L,
  mes  = 1L,
  sexo = as.integer(P6020),
  edad = as.integer(P6040),
  horas_trab = as.numeric(P6800)
)]

# Factor de expansión: en tu dt aparece como fex_c_2011_per y fex_c_2011_ocu
# Usamos el de personas por defecto
if ("fex_c_2011_per" %in% names(dt)) {
  dt[, factor_exp := as.numeric(fex_c_2011_per)]
} else if ("fex_c_2011_ocu" %in% names(dt)) {
  dt[, factor_exp := as.numeric(fex_c_2011_ocu)]
} else {
  warning("No encontré factor de expansión en dt (fex_c_2011_per / fex_c_2011_ocu).")
  dt[, factor_exp := NA_real_]
}

# IDs simples
dt[, `:=`(
  id_hogar   = paste0(DIRECTORIO, "_", SECUENCIA_P),
  id_persona = paste0(DIRECTORIO, "_", SECUENCIA_P, "_", ORDEN)
)]

# ---- 7) Filtrar: mujeres 18–65 ----
dt <- dt[sexo == 2 & edad >= 18 & edad <= 65]

# ---- 8) Chequeos finales ----
cat("\nFilas finales (mujeres 18-65 ocupadas): ", nrow(dt), "\n")

# Debe ser 0 duplicados por persona (llave_merge)
dup_final <- dt[, .N, by = llave_merge][N > 1]
cat("Duplicados por persona (esperado 0): ", nrow(dup_final), "\n")

cat("\nResumen horas_trab (P6800):\n")
print(summary(dt$horas_trab))

cat("\nResumen factor_exp:\n")
print(summary(dt$factor_exp))

# ---- 9) Guardar salida ----
dir.create("data_int", showWarnings = FALSE)
fwrite(dt, "data_int/geih_2019_01_mujeres_ocupadas.csv")
cat("\nGuardado: data_int/geih_2019_01_mujeres_ocupadas.csv\n")
