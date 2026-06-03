# Hotel Luxury Moonsea — Especificación Completa de App Móvil
> Instrucción maestra para construcción con Flutter + Firebase | No orientada a producción

---

## Visión General

Construir una aplicación móvil de reservas hoteleras llamada **Hotel Luxury Moonsea**, con tres roles de usuario: huésped no registrado, huésped registrado y administrador. La app no es para producción; prioriza funcionalidad clara, código limpio y una UI/UX coherente.

**Stack tecnológico:**
- Framework: Flutter (Dart)
- Backend / Auth / DB: Firebase (Firestore, Authentication, Storage)
- Estado: Provider o Riverpod (a elección del desarrollador)
- Paleta: Rojo primario `#C0392B`, rojo oscuro `#922B21`, blanco `#FFFFFF`, gris claro `#F5F5F5`, gris texto `#333333`

---

## Arquitectura de Proyecto

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── constants/         # colores, strings, rutas
│   ├── theme/             # ThemeData global
│   └── utils/             # helpers de fecha, formato, validaciones
├── data/
│   ├── models/            # clases Dart que mapean Firestore
│   └── services/          # FirebaseAuth, FirestoreService, StorageService
├── features/
│   ├── auth/              # login, register, splash
│   ├── home/              # pantalla principal del huésped
│   ├── rooms/             # catálogo y detalle de habitaciones
│   ├── reservations/      # crear, ver, cancelar reservas
│   ├── profile/           # perfil del huésped
│   └── admin/             # panel de administrador (CRUD completo)
└── widgets/               # componentes compartidos
```

---

## Base de Datos — Colecciones Firestore

### `users`
```
users/{uid}
  ├── uid: String
  ├── name: String
  ├── email: String
  ├── phone: String
  ├── role: String           // "guest" | "admin"
  ├── photoUrl: String?
  └── createdAt: Timestamp
```

### `rooms`
```
rooms/{roomId}
  ├── roomId: String
  ├── name: String           // "Suite Presidencial", "Doble Estándar"
  ├── type: String           // "suite" | "double" | "single" | "family"
  ├── description: String
  ├── pricePerNight: double
  ├── capacity: int
  ├── amenities: List<String>   // ["WiFi", "TV", "Jacuzzi", ...]
  ├── imageUrls: List<String>
  ├── isAvailable: bool
  └── floor: int
```

### `reservations`
```
reservations/{reservationId}
  ├── reservationId: String
  ├── userId: String
  ├── roomId: String
  ├── roomName: String        // desnormalizado para lectura rápida
  ├── guestName: String
  ├── checkIn: Timestamp
  ├── checkOut: Timestamp
  ├── nights: int
  ├── totalPrice: double
  ├── status: String          // "pending" | "confirmed" | "cancelled" | "completed"
  ├── adults: int
  ├── children: int
  ├── specialRequests: String?
  └── createdAt: Timestamp
```

### `services`
```
services/{serviceId}
  ├── serviceId: String
  ├── name: String            // "Desayuno", "Spa", "Transfer aeropuerto"
  ├── description: String
  ├── price: double
  ├── category: String        // "food" | "wellness" | "transport" | "other"
  ├── imageUrl: String?
  └── isActive: bool
```

---

## Flujo de Navegación

```
SplashScreen
└── HomePublic (sin auth)
    ├── → RegisterScreen
    │     └── → HomeGuest (tras registro exitoso)
    ├── → LoginScreen
    │     ├── → HomeGuest (rol: guest)
    │     └── → AdminDashboard (rol: admin)
    └── → RoomCatalog (solo lectura, sin reservar)
