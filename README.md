# 🏠 Enterprise Homelab — Boris Pintos

> Laboratorio virtualizado de infraestructura corporativa, automatización y seguridad defensiva construido sobre VirtualBox. Cada sección demuestra habilidades técnicas aplicadas en un entorno controlado que replica escenarios del mundo real.

---

## 🗺️ Arquitectura General del Laboratorio

```
                        ┌─────────────────────────────┐
                        │  OPNsense 26.1.2 (FreeBSD)  │
                        │  Firewall / Router + Suricata│
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
          │ AD · DNS · DHCP    │    │  GLPI · Apache2       │
          │ Wazuh Agent v4.7.5 │    │  Wazuh Manager        │
          │ IP: 192.168.0.17   │
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

| Parámetro         | Valor                           |
|-------------------|---------------------------------|
| Rol principal     | AD DS + DNS                     |
| IP estática       | `192.168.0.17`                  |
| Subred            | `255.255.255.0`                 |
| Gateway           | `192.168.0.1`                   |
| DNS primario      | `192.168.0.17` (sí mismo)       |
| DNS secundario    | `8.8.8.8`                       |
| Nombre de dominio | `homelab.local`                 |

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

### 1.4 · Gestión Centralizada de Políticas con Group Policy Management

Uso de la consola **Group Policy Management (GPMC)** para administrar y desplegar políticas de dominio en `homelab.local`. Desde esta herramienta se gestionan GPOs que aplican configuraciones automáticas a todos los equipos y usuarios del dominio — incluyendo la programación de actualizaciones de sistema.

![Consola GPMC del dominio homelab.local](img/GPO%20Management%20Console.png)

| Elemento               | Detalle                                              |
|------------------------|------------------------------------------------------|
| Forest                 | `homelab.local`                                      |
| Baseline DC            | `WIN-RMH839Q6RKN.homelab.local`                      |
| OUs gestionadas        | Domain Controllers, Empleados                        |
| GPOs configurables     | Default Domain Policy, Starter GPOs, WMI Filters     |

*La GPMC centraliza el ciclo de vida de todas las políticas del dominio. Permite crear, vincular y forzar GPOs que se aplican automáticamente al inicio de sesión o al reiniciar los equipos — sin necesidad de intervención manual en cada máquina.*

---

### 1.5 · Monitorización de Rendimiento con Performance Monitor

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

Configuración del archivo `/home/Boris/.bashrc` con un conjunto de **alias personalizados** para acelerar las operaciones diarias de administración de sistemas.

![Archivo .bashrc con alias personalizados en GNU nano](img/Alias%20creados%20por%20mi%20en%20Linux.png)

| Alias       | Comando real                              | Propósito                          |
|-------------|-------------------------------------------|------------------------------------|
| `actualizar`| `sudo apt update && sudo apt upgrade -y`  | Actualización completa del sistema |
| `ports`     | `netstat -tulanp`                         | Auditoría de puertos activos       |
| `extip`     | `curl icanhazip.com`                      | IP pública del equipo              |
| `mem5`      | `ps auxf \| sort -nr -k 4 \| head -5`    | Top 5 procesos por RAM             |
| `cpu5`      | `ps auxf \| sort -nr -k 3 \| head -5`    | Top 5 procesos por CPU             |
| `ll`        | `ls -alF`                                 | Listado detallado con permisos     |
| `nbash`     | `nano .bashrc`                            | Edición rápida del perfil          |

---

### 2.3 · Gestión Remota Segura con SSH y Control de Permisos

Conexión desde el equipo Windows al servidor Linux mediante **SSH**, demostrando administración remota segura. Durante la sesión se ejecutaron operaciones de control de permisos con `chown` y `chmod`, replicando el flujo de trabajo de un administrador en producción.

![Conexión SSH desde Windows al equipo Linux con comandos chown/chmod](img/Ussando%20SSH%20para%20conectarme%20al%20pc%20de%20Linux%20desde%20mi%20pc%20de%20Windows.png)

*La sesión SSH inter-VM demuestra: autenticación remota, navegación del sistema de archivos y aplicación del modelo de permisos POSIX (`rwxr-xr-x`) — equivalente Linux al modelo NTFS/Share de Windows.*

---

## Área 3 — Seguridad Defensiva (Blue Team) 🛡️

> **Objetivo:** Implementar controles de seguridad en capas (defense in depth): auditoría de accesos, endurecimiento del perímetro, IDS/IPS con reglas de amenazas reales y simulación de ataques, desarrollando la mentalidad de detección y respuesta del Blue Team.

### 3.1 · Auditoría de Accesos con Event Viewer — Event ID 4663

Configuración de políticas de **Object Access Auditing** en Windows y análisis del **Event ID 4663** ("Se intentó acceder a un objeto") en el Security Log. Este evento es crítico en la investigación forense: registra qué usuario accedió a qué archivo, desde qué proceso y en qué momento exacto.

![Event Viewer filtrando el Event ID 4663 en el Security Log](img/Event%20Viewe%20Flitrer%204663.png)

| Campo del evento | Valor                      |
|------------------|----------------------------|
| Event ID         | `4663`                     |
| Log              | Security (Windows Logs)    |
| Task Category    | File System                |
| Fuente           | Microsoft Windows security |

*El filtrado por Event ID en el Security Log es una técnica fundamental de **SIEM triage**: permite aislar eventos específicos entre miles de registros y reconstruir la línea temporal de un incidente.*

---

### 3.2 · Hardening de Red — Regla de Firewall Personalizada

Creación de una regla **Inbound** personalizada en Windows Defender Firewall (`Bloqueo_Ping_Entrante`) bloqueando solicitudes ICMP entrantes, reduciendo la superficie de ataque visible en un network scan.

![Reglas Inbound del Firewall de Windows con la regla Bloqueo_Ping_Entrante](img/Creacion%20de%20una%20regla%20en%20Windows%20Firewall.png)

*Un host que no responde a ping es invisible en un barrido con `nmap -sn`, dificultando la fase de reconocimiento de un atacante.*

---

### 3.3 · Simulación de Ataque — Fuerza Bruta RDP con Hydra (Kali Linux)

Ejecución de un ataque de diccionario contra **RDP** (puerto 3389) desde Kali Linux utilizando **Hydra**, simulando la técnica de **credential stuffing** usada por actores de amenaza reales.

```bash
hydra -t 1 -l sofia.perez -P dictionary.txt rdp://10.0.0.100
```

![Ataque de fuerza bruta RDP con Hydra desde Kali Linux](img/Captura%20Kali%20Linux.png)

| Parámetro   | Valor                              |
|-------------|------------------------------------|
| Herramienta | Hydra v9.0                         |
| Protocolo   | RDP (puerto 3389)                  |
| Target      | `10.0.0.100`                       |
| Resultado   | 0 contraseñas válidas encontradas  |

> ⚠️ **Entorno controlado:** Ejecutado exclusivamente dentro de la red virtual aislada del laboratorio, contra máquinas propias.

**Perspectiva Blue Team:** Cada intento fallido genera un **Event ID 4625** en el Security Log. Un analista SOC configuraría una alerta cuando este evento supera un umbral (ej. >5 intentos en 60 segundos).

---

### 3.4 · Firewall Perimetral — OPNsense (FreeBSD)

Despliegue de **OPNsense 26.1.2_5** como firewall y router perimetral, proporcionando inspección de tráfico, NAT y segmentación entre la WAN y la LAN interna.

![Consola de administración de OPNsense mostrando interfaces LAN/WAN](img/Router%20FreeBSD%20Configurado.png)

| Interfaz | Adaptador | Dirección IP         | Tipo     |
|----------|-----------|----------------------|----------|
| LAN      | `em0`     | `192.168.1.1/24`     | Estática |
| WAN      | `em1`     | `10.0.0.102/8`       | DHCP     |

---

### 3.5 · IDS/IPS con Suricata — Configuración en OPNsense

Activación del motor **Suricata** integrado en OPNsense como **IPS (Intrusion Prevention System)** en modo `Netmap`, capturando tráfico directamente en la interfaz WAN. El modo promiscuo permite inspeccionar todo el tráfico que atraviesa el firewall, no solo el dirigido a él.

![Configuración general de Suricata IPS en OPNsense](img/Suricata%20Configuracion%20IPS.png)

| Parámetro       | Valor           |
|-----------------|-----------------|
| Motor           | Suricata (integrado en OPNsense) |
| Modo            | Netmap (IPS)    |
| Interfaz        | WAN             |
| Promiscuous     | Activado        |
| Rotación de log | Semanal         |

*La diferencia entre IDS e IPS es crítica: en modo IDS el tráfico malicioso se registra pero no se detiene; en modo **IPS con Netmap** Suricata actúa inline y puede bloquear el paquete antes de que llegue a la red interna.*

---

### 3.6 · IDS/IPS con Suricata — Reglas Emerging Threats Open

Descarga y habilitación de los rulesets **ET Open** (Emerging Threats Open), el conjunto de firmas comunitario más utilizado en entornos de producción. Estos rulesets cubren categorías como escaneo de red, shellcode, SMTP malicioso y otras técnicas de ataque activas.

![Descarga de rulesets ET Open en OPNsense Intrusion Detection](img/Suricata%20Reglas%20ET%20Open.png)

*La pestaña "Download" del módulo Intrusion Detection permite seleccionar y actualizar los rulesets de forma centralizada. `ET open/emerging-scan` detecta técnicas de reconocimiento activo como los escaneos de puertos — directamente relevante para detectar la fase inicial de un ataque.*

---

### 3.7 · Detección y Bloqueo de Ataque en Tiempo Real

Con Suricata activo y los rulesets ET Open habilitados, el tráfico generado desde **Kali Linux** (`10.0.0.103`) hacia la red interna fue detectado y **bloqueado automáticamente** en tiempo real, sin intervención manual.

![Alertas de Suricata bloqueando tráfico desde Kali Linux](img/Suricata%20Bloqueo%20Kali.png)

| Campo       | Valor                              |
|-------------|------------------------------------|
| Fecha       | 2026/04/26 14:58                   |
| Acción      | `blocked`                          |
| Origen      | `10.0.0.103` (Kali Linux) via LAN  |
| SID activo  | `2024364`                          |
| WAN bloqueado | `216.58.204.165:443` → `192.168.0.21` |

*El log de alertas muestra múltiples eventos `blocked` contra la misma IP de Kali, confirmando que Suricata actuó como IPS real: no solo detectó el patrón malicioso sino que descartó los paquetes antes de que alcanzaran el destino. Esto cierra el ciclo ofensiva/defensiva del laboratorio.*

---

## Área 4 — SIEM & Threat Hunting con Wazuh 🔍

> **Objetivo:** Desplegar una plataforma SIEM de grado empresarial, conectar el Domain Controller como agente monitorizado y demostrar capacidades de detección de vulnerabilidades, análisis de eventos de seguridad, correlación con MITRE ATT&CK y cumplimiento normativo (CIS Benchmark / PCI DSS).

### 4.1 · Despliegue del Agente Wazuh en SRV-DC01

Instalación y conexión del agente **Wazuh v4.7.5** en el Domain Controller (`SRV-DC01`), registrado con cobertura del 100% de los agentes del laboratorio. El agente reporta en tiempo real al servidor Wazuh.

![Dashboard de agentes de Wazuh con SRV-DC01 activo](img/Wazuh%20Agentes%20Overview.png)

| Parámetro          | Valor                                     |
|--------------------|-------------------------------------------|
| Agente ID          | `001`                                     |
| Nombre             | `SRV-DC01`                                |
| IP                 | `10.0.0.5`                                |
| Sistema operativo  | Windows Server 2022 Standard (10.0.20348) |
| Versión agente     | Wazuh v4.7.5                              |
| Cluster node       | `node01`                                  |
| Estado             | Active ✅                                  |

---

### 4.2 · Dashboard del Agente — MITRE, SCA y Compliance

El panel de detalle del agente agrega múltiples dimensiones de análisis en una sola vista: tácticas MITRE detectadas, estado de cumplimiento PCI DSS y resultados del **Security Configuration Assessment (SCA)** contra el CIS Benchmark.

![Dashboard completo del agente SRV-DC01 en Wazuh](img/Wazuh%20Agente%20Dashboard.png)

**Top tácticas MITRE detectadas:**

| Táctica              | Eventos |
|----------------------|---------|
| Defense Evasion      | 181     |
| Privilege Escalation | 180     |
| Persistence          | 178     |
| Initial Access       | 176     |
| Impact               | 25      |

**SCA — CIS Microsoft Windows Server 2022 Benchmark v1.0.0:**

| Resultado   | Controles |
|-------------|-----------|
| Passed      | 127       |
| Failed      | 212       |
| Score       | 37%       |

*Un score SCA del 37% es el punto de partida típico de un servidor recién instalado sin hardening. El valor del ejercicio está en identificar exactamente qué controles fallan para priorizarlos y mejorar la postura de seguridad de forma medible.*

---

### 4.3 · Análisis de Security Events

El dashboard de **Security Events** de Wazuh consolida todos los eventos del agente en una vista de analista SOC: evolución temporal de alertas, distribución por grupo de regla y alineación con requisitos PCI DSS.

![Dashboard de Security Events de Wazuh para SRV-DC01](img/Wazuh%20Security%20Events%20Dashboard.png)

| Métrica                  | Valor                                                     |
|--------------------------|-----------------------------------------------------------|
| Total eventos (24h)      | 1.849                                                     |
| Top grupos de alerta     | `windows_security`, `sca`, `vulnerability-detector`       |
| Top alertas              | Windows Logon Success/Failure, Multiple Logon Events      |
| Requisitos PCI DSS top   | 11.2.1, 11.2.3, 10.2.5                                   |

*La concentración de eventos en `windows_security` y `authentication_failed` refleja directamente los intentos de fuerza bruta simulados desde Kali Linux — visible en el SIEM como picos en la evolución temporal de alertas.*

---

### 4.4 · Integración con MITRE ATT&CK — Técnica T1110 (Brute Force)

Navegación por el módulo **MITRE ATT&CK** de Wazuh para investigar la técnica **T1110 – Brute Force**, directamente relacionada con el ataque Hydra simulado. Wazuh vincula los eventos detectados con el framework MITRE, incluyendo los grupos APT conocidos que utilizan esta técnica.

![Vista MITRE ATT&CK en Wazuh mostrando técnica Brute Force T1110](img/Wazuh%20MITRE%20ATT%26CK%20Brute%20Force.png)

*La integración MITRE convierte logs crudos en inteligencia de amenazas contextualizada: permite al analista identificar no solo qué pasó, sino qué actor de amenaza podría estar detrás y qué otras técnicas suele combinar.*

---

### 4.5 · Detección de Vulnerabilidades — 996 CVEs en SRV-DC01

El módulo de **Vulnerability Detection** de Wazuh realizó un escaneo completo del Domain Controller e identificó 996 vulnerabilidades conocidas, clasificadas por severidad con sus CVEs y puntuaciones CVSS.

![Módulo de Vulnerabilidades de Wazuh con 996 CVEs detectados](img/Wazuh%20Vulnerabilidades.png)

| Severidad | Cantidad |
|-----------|----------|
| Critical  | 40       |
| High      | 731      |
| Medium    | 223      |
| Low       | 2        |
| **Total** | **996**  |

**CVEs de alta severidad (muestra):**

| CVE               | CVSS3 | Severidad |
|-------------------|-------|-----------|
| CVE-2024-38202    | 7.3   | High      |
| CVE-2023-50387    | 7.5   | High      |
| CVE-2024-20683    | 7.8   | High      |
| CVE-2024-20682    | 7.8   | High      |

*El volumen de vulnerabilidades refleja que el servidor opera con la versión de evaluación de Windows Server 2022 sin patches aplicados — estado deliberado para el laboratorio. En un entorno de producción, este output priorizaría el patch management inmediato de los 40 CVEs críticos.*

---

## 🧪 Ejercicios Adicionales

Laboratorios específicos documentados de forma independiente, cada uno con su propio objetivo, configuración detallada y evidencia visual. Haz clic en el ejercicio para ver la documentación completa.

| Ejercicio | Tecnologías clave | Descripción |
|---|---|---|
| [🎫 ITSM & Gestión de Activos con GLPI](Sistema%20de%20Ticketing%20y%20Activos%20con%20GLPI/README.md) | GLPI · Apache2 · LDAP/AD | Despliegue integrado con Active Directory, inventario de activos y gestión de tickets de soporte |
| [🔀 Segmentación de Red — DMZ y Guest](DMZ%20y%20Red%20de%20Invitados/README.md) | OPNsense · Firewall Rules | Interfaces DMZ y Guest aisladas de la LAN con acceso a internet mediante reglas de firewall |

---

## 🧰 Stack Tecnológico Completo

| Categoría           | Tecnología                                                        |
|---------------------|-------------------------------------------------------------------|
| Virtualización      | Oracle VirtualBox                                                 |
| Sistemas Operativos | Windows Server 2022 · Windows 11 Pro · Ubuntu · Kali Linux        |
| Firewall/Router     | OPNsense 26.1.2 (FreeBSD) · Segmentación DMZ · Red de Invitados  |
| IDS/IPS             | Suricata (integrado en OPNsense) · ET Open Rulesets              |
| SIEM                | Wazuh v4.7.5 · MITRE ATT&CK · SCA · Vulnerability Detection      |
| ITSM                | GLPI · Apache2 · Integración LDAP/Active Directory               |
| Directorio Activo   | Active Directory DS · DNS · DHCP · GPO · GPMC                    |
| Automatización      | PowerShell · Bash · `.bashrc` aliases                             |
| Seguridad Ofensiva  | Hydra · Kali Linux (entorno controlado)                           |
| Seguridad Defensiva | Windows Event Viewer · Windows Defender Firewall · Suricata IPS   |
| Administración      | SSH · CMD · PowerShell ISE · Server Manager                       |
| Monitorización      | Performance Monitor · Event Log (Security Channel) · Wazuh SIEM  |
| Cumplimiento        | CIS Benchmark (Win Server 2022) · PCI DSS                        |

---

## 📌 Estado del Laboratorio

| Área                              | Estado          |
|-----------------------------------|-----------------|
| Windows Enterprise Infrastructure | ✅ Completado    |
| Linux & Automatización            | ✅ Completado    |
| Blue Team / Seguridad Defensiva   | ✅ Completado    |
| IDS/IPS con Suricata              | ✅ Completado    |
| SIEM con Wazuh                    | ✅ Completado    |
| ITSM con GLPI                     | ✅ Completado    |
| Segmentación de Red (DMZ y Guest) | ✅ Completado    |
| Network Topologies (Cisco PT)     | 🔄 En progreso  |

---

<div align="center">

**[Ver perfil de GitHub](https://github.com/BorisPintos) · [LinkedIn](https://www.linkedin.com/in/boris-rodriguez-pintos/)**

</div>
