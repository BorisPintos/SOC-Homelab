# 🏠 Enterprise Homelab — Boris Pintos

> Laboratorio virtualizado de infraestructura corporativa, automatización y seguridad defensiva construido sobre VirtualBox. Cada sección demuestra habilidades técnicas aplicadas en un entorno controlado que replica escenarios del mundo real.

---

## 🗺️ Arquitectura General del Laboratorio

```
                        ┌─────────────────────────────┐
                        │  OPNsense 26.1.2 (FreeBSD)  │
                        │  Firewall / Router Perimetral│
                        │  WAN: 10.0.0.102/8 (DHCP)   │
                        │  LAN: 192.168.1.1/24         │
                        └────────────┬────────────────-┘
                                     │
                    ┌────────────────┴────────────────┐
                    │         Red Interna (LAN)        │
                    └──────┬──────────────────┬────────┘
                           │                  │
          ┌────────────────┴──┐    ┌──────────┴───────────┐
          │ Windows Server 2022│    │    Ubuntu Linux       │
          │ Domain Controller  │    │  Managed via SSH      │
          │ AD · DNS · DHCP    │    │  192.168.x.x          │
          │ IP: 192.168.0.17   │    └──────────────────────┘
          └────────────────┬──┘
                           │
                  ┌────────┴──────────┐
                  │  Windows 11 Pro   │
                  │  PC1 (Cliente)    │
                  │  Unido a dominio  │
                  │  homelab.local    │
                  └───────────────────┘
```

---

## Área 1 — Windows Enterprise Infrastructure

> **Objetivo:** Desplegar y administrar una red corporativa aislada con gestión centralizada de usuarios, políticas de grupo y monitorización de rendimiento, replicando el stack tecnológico de un entorno Active Directory real.

### 1.1 · Controlador de Dominio en Windows Server 2022

El servidor actúa simultáneamente como **Domain Controller**, servidor **DNS** autoritativo y servidor **DHCP** para la red interna. La configuración de red es estática para garantizar la estabilidad del servicio de directorio.

| Parámetro       | Valor             |
|-----------------|-------------------|
| Rol principal   | AD DS + DNS       |
| IP estática     | `192.168.0.17`    |
| Subred          | `255.255.255.0`   |
| Gateway         | `192.168.0.1`     |
| DNS primario    | `192.168.0.17` (sí mismo) |
| DNS secundario  | `8.8.8.8`         |
| Nombre de dominio | `homelab.local` |

![Windows Server 2022 configurado con AD/DNS y IP estática](img/WS%20Configurado.png)

*Server Manager confirma el estado operativo del servidor. La ventana de propiedades IPv4 muestra la asignación de IP estática con el DC como su propio servidor DNS primario — práctica estándar en entornos Active Directory.*

---

### 1.2 · Integración de Cliente Windows 11 al Dominio

El equipo cliente `PC1` fue unido correctamente al dominio `homelab.local`, lo que valida el funcionamiento del controlador de dominio y la resolución DNS interna. Desde este punto, el equipo queda bajo la gestión centralizada de **Group Policy Objects (GPOs)**.

![Windows 11 unido al dominio homelab.local](img/Captura%20de%20PC%20unido%20a%20Dominio.png)

*La pantalla "Acerca de" de Windows 11 confirma la pertenencia al dominio. Este paso requiere que el DNS del cliente apunte al DC y que la comunicación de red entre ambas VMs esté correctamente enrutada.*

---

### 1.3 · Verificación de Conectividad — Intranet

Validación de conectividad extremo a extremo entre `PC1` y el servidor mediante **ICMP**, confirmando que el enrutamiento interno y la configuración de red son funcionales.

![CMD de PC1 mostrando ping exitoso al servidor](img/Captura%20CMD%20de%20pc1%20muestra%20conexion%20con%20el%20Servidor.png)

*La prueba de ping desde el cliente hacia la IP del controlador de dominio valida tres capas simultáneamente: la configuración de red de la VM, las reglas de firewall del servidor y el enrutamiento interno de VirtualBox.*

---

### 1.4 · Monitorización de Rendimiento con Performance Monitor

Uso de **Windows Performance Monitor** para analizar contadores de sistema en tiempo real: CPU, memoria, disco e I/O de red. Esta herramienta es esencial para el diagnóstico proactivo de cuellos de botella en entornos de servidor.

![Performance Monitor mostrando contadores en tiempo real](img/Perform%20Monitor.png)

*La monitorización continua de contadores de rendimiento es una práctica fundamental de operaciones (OPS) que permite detectar degradación del servicio antes de que impacte al usuario final.*

---

## Área 2 — Linux & Automatización

> **Objetivo:** Demostrar capacidad de scripting, administración remota segura y optimización del entorno de trabajo en Linux mediante la automatización de tareas repetitivas de Help Desk y el control estricto de permisos.

### 2.1 · Creación Masiva de Usuarios en Active Directory (PowerShell)

