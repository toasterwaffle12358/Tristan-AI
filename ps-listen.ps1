<#
PowerShell TCP listener for simple message forwarding.
Usage (on the machine that should receive messages):
  PowerShell -ExecutionPolicy Bypass -File .\ps-listen.ps1 -Port 8001

The script will listen on the given port and print received messages to console
and append them to a file `messages.log` in the same folder.
#>
param(
  [int]$Port = 8001
)

Write-Host "Starting listener on port $Port... (Ctrl+C to stop)"

$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, $Port)
$listener.Start()

try {
  while ($true) {
    $client = $listener.AcceptTcpClient()
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
    # ReadToEnd will wait until the sender closes the connection — sender script does close after sending.
    $text = $reader.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($text)) {
      $client.Close()
      continue
    }
    $text = $text.Trim()
    $time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $line = "[$time] $text"
    Write-Host $line
    # Append to messages.log
    Add-Content -Path (Join-Path $PSScriptRoot 'messages.log') -Value $line
    # send ack
    try {
      $writer = New-Object System.IO.StreamWriter($stream)
      $writer.Write('OK')
      $writer.Flush()
    } catch { }
    $client.Close()
  }
} finally {
  $listener.Stop()
}
