# Solicitar elevacion de permisos si no se ejecuta como administrador
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process powershell -Verb runAs -ArgumentList $arguments
  Break
}

# Importar modulo PSWindowsUpdate, instalar si no esta disponible
Try {
  Import-Module PSWindowsUpdate -ErrorAction Stop
} Catch {
  Write-Host "Instalando modulo PSWindowsUpdate..."
  Install-Module -Name PSWindowsUpdate -Force
  Import-Module PSWindowsUpdate
}

# Registrar actividades
$LogPath = "$env:TEMP\WindowsUpdateLog.txt"
"--- $(Get-Date) ---" | Out-File -FilePath $LogPath -Append

# Obtener e instalar actualizaciones
Try {
  Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot | Out-File -FilePath $LogPath -Append
} Catch {
  "Error al obtener o instalar actualizaciones: $_" | Out-File -FilePath $LogPath -Append
  Write-Host "Error al obtener o instalar actualizaciones. Verifique el log en $LogPath"
  Exit
}

# Solicitar hora de reinicio al usuario
$horaReinicioPredeterminada = "22:00" # Hora predeterminada para el reinicio
$horaReinicio = Read-Host "Ingrese la hora de reinicio deseada (HH:mm) o presione Enter para usar la hora predeterminada ($horaReinicioPredeterminada)"
If ($horaReinicio -eq "") {
  $horaReinicio = $horaReinicioPredeterminada
}

# Validar y calcular la hora de reinicio
Try {
  $fechaReinicio = [datetime]::ParseExact($horaReinicio, 'HH:mm', $null)
  $fechaActual = Get-Date
  If ($fechaReinicio.TimeOfDay -lt $fechaActual.TimeOfDay) {
    $fechaReinicio = $fechaReinicio.AddDays(1)
  }
  $segundosParaReinicio = New-TimeSpan -Start $fechaActual -End $fechaReinicio
  $segundosParaReinicio = [Math]::Round($segundosParaReinicio.TotalSeconds, 0)

  # Programar el reinicio
  Shutdown.exe /r /t $segundosParaReinicio
  Write-Host "El sistema se reiniciara automaticamente en $segundosParaReinicio segundos, a las $horaReinicio."
} Catch {
  Write-Host "La hora de reinicio ingresada no es valida. Por favor, intente nuevamente."
  Exit
}
