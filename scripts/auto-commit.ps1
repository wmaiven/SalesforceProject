# Script de auto-commit a cada 10 minutos
# Cria commit mesmo sem alterações (allow-empty) para garantir periodicidade

function Try-Push {
  try {
    $remotes = git remote
    if ($remotes) {
      $branch = git rev-parse --abbrev-ref HEAD
      $upstream = git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null
      if (-not $upstream) {
        # Primeiro push: define upstream para origin/<branch>
        git push -u origin $branch
      } else {
        git push
      }
    } else {
      Write-Host "[auto-commit] Nenhum remoto configurado; push ignorado. Use: git remote add origin <url>"
    }
  } catch {
    Write-Host "[auto-commit] Falha no push: $($_.Exception.Message)"
  }
}

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
    Try-Push
    Start-Sleep -Seconds 600 # 10 minutos
  }
}

Invoke-AutoCommit