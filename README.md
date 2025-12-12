**Resumen del proyecto**

El proyecto analiza cómo la **teletrabajabilidad ocupacional** se relaciona con las **horas trabajadas** y los **tiempos de cuidado no remunerado** de las mujeres en Colombia entre 2018 y 2024. La idea central es distinguir entre ocupaciones con **alta** y **baja posibilidad de teletrabajo** y estudiar cómo estas se ven afectadas por dos grandes cambios recientes: la pandemia de COVID-19 y la entrada en vigor de la **Ley 2191 de 2022** sobre derecho a la desconexión laboral.

Para ello se utilizarán microdatos de la **Gran Encuesta Integrada de Hogares (GEIH)** del DANE (2018–2024), a partir de los cuales se construirá un panel de mujeres ocupadas con información sobre ocupación, horas trabajadas, características sociodemográficas y laborales. Sobre este panel se asignará un **índice de teletrabajabilidad por ocupación**, adaptado de la literatura internacional, y se implementará una estrategia de **diferencias en diferencias (DiD)** para estimar el efecto diferencial de la teletrabajabilidad antes y después de la pandemia y de la Ley 2191.

Complementariamente, se emplearán los microdatos de la **Encuesta Nacional de Uso del Tiempo (ENUT)** para estudiar la asociación entre teletrabajabilidad y **tiempos de cuidado y trabajo doméstico no remunerado** en las mujeres, a través de análisis descriptivos y modelos de regresión. El objetivo general es aportar evidencia empírica sobre las tensiones entre flexibilidad laboral, carga de trabajo y distribución del cuidado, en un contexto de cambios acelerados en la organización del trabajo y la regulación de la desconexión laboral en Colombia.

**Salida esperada para el semillero**

Un conjunto de scripts reproducibles en R (con control de versiones en Git), un dataset limpio de GEIH y ENUT con variables de teletrabajabilidad, varias tablas y gráficos de resultados, y un documento corto con la síntesis de la metodología y los principales hallazgos empíricos.

##  Metodología

- **Datos:** GEIH–DANE (ocupación, ingresos, educación, formalidad, región), IPC base 2018.  
- **Variable clave:** índice de teletrabajabilidad (0–1) por ocupación, adaptado de Dingel & Neiman.  
- **Diseño:** diferencias-en-diferencias (DiD) con interacción `Teletrabajable × Post-2020`.  
- **Controles:** edad, educación, género, formalidad.  
- **Efectos fijos:** ocupación/sector, mes-año, región.  
- **Robustez:** índice continuo, submuestras urbanas, cuantiles salariales, event study.

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
