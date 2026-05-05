<#
.SYNOPSIS
    Script de monitorización de infraestructura básica
.DESCRIPTION
    Comprueba el estado (Ping) y los puertos críticoss de loss servidores del Homelab.

#>

$Servers = @(
        @{ Name = "SRV-DC01"; IP = "10.0.0.5"; Port = 53; Service = "DNS / Active Directory" },
        @{ Name = "Ubuntu-Linux"; IP = "10.0.0.101"; Port = 22; Service = "SSH" },
        @{ Name = "Router-OPNssense"; IP = "10.0.0.1"; Port = 443; Service = "Web GUI /HTTPS" }
)

Write-Host "Iniciando el escaneo. Espere un momento mientras se completa" -ForegroundColor Cyan
Write-Host "---------------------------------------------------------------------"

$Results = foreach ($Server in $Servers) {
    $Ping = Test-Connection -ComputerName $Server.IP -Count 1 -Quiet

    $PortCheck = $false
    if ($Ping) {
        $TCP = Test-NetConnection -ComputerName $Server.IP -Port $Server.Port -InformationLevel Quiet
        $PortCheck = $TCP
    }

    $Status = if ($Ping -and $PortCheck) { "ONLINE" } elseif ($Ping) { "PUERTO CERRADO" } else { "OFFLINE" }

    [PSCustomObject]@{
        Servidor = $Server.Name
        IP       = $Server.IP
        Servicio = $Server.Service
        Puerto   = $Server.Port
        Estado   = $Status
    }
}

$Results  | Format-Table  -AutoSize

$Results | Export-Csv -Path "C:\Reports_Escaner\Estado_Red.csv" -NoTypeInformation
Write-Host "Escaneo finalizado. Reporte guardado en C:\Reports_Escaner\Estado_Red.csv" -ForegroundColor Green