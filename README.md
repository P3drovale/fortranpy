# 🌀 FYPP - Traductor Fortran a Python

[![License](https://img.shields.io/badge/license-Educational-blue.svg)](LICENSE)
[![Language](https://img.shields.io/badge/language-C%2FFlex%2FBison-orange.svg)]()
[![Fortran](https://img.shields.io/badge/input-Fortran%2090-purple.svg)]()
[![Python](https://img.shields.io/badge/output-Python%203-green.svg)]()

**FYPP** (Fortran to pYthon Parser) es un traductor automático que convierte código Fortran 90 a Python 3, facilitando la modernización de código científico legado. Desarrollado con **Flex**, **Bison/Yacc** y **C** para máximo rendimiento y precisión.

## ✨ Características

- 🔄 **Traducción automática** de Fortran 90 a Python 3
- 📊 **Cobertura del 60%** de sintaxis Fortran común
- 🚀 **Alto rendimiento** con analizadores compilados
- 🛠️ **Facilidad de uso** con scripts de automatización
- 🔍 **Diagnóstico detallado** de errores con línea y columna
- 📦 **Conversión en lote** de múltiples archivos

## 📁 Estructura del Proyecto

```
fypp/
├── src/
│   ├── lexer.l          # Analizador léxico (Flex)
│   ├── parser.y         # Analizador sintáctico (Bison)
│   ├── main.c           # Punto de entrada
│   └── functions.c      # Funciones auxiliares
├── scripts/
│   ├── build.sh         # Script de compilación
│   └── convertir_todos.sh # Conversión en lote
├── examples/
│   ├── fermat.f90       # Programa de ejemplo
│   └── fermat.py        # Resultado de traducción
├── docs/
│   └── manual.md        # Manual de usuario
└── README.md
```

## 🔧 Instalación

### Requisitos del Sistema

- **SO**: Linux, macOS, WSL (Windows), o Cygwin
- **Compiladores**: GCC 4.8+
- **Herramientas**: Flex 2.5+, Bison 3.0+
- **Librerías**: libm (matemáticas)

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install flex bison gcc build-essential
```

### CentOS/RHEL/Fedora
```bash
sudo yum install flex bison gcc make
# o para Fedora:
sudo dnf install flex bison gcc make
```

### macOS
```bash
brew install flex bison gcc
```

## 🏗️ Compilación

### Método Rápido (Recomendado)
```bash
chmod +x scripts/build.sh
./scripts/build.sh
```

### Compilación Manual
```bash
# Generar analizador sintáctico
bison -d src/parser.y

# Generar analizador léxico
flex src/lexer.l

# Compilar ejecutable
gcc -o fypp parser.tab.c lex.yy.c src/main.c src/functions.c -lm

# Limpiar archivos temporales
rm -f parser.tab.c parser.tab.h lex.yy.c
```

## 🚀 Uso

### Conversión Individual
```bash
./fypp <archivo_entrada.f90> <archivo_salida.py>
```

**Ejemplo:**
```bash
./fypp examples/fermat.f90 output/fermat.py
```

### Conversión en Lote
Para convertir todos los archivos `.f90` del directorio actual:
```bash
chmod +x scripts/convertir_todos.sh
./scripts/convertir_todos.sh
```

### Opciones de Línea de Comandos
```bash
./fypp [opciones] <entrada.f90> <salida.py>

Opciones:
  -v, --verbose    Mostrar información detallada del proceso
  -h, --help       Mostrar esta ayuda
  --version        Mostrar versión del traductor
```

## 📊 Características Soportadas

### ✅ Totalmente Soportado
- **Variables**: `integer`, `real`, `logical`, `character`
- **Estructuras de control**: `if/then/else`, `do while`, `do...end do`
- **Operadores**: aritméticos, relacionales, lógicos
- **E/O básica**: `read`, `print`, `write`
- **Funciones matemáticas**: `exp`, `sin`, `cos`, `sqrt`

### 🔶 Parcialmente Soportado
- **Arrays**: declaración y acceso básico
- **Subrutinas**: conversión a funciones Python
- **Módulos**: conversión simplificada

### ❌ No Soportado (Aún)
- **Tipos derivados**
- **Interfaz de procedimientos**
- **Paralelización (OpenMP)**
- **E/O avanzada de archivos**

## 📝 Ejemplo de Traducción

### Código Fortran Original
```fortran
program potencia
    implicit none
    integer :: n, total, x, y, z
    
    print *, "Ingrese el exponente:"
    read(*,*) n
    
    total = 3
    do while (total <= 100)
        do x = 1, total - 2
            do y = 1, total - x - 1
                z = total - x - y
                if (x**n + y**n == z**n) then
                    print *, "Contraejemplo encontrado:", x, y, z
                    stop
                end if
            end do
        end do
        total = total + 1
    end do
    
    print *, "No se encontró contraejemplo hasta", total-1
end program potencia
```

### Código Python Generado
```python
import math

def main():
    print("Ingrese el exponente:")
    n = int(input())
    
    total = 3
    while total <= 100:
        for x in range(1, total - 2 + 1):
            for y in range(1, total - x - 1 + 1):
                z = total - x - y
                if (x ** n + y ** n == z ** n):
                    print("Contraejemplo encontrado:", x, y, z)
                    return
        total = total + 1
    
    print("No se encontró contraejemplo hasta", total-1)

if __name__ == "__main__":
    main()
```

## 🐛 Solución de Problemas

### Error: "No se genera archivo .py"
```bash
# Verificar permisos
chmod +x fypp

# Ejecutar con verbose para más información
./fypp -v input.f90 output.py
```

### Error: "Comando no encontrado"
```bash
# Verificar que el ejecutable esté en PATH o usar ruta completa
./fypp archivo.f90 salida.py
```

### Errores de Sintaxis
El traductor reportará errores con formato:
```
Error de sintaxis en línea 15, columna 8: token inesperado 'entonces'
Sugerencia: use 'then' en lugar de 'entonces'
```

## 🧪 Testing

### Ejecutar Tests
```bash
# Compilar en modo debug
./scripts/build.sh --debug

# Ejecutar suite de pruebas
./scripts/run_tests.sh
```

### Agregar Nuevos Tests
1. Crear archivo `.f90` en `tests/input/`
2. Crear archivo `.py` esperado en `tests/expected/`
3. Ejecutar `./scripts/run_tests.sh --update`

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Por favor:

1. **Fork** el repositorio
2. Crea una **rama** para tu feature (`git checkout -b feature/nueva-caracteristica`)
3. **Commit** tus cambios (`git commit -am 'Agregar nueva característica'`)
4. **Push** a la rama (`git push origin feature/nueva-caracteristica`)
5. Crea un **Pull Request**

### Guías de Contribución
- Seguir el estilo de código existente
- Agregar tests para nuevas características
- Actualizar documentación según sea necesario
- Usar commits descriptivos

## 📚 Documentación Adicional

- [Manual de Usuario](docs/manual.md)
- [Guía de Desarrollo](docs/development.md)
- [Referencia de API](docs/api.md)
- [Casos de Uso](docs/use-cases.md)

## 🏆 Créditos

Desarrollado por [Tu Nombre] como parte de [Proyecto/Institución].

Agradecimientos especiales a:
- Comunidad de Flex/Bison
- Proyectos de referencia en traducción de lenguajes
- Usuarios beta que proporcionaron retroalimentación

## 📄 Licencia

Este proyecto está licenciado bajo la **Licencia Educativa** - ver el archivo [LICENSE](LICENSE) para más detalles.

```
Copyright (c) 2024 [Tu Nombre]

Este software puede ser usado con fines educativos y de investigación.
Para uso comercial, contactar al autor para obtener permisos.
```

## 🔗 Enlaces Útiles

- [Documentación de Flex](https://github.com/westes/flex)
- [Manual de Bison](https://www.gnu.org/software/bison/manual/)
- [Referencia Fortran 90](https://www.fortran90.org/)
- [Guía de Migración Python](https://docs.python.org/3/howto/porting.html)

---

<div align="center">

**⭐ Si este proyecto te resulta útil, considera darle una estrella ⭐**

[Reportar Bug](https://github.com/tu-usuario/fypp/issues) · [Solicitar Feature](https://github.com/tu-usuario/fypp/issues) · [Discusiones](https://github.com/tu-usuario/fypp/discussions)

</div>