```

**Rutas nombradas** (usar `GoRouter` o `Navigator 2.0`):
```
/                → SplashScreen
/home            → HomePublic
/register        → RegisterScreen
/login           → LoginScreen
/rooms           → RoomCatalogScreen
/rooms/:id       → RoomDetailScreen
/reservations/new → CreateReservationScreen
/reservations    → MyReservationsScreen
/reservations/:id → ReservationDetailScreen
/profile         → ProfileScreen
/admin           → AdminDashboard
/admin/rooms     → AdminRoomsScreen
/admin/reservations → AdminReservationsScreen
/admin/users     → AdminUsersScreen
/admin/services  → AdminServicesScreen
```

---

## Pantallas — Especificación Detallada

### 1. SplashScreen
- Logo "H" grande centrado (tipografía serif)
- Texto "HOTEL" en cursiva + "LUXURY MOONSEA" debajo
- Fondo blanco, sin animación compleja
- Lógica: esperar `FirebaseAuth.authStateChanges()` y redirigir según rol o a `/home`

### 2. HomePublic (pantalla inicial — como la imagen adjunta)
- Logo centrado arriba
- Tres botones rojos de ancho completo con bordes redondeados:
  - **REGÍSTRATE** → `/register`
  - **INICIAR SESIÓN** → `/login`
  - **ADMINISTRADOR** → `/login` (mismo login, diferencia por rol)
- Fondo gris muy claro `#F2F2F2`
- Botón ADMINISTRADOR en rojo más oscuro `#922B21`

### 3. RegisterScreen
Formulario con:
- Nombre completo (TextField)
- Email (TextField, teclado email)
- Teléfono (TextField, teclado número)
- Contraseña (TextField, obscureText, toggle visibilidad)
- Confirmar contraseña
- Botón **REGISTRARSE** rojo
- Link "¿Ya tienes cuenta? Inicia sesión"

Validaciones:
- Email válido
- Contraseña mínimo 6 caracteres
- Las contraseñas coinciden
- Campos no vacíos

Lógica Firebase:
```dart
await FirebaseAuth.instance.createUserWithEmailAndPassword(...)
// Luego crear documento en users/{uid} con role: "guest"
```

### 4. LoginScreen
- Email + Contraseña
- Botón **INICIAR SESIÓN**
- Link "¿Olvidaste tu contraseña?" → `sendPasswordResetEmail`
- Link "Crear cuenta"
- Al login, leer `users/{uid}.role` y redirigir:
  - `guest` → `/home-guest`
  - `admin` → `/admin`

### 5. HomeGuest
AppBar con:
- Nombre del usuario (saludo: "Bienvenido, {name}")
- Icono de notificaciones y perfil

Contenido (scroll):
- **Banner destacado**: imagen de header del hotel con overlay rojo semitransparente y texto "Reserva tu experiencia perfecta"
- **Sección "Habitaciones Destacadas"**: ListView horizontal de cards (3-4 habitaciones)
- **Sección "Nuestros Servicios"**: Grid 2x2 de servicios (íconos + nombre)
- **Sección "Mis Próximas Reservas"**: Lista compacta de las próximas reservas del usuario (máx 3, con botón "Ver todas")

BottomNavigationBar con 4 tabs:
- Inicio (home icon)
- Habitaciones (bed icon)
- Mis Reservas (calendar icon)
- Perfil (person icon)

### 6. RoomCatalogScreen
- AppBar: "Habitaciones"
- Filtros horizontales: chips por tipo (Suite, Doble, Individual, Familiar)
- Lista vertical de `RoomCard`:
  - Imagen (NetworkImage con placeholder)
  - Nombre + tipo
  - Precio por noche (destacado en rojo)
  - Capacidad (icono personas)
  - Amenidades resumidas (máx 3 chips)
  - Botón "Ver más" → `RoomDetailScreen`

### 7. RoomDetailScreen
- Hero image con botón back
- Nombre de habitación (h2 bold)
- Precio por noche destacado
- Descripción completa
- Galería de imágenes (PageView con dots)
- Sección "Amenidades": chips con ícono
- Capacidad y piso
- Botón fijo en la parte baja: **RESERVAR AHORA** (solo visible si el usuario está autenticado; si no, muestra "Inicia sesión para reservar")

### 8. CreateReservationScreen
Formulario de reserva:
- Fecha de check-in (DatePicker)
- Fecha de check-out (DatePicker)
- Cálculo automático de noches y precio total
- Número de adultos (stepper +/-)
- Número de niños (stepper +/-)
- Solicitudes especiales (TextField multilínea, opcional)
- Resumen de la reserva (card): habitación, fechas, noches, precio total
- Botón **CONFIRMAR RESERVA**

Validaciones:
- Check-out posterior al check-in
- Capacidad total ≤ `room.capacity`
- Fechas no en el pasado

