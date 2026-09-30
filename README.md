# Ritmo — rastreador de hábitos para iPhone

Proyecto de inicio nativo SwiftUI, iOS 17+, SwiftData, MVVM y UserNotifications. Idioma de interfaz: español.

## Abrir en Xcode (Mac)

1. Instala Xcode 15 o posterior y [XcodeGen](https://github.com/yonaskolb/XcodeGen). Si usas Homebrew: `brew install xcodegen`.
2. Descomprime el ZIP. Abre Terminal en la carpeta `Ritmo` y ejecuta `xcodegen generate`.
3. Abre `Ritmo.xcodeproj` en Xcode, selecciona un simulador iPhone con iOS 17 o posterior y pulsa ▶ **Run**.
4. Para usar un iPhone físico o distribuir la app, configura tu equipo de firma en el target y cambia `cl.matiascastro.ritmo` por un identificador propio en `project.yml`; luego vuelve a ejecutar `xcodegen generate`.

El ícono de App Store queda pendiente de crear en `Assets.xcassets/AppIcon.appiconset`.

## Estructura y orden de implementación

| Etapa | Archivos | Decisión |
| --- | --- | --- |
| 1. Design System | `DesignSystem/Theme.swift`, `Heatmap.swift` | Los cinco colores exactos, superficies translúcidas, tipografía del sistema, anillos y puntos mensuales. Fondo oscuro inicial y contraste claro alternativo. |
| 2. Modelos | `Models/Habit.swift` | SwiftData local. Un registro numérico por hábito y fecha; frecuencia diaria, semanal o días elegidos. |
| 3. Estado y métricas | `ViewModels/HabitViewModel.swift`, `Services/HabitMetrics.swift` | Escrituras encapsuladas; tasas basadas en días programados desde la creación; racha de días programados consecutivos. |
| 4. Pantallas | `Views/*.swift` | Inicio con tarjetas y anillo, detalle con tres meses, calendario, comparación, notas, alta, configuración y onboarding de tres pasos. |
| 5. Avisos | `Services/ReminderService.swift` | Avisos locales por hábito; segundo aviso opcional, cancelación al completar y reprogramación al abrir la app. |

## Alcance y límites

- Las notificaciones son **locales**, no push remotas. El sistema programa una ventana móvil de siete días con un máximo de 60 solicitudes propias, para respetar el límite de iOS; la ventana se renueva cuando se abre la app o se registra un avance. Si la app no se abre durante más de siete días, los avisos futuros no se programarán hasta la siguiente apertura. Para producción conviene adoptar un esquema híbrido de avisos recurrentes o BackgroundTasks, sujeto a las restricciones de iOS.
- El segundo aviso se programa si el hábito está pendiente al sincronizar; se cancela al registrar la meta en la app. El sistema no puede comprobar silenciosamente el estado justo antes de entregar una notificación sin ejecutar la app.
- Los datos permanecen en el dispositivo; no hay cuenta, sincronización, widget ni Apple Health en este primer alcance.
- `NotesView` guarda un borrador de texto con AppStorage. En una versión posterior conviene modelar varias notas en SwiftData.
- Aquí no se dispone de Xcode ni del simulador de iOS; el código y el proyecto deben compilarse y revisarse en un Mac antes de distribución.

## Branding

**Ritmo**: cálido, sencillo y relacionado con la constancia. Alternativas: **Pulso** (energía y progreso), **Brío** (impulso diario), **Chispa** (inicio de una acción). Dirección de ícono: círculo rojo `#F10222` con un arco incompleto y un punto rosa `#FFCAD0` sobre fondo `#250202`; evitar texto pequeño.
