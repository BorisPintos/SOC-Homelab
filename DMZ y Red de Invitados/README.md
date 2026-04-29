# 🔀 Segmentación de Red — DMZ y Red de Invitados

> **Contexto:** Ejercicio realizado sobre el homelab virtualizado ([ver infraestructura base](../README.md)). OPNsense ya estaba operativo como firewall perimetral con interfaces WAN y LAN. Se añaden dos segmentos de red adicionales para replicar una topología corporativa real.

**Objetivo:** Ampliar la topología del firewall OPNsense con dos interfaces nuevas — **DMZ** (zona desmilitarizada para servicios expuestos) y **Guest** (red de invitados aislada) — aplicando reglas de firewall que permitan el acceso a internet pero bloqueen el acceso a la LAN interna.

---

## 1 · Asignación de Interfaces en OPNsense

Se añadieron dos adaptadores de red adicionales a la VM de OPNsense en VirtualBox y se asignaron como nuevas interfaces en el panel `Interfaces > Assignments`.

| Interfaz | Identificador | Dispositivo (MAC) |
|---|---|---|
| `[WAN]` | `wan` | em0 (08:00:27:1e:41:8d) |
| `[LAN]` | `lan` | em1 (08:00:27:c6:b2:1e) |
| `[Guest]` | `opt1` | em2 (08:00:27:ed:7d:8d) |
| `[DMZ]` | `opt2` | em3 (08:00:27:7d:35:ab) |

![Interfaces asignadas en OPNsense — WAN, LAN, Guest y DMZ](Interfaces%20asignadas.png)

---

## 2 · Configuración de Subredes

Cada interfaz requiere su propia subred para segmentar el tráfico. Durante la configuración de la interfaz DMZ se produjo un error al introducir la dirección de red (`x.x.x.0`) en lugar de la dirección de host del gateway (`x.x.x.1`), lo que OPNsense detecta y rechaza correctamente.

![Configuración de subred en la interfaz DMZ — error por usar dirección de red](Asignando%20Subnets.png)

*Este comportamiento de validación de OPNsense previene errores de configuración de red. La dirección asignada a la interfaz debe ser siempre una dirección de host válida dentro de la subred, nunca la dirección de red en sí.*

---

## 3 · Reglas de Firewall — Red de Invitados (Guest)

Se configuraron dos reglas en la interfaz **Guest** para definir su política de acceso:

- **DENY ACCESS TO LAN** — bloquea el acceso de la red Guest a `LAN net` y `LAN address`, impidiendo que los invitados alcancen los recursos internos.
- **ALLOW INTERNET** — permite a `Guest net` y `Guest address` alcanzar cualquier destino externo.

![Reglas de firewall aplicadas en la interfaz Guest](Reglas%20firewall%20Guest.png)

| Regla | Acción | Origen | Destino | Descripción |
|---|---|---|---|---|
| 1 | ❌ Block | Guest net, Guest address | LAN net, LAN address | DENY ACCESS TO LAN |
| 2 | ✅ Pass | Guest net, Guest address | Any | ALLOW INTERNET |

---

## 4 · Reglas de Firewall — Zona DMZ

Política equivalente aplicada en la interfaz **DMZ**, añadiendo también `This Firewall` como destino bloqueado para impedir que los servicios DMZ accedan a la propia interfaz del firewall:

- **DENY ACCESS TO LAN** — bloquea el tráfico DMZ hacia `This Firewall`, `LAN net` y `LAN address`.
- **ALLOW INTERNET** — permite a `DMZ net` y `DMZ address` alcanzar destinos externos.

![Reglas de firewall aplicadas en la interfaz DMZ](Reglas%20firewall%20DMZ.png)

| Regla | Acción | Origen | Destino | Descripción |
|---|---|---|---|---|
| 1 | ❌ Block | DMZ net, DMZ address | This Firewall, LAN net, LAN address | DENY ACCESS TO LAN |
| 2 | ✅ Pass | DMZ net, DMZ address | Any | ALLOW INTERNET |

---

## 5 · Validación de Conectividad

Con un equipo ubicado en el segmento Guest/DMZ se verificó que las reglas funcionan correctamente:

- **Ping a `8.8.8.8`** → exitoso — el acceso a internet está permitido.
- **Ping a `192.168.1.x`** (LAN) → 100% packet loss — el aislamiento de la LAN funciona.

![Validación de conectividad — internet OK, LAN bloqueada](Validacion%20conectividad.png)

*Esta prueba confirma el funcionamiento de las reglas en ambas direcciones: salida a internet operativa y aislamiento completo de la red interna. Es la verificación equivalente a un test de penetración básico para validar la segmentación de red.*

---

## Topología resultante

```
OPNsense 26.1.2
├── WAN  (em0) ── Internet
├── LAN  (em1) ── Red corporativa interna (192.168.1.x)
│                  └── SRV-DC01, PC1-USUARIO
├── Guest (em2) ─ Red de invitados
│                  ✅ Internet   ❌ LAN
└── DMZ   (em3) ─ Zona desmilitarizada
                   ✅ Internet   ❌ LAN   ❌ This Firewall
```

---

## Stack utilizado

| Tecnología | Rol |
|---|---|
| OPNsense 26.1.2 (FreeBSD) | Firewall perimetral y router |
| Oracle VirtualBox | Hipervisor (adaptadores de red adicionales) |
| Firewall Rules (OPNsense) | Segmentación y control de acceso entre segmentos |

---

<div align="center">

**[← Volver al laboratorio principal](../README.md)**

</div>