Lógica:
- Verificar disponibilidad: buscar reservas activas de esa habitación que se solapen con las fechas elegidas
- Crear documento en `reservations/` con `status: "pending"`

### 9. MyReservationsScreen
Tabs: **Próximas** | **Historial** | **Canceladas**

Cada `ReservationCard`:
- Nombre de habitación
- Fechas check-in / check-out
- Total pagadero
- Badge de estado (color semántico: azul=pendiente, verde=confirmada, gris=completada, rojo=cancelada)
- Botón "Ver detalle" → `ReservationDetailScreen`

### 10. ReservationDetailScreen
- Todos los datos de la reserva
- Estado con badge grande
- Botón **CANCELAR RESERVA** (visible solo si `status == "pending"` o `"confirmed"` y `checkIn` es en el futuro)
- Al cancelar: `status = "cancelled"`, mostrar AlertDialog de confirmación

### 11. ProfileScreen
- Avatar con iniciales o foto (editable via Firebase Storage)
- Nombre, email, teléfono (editable)
- Botón **GUARDAR CAMBIOS**
- Sección "Cuenta": Cambiar contraseña, Cerrar sesión

---

## Panel de Administrador

### AdminDashboard
Pantalla principal con 4 tarjetas de acceso rápido en Grid 2x2:
- 🛏 Habitaciones
- 📅 Reservaciones
- 👥 Usuarios
- ⭐ Servicios

Además, barra de estadísticas en la parte superior:
- Total reservas activas
- Habitaciones ocupadas hoy
- Ingresos del mes (suma de `totalPrice` de reservas `confirmed`)

### AdminRoomsScreen — CRUD Habitaciones
**Lista**: cada item muestra imagen, nombre, precio, badge disponible/no disponible, íconos de editar y eliminar.

**Crear/Editar** (BottomSheet o nueva ruta):
- Todos los campos de `rooms`
- Subir imágenes a Firebase Storage (`rooms/{roomId}/image_N.jpg`)
- Lista editable de amenidades (chips con botón eliminar + campo agregar)
- Switch de disponibilidad

**Eliminar**: AlertDialog de confirmación + `deleteDoc`.

### AdminReservationsScreen — CRUD Reservas
Lista completa con filtros:
- Por estado (dropdown)
- Por fecha (DateRangePicker)
- Búsqueda por nombre de huésped

Cada item: huésped, habitación, fechas, estado (editable via dropdown), total.

**Editar estado**: cambiar `status` directamente desde la lista (DropdownButton inline).

**Crear reserva manual**: mismo formulario que el huésped, pero el admin puede seleccionar cualquier usuario o ingresar nombre libre.

**Eliminar**: solo si `status == "cancelled"`.

### AdminUsersScreen — CRUD Usuarios
Lista de todos los usuarios con:
- Avatar inicial, nombre, email, rol, fecha registro

**Editar**: nombre, teléfono, rol (guest/admin).
**Eliminar**: solo usuarios con `role: "guest"` (no se puede eliminar admins desde la app).

Nota: no se puede cambiar contraseña de otros usuarios desde cliente por limitaciones de Firebase Auth. Mostrar nota informativa.

### AdminServicesScreen — CRUD Servicios
Lista de servicios con imagen, nombre, precio, categoría, toggle activo/inactivo.

**Crear/Editar**: todos los campos del modelo `services` + subida de imagen.

**Eliminar**: con confirmación.

---

## Tema y Estilos Globales

```dart
// lib/core/theme/app_theme.dart

class AppTheme {
  static const Color primaryRed   = Color(0xFFC0392B);
  static const Color darkRed      = Color(0xFF922B21);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color lightGray    = Color(0xFFF5F5F5);
  static const Color textDark     = Color(0xFF333333);
  static const Color textMuted    = Color(0xFF777777);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryRed,
      primary: primaryRed,
      onPrimary: white,
      surface: white,
      background: lightGray,
    ),
    scaffoldBackgroundColor: lightGray,
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      foregroundColor: textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: white,
        minimumSize: Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFDDDDDD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFFDDDDDD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryRed, width: 2),
      ),
    ),
    cardTheme: CardTheme(
      color: white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
```

---

## Widgets Reutilizables

Crear los siguientes widgets en `lib/widgets/`:

