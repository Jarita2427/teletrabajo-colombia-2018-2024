# Esquema dataset final – GEIH mujeres ocupadas 2018–2024

## Unidad de análisis

- **Unidad**: Mujer ocupada (18–65 años) observada en la GEIH.
- **Nivel temporal**: Año y mes de la encuesta (con opción de agrupar luego por año o año–trimestre).

## Variables clave (versión preliminar)

| Nombre          | Tipo        | Descripción                                             | Fuente (GEIH)             |
|----------------|------------|-----------------------------------------------------------|---------------------------|
| id_hogar       | entero     | Identificador del hogar                                   | IDs de la GEIH            |
| id_persona     | entero     | Identificador de la persona dentro del hogar              | IDs de la GEIH            |
| anio           | entero     | Año de la encuesta                                        | Variable de año           |
| mes            | entero     | Mes de la encuesta (1–12)                                 | Variable de mes           |
| factor_exp     | numérico   | Factor de expansión muestral                              | Factor de expansión       |
| edad           | entero     | Edad en años cumplidos (P6040, años)                      | Características generales |
| sexo           | entero     | Sexo (1 hombre, 2 mujer – P6020)                          | Características generales |
| horas_trab     | numérico   | Horas trabajadas a la semana (horas normales P6800)       | Módulo de ocupados        |
| educacion      | categórica | Nivel educativo máximo alcanzado                          | Educación                 |
| estado_civil   | categórica | Estado civil (soltera, unida/casada, etc.)                | Estado civil              |
| hijos_menores  | entero     | Nº de niños/as menores de cierta edad en el hogar         | Derivada de composición   |
| posicion_hogar | categórica | Jefa, cónyuge, hija, etc.                                 | Posición en el hogar      |
| area           | categórica | Urbano/rural                                              | Área                      |
| region         | categórica | Región / departamento                                     | Ubicación geográfica      |
| ocupacion_cod  | categórica | Código de ocupación (CNO/CIUO)                            | Módulo de ocupados        |
| rama_cod       | categórica | Código de rama de actividad económica                     | Módulo de ocupados        |
| tipo_contrato  | categórica | Tipo de vínculo (asalariada, cuenta propia, etc.)         | Módulo de ocupados        |
| formal         | entero     | Dummy de formalidad (1 = formal, 0 = informal)            | Derivada (regla DANE)     |

_Notas_:  
- En la GEIH, **P6020** se usa para sexo y **P6040** para edad.:contentReference[oaicite:0]{index=0}  
- Para horas normales trabajadas en el empleo principal se usa la variable **P6800**.:contentReference[oaicite:1]{index=1}  

## Variables derivadas para análisis

| Nombre              | Tipo        | Descripción                                                       |
|---------------------|------------|--------------------------------------------------------------------|
| post_pandemia       | entero     | 1 si año ≥ 2020, 0 si año < 2020                                 |
| post_ley2191        | entero     | 1 si año ≥ 2022, 0 si año < 2022                                 |
| indice_tele         | numérico   | Índice 0–1 de teletrabajabilidad de la ocupación                   |
| alta_tele           | entero     | 1 si ocupación en tercil superior de indice_tele, 0 tercil inferior|
| hijos_menores_dummy | entero     | 1 si hijos_menores > 0, 0 en caso contrario                        |