Aprovisionamiento automatizado de cuentas de usuario corporativas en la Unidad Organizativa `Empleados` del dominio `homelab.local`. Los usuarios (**Ana, Carlos, Contabilidad, David, Elena, Juan Perez, Sofia**) fueron creados mediante un script de **PowerShell** en lugar de hacerlo manualmente uno a uno, eliminando el error humano y reduciendo el tiempo de onboarding.

![Active Directory con la OU Empleados poblada por script de PowerShell](img/Captura%20empleados%20de%20Windows%20Server.png)

*La consola de Active Directory Users and Computers muestra la OU `Empleados` con todas las cuentas activas. Al fondo, PowerShell ISE evidencia el entorno de scripting utilizado. El DNS Manager confirma la zona de búsqueda directa `homelab.local` operativa.*

**Habilidades demostradas:** `New-ADUser`, iteración con `ForEach`, gestión de OUs, atributos de cuenta (nombre, contraseña, grupo).

---

### 2.2 · Optimización del Entorno Linux con Alias en `.bashrc`

Configuración del archivo `/home/Boris/.bashrc` con un conjunto de **alias personalizados** para acelerar las operaciones diarias de administración de sistemas. Incluye atajos de productividad, auditoría de red y diagnóstico de recursos.

![Archivo .bashrc con alias personalizados en GNU nano](img/Alias%20creados%20por%20mi%20en%20Linux.png)

*El archivo `.bashrc` editado con `nano` muestra alias organizados por categoría:*

| Alias       | Comando real                              | Propósito                          |
|-------------|-------------------------------------------|------------------------------------|
| `actualizar`| `sudo apt update && sudo apt upgrade -y`  | Actualización completa del sistema |
| `ports`     | `netstat -tulanp`                         | Auditoría de puertos activos       |
| `extip`     | `curl icanhazip.com`                      | IP pública del equipo              |
| `weather`   | `curl wttr.in`                            | Clima desde la terminal            |
| `mem5`      | `ps auxf \| sort -nr -k 4 \| head -5`    | Top 5 procesos por RAM             |
| `cpu5`      | `ps auxf \| sort -nr -k 3 \| head -5`    | Top 5 procesos por CPU             |
| `ll`        | `ls -alF`                                 | Listado detallado con permisos     |
| `nbash`     | `nano .bashrc`                            | Edición rápida del perfil          |

> **Nota:** El repositorio de scripts incluye también la configuración del dinosaurio T-Rex animado (`cmatrix`, `lolcat`) como easter egg de terminal. 🦖

---

### 2.3 · Gestión Remota Segura con SSH y Control de Permisos

Conexión desde el equipo Windows al servidor Linux mediante **SSH**, demostrando administración remota segura sin necesidad de acceso físico. Durante la sesión remota se ejecutaron operaciones de control de permisos con `chown` y `chmod`, replicando el flujo de trabajo de un administrador de sistemas en un entorno de producción.

![Conexión SSH desde Windows al equipo Linux con comandos chown/chmod](img/Ussando%20SSH%20para%20conectarme%20al%20pc%20de%20Linux%20desde%20mi%20pc%20de%20Windows.png)

*La sesión SSH inter-VM demuestra: autenticación remota, navegación del sistema de archivos y aplicación del modelo de permisos POSIX (`rwxr-xr-x`) — equivalente Linux al modelo de permisos NTFS/Share de Windows.*

---

## Área 3 — Seguridad Defensiva y Análisis (Blue Team) 🛡️

> **Objetivo:** Implementar controles de seguridad en capas (defense in depth): auditoría de accesos a objetos, endurecimiento del perímetro con firewall y análisis de ataques de fuerza bruta reales, desarrollando la mentalidad de detección y respuesta propia del Blue Team.

### 3.1 · Auditoría de Accesos con Event Viewer — Event ID 4663

Configuración de políticas de **Object Access Auditing** en Windows y análisis del **Event ID 4663** ("Se intentó acceder a un objeto") en el Security Log. Este evento es crítico en la investigación forense: registra qué usuario accedió a qué archivo, desde qué proceso y en qué momento exacto.

![Event Viewer filtrando el Event ID 4663 en el Security Log](img/Event%20Viewe%20Flitrer%204663.png)

| Campo del evento | Valor                    |
|------------------|--------------------------|
| Event ID         | `4663`                   |
| Log              | Security (Windows Logs)  |
| Task Category    | File System              |
| Fecha registrada | 04/04/2026 · 16:53:42    |
| Fuente           | Microsoft Windows security |

*El filtrado por Event ID en el Security Log es una técnica fundamental de **SIEM triage**: permite aislar eventos específicos entre miles de registros y reconstruir la línea temporal de un incidente.*

---

### 3.2 · Hardening de Red — Regla de Firewall Personalizada

Creación de una regla **Inbound** personalizada en Windows Defender Firewall con el nombre `Bloqueo_Ping_Entrante`, bloqueando solicitudes ICMP entrantes. Esta técnica de hardening reduce la superficie de ataque al dificultar el reconocimiento de red (network enumeration) por parte de un atacante.