| Widget | Descripción |
|---|---|
| `PrimaryButton` | Botón rojo ancho completo, con loading state |
| `RoomCard` | Card de habitación para catálogo (imagen, nombre, precio) |
| `ReservationCard` | Card de reserva con badge de estado |
| `StatusBadge` | Badge coloreado según status string |
| `SectionTitle` | Título de sección con línea roja decorativa |
| `LoadingOverlay` | Overlay de carga semitransparente |
| `ConfirmDialog` | AlertDialog reutilizable de confirmación |
| `EmptyState` | Ilustración + texto cuando no hay datos |
| `AdminCrudTile` | ListTile con íconos de editar/eliminar para admin |

---

## Reglas de Seguridad Firestore (Básicas)

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Usuarios: solo el propio usuario o admin pueden leer/escribir
    match /users/{userId} {
      allow read: if request.auth != null &&
        (request.auth.uid == userId || isAdmin());
      allow write: if request.auth != null &&
        (request.auth.uid == userId || isAdmin());
    }

    // Habitaciones: todos pueden leer, solo admin puede escribir
    match /rooms/{roomId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // Reservas: usuario propietario o admin
    match /reservations/{resId} {
      allow read: if request.auth != null &&
        (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
        (resource.data.userId == request.auth.uid || isAdmin());
    }

    // Servicios: todos leen, solo admin escribe
    match /services/{serviceId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid))
        .data.role == 'admin';
    }
  }
}
```

---

## Datos Semilla (Seed Data)

Crear un script o ejecutar una vez en la app de administrador para poblar:

**Habitaciones de ejemplo:**
1. Suite Presidencial — $350/noche — capacidad 2 — piso 10
2. Suite Junior — $220/noche — capacidad 2 — piso 8
3. Habitación Doble Deluxe — $140/noche — capacidad 3 — piso 4
4. Habitación Doble Estándar — $95/noche — capacidad 2 — piso 2
5. Habitación Individual — $70/noche — capacidad 1 — piso 2
6. Habitación Familiar — $180/noche — capacidad 5 — piso 6

**Servicios de ejemplo:**
1. Desayuno buffet — $18/persona — categoría food
2. Spa & Masajes — $80/sesión — categoría wellness
3. Transfer aeropuerto — $45 — categoría transport
4. Room service 24h — $0 (incluido) — categoría food
5. Gimnasio — $0 (incluido) — categoría wellness

**Usuario admin de ejemplo:**
- Email: admin@moonsea.com
- Password: admin123456
- role: "admin"
*(Crear manualmente en Firebase Console y en Firestore)*

---

## Flujo de Disponibilidad de Habitaciones

Al crear una reserva, ejecutar esta query antes de guardar:

```dart
Future<bool> checkAvailability({
  required String roomId,
  required DateTime checkIn,
  required DateTime checkOut,
}) async {
  final query = await FirebaseFirestore.instance
      .collection('reservations')
      .where('roomId', isEqualTo: roomId)
      .where('status', whereIn: ['pending', 'confirmed'])
      .get();

  for (final doc in query.docs) {
    final existingCheckIn  = (doc['checkIn']  as Timestamp).toDate();
    final existingCheckOut = (doc['checkOut'] as Timestamp).toDate();

    // Hay solapamiento si: nueva checkIn < existente checkOut
    //                   Y nueva checkOut > existente checkIn
    if (checkIn.isBefore(existingCheckOut) &&
        checkOut.isAfter(existingCheckIn)) {
      return false; // No disponible
    }
  }
  return true; // Disponible
}
```

---

## Consideraciones Finales

- **No hay pasarela de pago**: el total se muestra pero el pago es presencial. El estado inicial siempre es `"pending"`.
- **Imágenes**: usar URLs de Unsplash para habitaciones en el seed (hardcodeado está bien para demo).
- **Manejo de errores**: mostrar `SnackBar` con mensaje descriptivo en cada operación Firebase.
- **Offline**: no requiere soporte offline; si Firestore lanza error de red, mostrar mensaje claro.
- **Idioma**: toda la UI en español.
- **Orientación**: solo portrait (configurar en `AndroidManifest.xml` y `Info.plist`).
- **Target**: Android mínimo API 21, iOS mínimo 12.0.

---

*Documento generado como instrucción maestra para construcción de Hotel Luxury Moonsea App.*
