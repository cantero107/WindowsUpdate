# Importar modulo PSWindowsUpdate
Import-Module PSWindowsUpdate

# Obtener actualizaciones pendientes
Write-Host "Obteniendo actualizaciones pendientes..."
Get-WindowsUpdate

# Instalar todas las actualizaciones pendientes
Write-Host "Instalando actualizaciones pendientes..."
Install-WindowsUpdate -AcceptAll -IgnoreReboot

#Actualizar aplicaciones mediante winget
#Write-Host "Actializando aplicaciones mediante winget..."
#winget upgrade --all #Para actualizar aplicaciones, quitar comentario si es necesario

# Establecer la hora de reinicio (formato 24 horas HH:mm)
#$horaReinicio = "12:00" # Ejemplo para reiniciar a las 12 AM

# Solicitar hora de reinicio al usuario
$horaReinicioPredeterminada = "22:00" # Hora predeterminada para el reinicio
$horaReinicio = Read-Host "Ingrese la hora de reinicio deseada (HH:mm) o presione Enter para usar la hora predeterminada ($horaReinicioPredeterminada)"
If ($horaReinicio -eq "") {
  $horaReinicio = $horaReinicioPredeterminada
}

# Convertir la hora de reinicio a formato de tiempo
$tiempoActual = Get-Date
$fechaReinicio = Get-Date -Hour $horaReinicio.Split(':')[0] -Minute $horaReinicio.Split(':')[1] -Second 0

# Si la hora de reinicio ya pasa para el d√ia actual, programar para el siguiente d√≠a
if ($fechaReinicio -lt $tiempoActual) {
    $fechaReinicio = $fechaReinicio.AddDays(1)
}

# Calcular la diferencia de tiempo en segundos
$diferenciaSegundos = New-TimeSpan -Start $tiempoActual -End $fechaReinicio
$segundosParaReinicio = [Math]::Round($diferenciaSegundos.TotalSeconds, 0)

# Programar el reinicio
Shutdown.exe /r /t $segundosParaReinicio

# Mostrar mensaje de cuando esta programado el reinicio
Write-Host "El sistema se reiniciara automaticamente en $segundosParaReinicio segundos, a las $horaReinicio."
