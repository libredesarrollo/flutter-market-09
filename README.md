# Tienda App - Flutter & Redux Modernized

Este es un proyecto de ejemplo de una tienda en línea construida con **Flutter** utilizando la arquitectura **Redux** para el manejo del estado global. El proyecto ha sido modernizado para cumplir con los estándares actuales de Flutter (Null Safety, Material 3, etc.).

## 📖 Recursos y Referencias

Este repositorio forma parte de los siguientes recursos educativos:

- 📘 **Libro**: [Primeros pasos en Flutter](https://www.desarrollolibre.net/libros/primeros-pasos-flutter)
- 🎓 **Curso**: [Curso de Flutter desde cero creandó más de 10 proyectos](https://www.desarrollolibre.net/blog/flutter/curso-de-flutter-desde-cero-creando-mas-de-10-proyectos)

## ✨ Características

- **Arquitectura Redux**: Manejo de estado centralizado para productos, carrito y usuario.
- **Modernizado**: Actualizado a Flutter 3+ con soporte para Full Null Safety.
- **Material 3**: Implementación de temas modernos y ColorScheme.
- **Autenticación**: Registro e inicio de sesión integrados con Strapi (o backend local).
- **Gestión de Carrito**: Agregar, remover y cambiar cantidades con sincronización de estado.
- **Favoritos**: Marcar productos como favoritos.

## 🚀 Instalación y Uso

1. **Clonar el repositorio**:
   ```bash
   git clone <url-del-repo>
   ```

2. **Obtener dependencias**:
   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

> [!NOTE]
> La aplicación está configurada por defecto para conectarse a un servidor local en `http://10.0.2.2:1337` (configuración estándar para emuladores Android). Asegúrate de tener el backend corriendo si deseas probar la persistencia de datos.

## 🛠️ Tecnologías Utilizadas

- **Flutter**: Framework UI multiplataforma.
- **flutter_redux**: Integración de Redux con Flutter.
- **redux_thunk**: Middleware para acciones asíncronas.
- **Shared Preferences**: Persistencia de datos del usuario localmente.
- **HTTP**: Comunicación con el backend.

---
Desarrollado con ❤️ para la comunidad de [Desarrollo Libre](https://www.desarrollolibre.net).
