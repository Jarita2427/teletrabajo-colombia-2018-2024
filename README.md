```markdown
# Teletrabajo y salarios reales en Colombia (2018–2025)

Este repositorio contiene el proyecto de investigación del semillero sobre el **impacto del teletrabajo en los salarios reales en Colombia durante el periodo 2018–2025**.  

El objetivo es evaluar, a partir de microdatos de la **GEIH–DANE** y el **IPC**, si la **teletrabajabilidad** de las ocupaciones está asociada con premios o penalidades en los salarios reales, y cómo varía por sector, género y región.

##Estructura del repositorio

teletrabajo-colombia-2018-2025/
├── data_raw/ # Microdatos originales (NO versionados, ignorados en .gitignore)
├── data_int/ # Datos procesados (ej. parquet con salarios reales, índice tele)
├── output/ # Tablas, gráficos y resultados exportados
├── r/ # Scripts R organizados por etapas
│ ├── 00_globals.R
│ ├── 01_clean_geih.R
│ ├── 02_tele_index.R
│ ├── 03_descriptivos.R
│ └── 04_did_models.R
├── docs/ # Notas metodológicas, bitácora, referencias
├── .gitignore
├── renv.lock # Estado de librerías para reproducibilidad
├── renv/ # Carpeta local de renv
└── teletrabajo-colombia-2018-2025.Rproj
---


````

---

##  Metodología

- **Datos:** GEIH–DANE (ocupación, ingresos, educación, formalidad, región), IPC base 2018.  
- **Variable clave:** índice de teletrabajabilidad (0–1) por ocupación, adaptado de Dingel & Neiman.  
- **Diseño:** diferencias-en-diferencias (DiD) con interacción `Teletrabajable × Post-2020`.  
- **Controles:** edad, educación, género, formalidad.  
- **Efectos fijos:** ocupación/sector, mes-año, región.  
- **Robustez:** índice continuo, submuestras urbanas, cuantiles salariales, event study.

---

##  Reproducibilidad

Este proyecto usa [`renv`](https://rstudio.github.io/renv/) para aislar librerías.  

- Para instalar el entorno en otro PC:
  ```r
  renv::restore()
````

* Para registrar cambios de paquetes:

  ```r
  renv::snapshot()
  ```

---

## Referencias clave

* Banco de la República (2025). *Informe de mercado laboral*.
* MinTIC (2021). *Informe de teletrabajo en Colombia*.
* OIT & OMS (2022). *Guía sobre teletrabajo saludable y seguro*.

---

## Autor

**Thomas Jaramillo Gómez**
Universidad Nacional de Colombia — Facultad de Ciencias Humanas y Económicas
Proyecto de Semillero de Estudios Aplicados a las Ciencias Sociales 