![Reglas Inbound del Firewall de Windows con la regla Bloqueo_Ping_Entrante](img/Creacion%20de%20una%20regla%20en%20Windows%20Firewall.png)

*La consola de **Windows Defender Firewall with Advanced Security** muestra las Inbound Rules activas. La regla personalizada `Bloqueo_Ping_Entrante` coexiste con las reglas de sistema, demostrando gestión granular de la política de firewall a nivel de protocolo.*

**Concepto aplicado:** Un host que no responde a ping es invisible en un barrido con `nmap -sn` o `ping sweep`, dificultando la fase de reconocimiento de un atacante.

---

### 3.3 · Simulación de Ataque — Fuerza Bruta RDP con Hydra (Kali Linux)

Ejecución de un ataque de diccionario contra el protocolo **RDP** (puerto 3389) desde Kali Linux utilizando **Hydra**, simulando la técnica de **credential stuffing** usada por actores de amenaza reales. El objetivo es entender el ataque para poder detectarlo y bloquearlo eficazmente.

```bash
hydra -t 1 -l sofia.perez -P dictionary.txt rdp://10.0.0.100
```

![Ataque de fuerza bruta RDP con Hydra desde Kali Linux](img/Captura%20Kali%20Linux.png)

| Parámetro   | Valor                              |
|-------------|------------------------------------|
| Herramienta | Hydra v9.0                         |
| Protocolo   | RDP (Remote Desktop Protocol)      |
| Target      | `10.0.0.100`                       |
| Usuario     | `sofia.perez`                      |
| Wordlist    | `dictionary.txt`                   |
| Threads     | 1 (módulo RDP es experimental)     |
| Resultado   | 0 contraseñas válidas encontradas  |

> ⚠️ **Entorno controlado:** Este ataque se ejecutó exclusivamente dentro de la red virtual aislada del laboratorio, contra máquinas propias. Nunca debe realizarse contra sistemas sin autorización explícita.

**Perspectiva Blue Team:** Cada intento fallido de Hydra genera un **Event ID 4625** (Logon Failure) en el Security Log del servidor objetivo. Un analista SOC configuraría una alerta que dispara cuando este evento supera un umbral (ej. >5 intentos en 60 segundos) — la base de una política de detección de fuerza bruta.

---

### 3.4 · Firewall Perimetral — OPNsense (FreeBSD)

Despliegue de **OPNsense 26.1.2_5** como firewall y router perimetral del laboratorio, proporcionando inspección de tráfico, NAT y segmentación de red entre la WAN y la LAN interna. OPNsense es una solución open source de grado empresarial utilizada en entornos de producción reales.

![Consola de administración de OPNsense mostrando interfaces LAN/WAN](img/Router%20FreeBSD%20Configurado.png)

| Interfaz | Adaptador | Dirección IP         | Tipo    |
|----------|-----------|----------------------|---------|
| LAN      | `em0`     | `192.168.1.1/24`     | Estática |
| WAN      | `em1`     | `10.0.0.102/8`       | DHCP    |

*La consola muestra los fingerprints SSH del firewall (ECDSA, ED25519, RSA), confirmando que la administración remota segura está habilitada. OPNsense actúa como el único punto de entrada/salida de la red de laboratorio, centralizando el control del tráfico.*

---

## 🧰 Stack Tecnológico Completo

| Categoría           | Tecnología                                              |
|---------------------|---------------------------------------------------------|
| Virtualización      | Oracle VirtualBox                                       |
| Sistemas Operativos | Windows Server 2022 · Windows 11 Pro · Ubuntu · Kali Linux |
| Firewall/Router     | OPNsense 26.1.2 (FreeBSD)                              |
| Directorio Activo   | Active Directory DS · DNS · DHCP · GPO                 |
| Automatización      | PowerShell · Bash · `.bashrc` aliases                  |
| Seguridad Ofensiva  | Hydra · Kali Linux (entorno controlado)                |
| Seguridad Defensiva | Windows Event Viewer · Windows Defender Firewall        |
| Administración      | SSH · CMD · PowerShell ISE · Server Manager            |
| Monitorización      | Performance Monitor · Event Log (Security Channel)     |

---

## 📌 Estado del Laboratorio

| Área                              | Estado         |
|-----------------------------------|----------------|
| Windows Enterprise Infrastructure | ✅ Completado   |
| Linux & Automatización            | ✅ Completado   |
| Blue Team / Seguridad Defensiva   | ✅ Completado   |
| Network Topologies (Cisco PT)     | 🔄 En progreso  |
| SIEM / Log Aggregation            | 📋 Planificado  |

---

<div align="center">

**[Ver perfil de GitHub](https://github.com/BorisPintos) · [LinkedIn](https://www.linkedin.com/in/boris-rodriguez-pintos/)**

</div>
