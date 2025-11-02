# Script de auto-commit a cada 20 minutos
# Executa commits apenas se houver alterações pendentes

function Invoke-AutoCommit {
  while ($true) {
    $status = git status --porcelain
    if ($status) {
      git add -A
      $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
      $message = "chore(auto-commit): snapshot $timestamp"
      git commit -m $message
    }
    Start-Sleep -Seconds 1200 # 20 minutos
  }
}

Invoke-AutoCommit