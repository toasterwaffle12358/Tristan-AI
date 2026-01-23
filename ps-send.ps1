<#
PowerShell TCP sender for quick testing.
Usage:
  PowerShell -File .\ps-send.ps1 -Host 192.168.1.42 -Port 8001 -Message "Hello from remote"

This connects to the listener, sends the message, then closes the connection.
#>
param(
  [Parameter(Mandatory=$true)] [string]$Host,
  [int]$Port = 8001,
  [Parameter(Mandatory=$true)] [string]$Message
)

try {
  $client = New-Object System.Net.Sockets.TcpClient($Host, $Port)
  $stream = $client.GetStream()
  $writer = New-Object System.IO.StreamWriter($stream, [System.Text.Encoding]::UTF8)
  $writer.Write($Message)
  $writer.Flush()
  # allow listener to read then close
  Start-Sleep -Milliseconds 50
  $client.Close()
  Write-Host "Sent to $Host:$Port -> $Message"
} catch {
  Write-Error "Failed to send: $_"
}
