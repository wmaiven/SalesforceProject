# Script de auto-commit a cada 10 minutos
# Cria commit mesmo sem alterações (allow-empty) para garantir periodicidade

function Invoke-AutoCommit {
  while ($true) {
    $status = git status --porcelain
    git add -A
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $message = "chore(auto-commit): snapshot $timestamp"
    if ($status) {
      git commit -m $message
    } else {
      git commit --allow-empty -m $message
    }
    Start-Sleep -Seconds 600 # 10 minutos
  }
}

Invoke-AutoCommit