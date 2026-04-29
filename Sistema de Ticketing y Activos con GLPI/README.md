# 🎫 ITSM & Gestión de Activos con GLPI

> **Contexto:** Ejercicio realizado sobre el homelab virtualizado ([ver infraestructura base](../README.md)). El laboratorio ya contaba con un Domain Controller (`SRV-DC01`) en `homelab.local` y un servidor Ubuntu con Wazuh desplegado.

**Objetivo:** Desplegar GLPI como plataforma central de gestión de servicios IT, integrarlo con Active Directory mediante LDAP, inventariar los activos del entorno y demostrar el ciclo completo de resolución de tickets de soporte técnico.

---

## 1 · Instalación de GLPI + Apache2 — Gestión de Conflicto de Puerto

GLPI fue instalado sobre **Apache2** en el servidor Ubuntu. Al coexistir con el stack de **Wazuh** — que ya ocupaba el puerto 80 —, fue necesario reconfigurar Apache para escuchar en el puerto **8080**, evitando el conflicto y manteniendo ambos servicios operativos simultáneamente.

| Archivo modificado | Cambio aplicado |
|---|---|
| `/etc/apache2/ports.conf` | `Listen 80` → `Listen 8080` |
| `/etc/apache2/sites-enabled/000-default.conf` | `<VirtualHost *:80>` → `<VirtualHost *:8080>` |

![Edición de ports.conf — Apache2 escuchando en puerto 8080](Instalamos%20GLPI%20y%20apache2_como%20tenemos%20wazuh%20instalado%20cambiamos%20el%20puerto%20(1).png)

![Edición del VirtualHost en 000-default.conf al puerto 8080](Tambien%20cambiamos%20el%20puerto%20de%20GLPI.png)

*La coexistencia de múltiples servicios web en el mismo servidor es un escenario habitual en producción. Identificar el conflicto y resolverlo editando la configuración de Apache2 desde la terminal es una habilidad cotidiana de administración Linux.*

---

## 2 · Integración con Active Directory vía LDAP

Configuración del conector **LDAP** en GLPI apuntando al Domain Controller (`SRV-DC01`), permitiendo autenticar usuarios corporativos directamente desde Active Directory — sin gestión de credenciales duplicadas.

| Parámetro | Valor |
|---|---|
| Nombre del directorio | `AD Homelab` |
| Servidor LDAP | `10.0.0.5` (SRV-DC01) |
| Puerto | `389` (LDAP estándar) |
| BaseDN | `DC=homelab,DC=local` |
| RootDN | `CN=BorisAdmin,CN=Users,DC=homelab,DC=local` |

![Configuración del directorio LDAP — AD Homelab en GLPI](Sincronizando%20GPLI%20con%20el%20servidor.png)

![Prueba de conexión LDAP exitosa — Servidor principal AD Homelab](Prueba%20exitosa%20con%20GLPI.png)

*La integración LDAP cierra el ciclo de identidad del laboratorio: un único directorio centralizado (Active Directory) gobierna el acceso al DC, las GPOs y el sistema ITSM. Este patrón de autenticación unificada replica exactamente cómo funciona en entornos empresariales reales.*

---

## 3 · Inventario de Activos del Laboratorio

Registro y catalogación de los equipos del homelab en el módulo **Activos** de GLPI, con tipo, fabricante, número de serie y sistema operativo — información esencial para la gestión del ciclo de vida del hardware.

![Dashboard del módulo Activos de GLPI](GLPI%20menu.png)

| Activo | Tipo | Fabricante | Número de serie | S.O. |
|---|---|---|---|---|
| `SRV-DC01` | Servidor | VirtualBox | `SN-WS2022-001` | Windows Server 2022 |
| `PC1-USUARIO` | Sobremesa | — | — | — |

![Lista de ordenadores inventariados — SRV-DC01 y PC1-USUARIO](GLPI%20activos.png)

*Un inventario actualizado es el punto de partida de cualquier gestión IT madura: permite asociar tickets a activos concretos, planificar sustituciones de hardware y demostrar cobertura ante auditorías de cumplimiento.*

---

## 4 · Gestión y Resolución de Tickets de Soporte

Demostración del flujo completo de **Help Desk** en GLPI: apertura de una incidencia, registro de intervenciones sucesivas y documentación de la resolución — replicando el workflow ITIL de un departamento IT real.

![Flujo de resolución de ticket de soporte en GLPI](GLPI%20resolucion%20de%20tickets.png)

*El ciclo de vida del ticket en GLPI — apertura → intervenciones → resolución — es el flujo operativo diario de cualquier equipo de soporte. La trazabilidad completa de fechas, estados y agentes es fundamental para cumplir SLAs y analizar el rendimiento del servicio.*

---

## Stack utilizado

| Tecnología | Rol |
|---|---|
| GLPI | Plataforma ITSM (ticketing + inventario) |
| Apache2 | Servidor web (puerto 8080) |
| Ubuntu Linux | Sistema operativo del servidor |
| LDAP (puerto 389) | Protocolo de integración con AD |
| Active Directory | Directorio de usuarios (`homelab.local`) |

---

<div align="center">

**[← Volver al laboratorio principal](../README.md)**

</div>
