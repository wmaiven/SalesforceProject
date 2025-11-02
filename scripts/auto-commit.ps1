# Script de auto-commit a cada 10 minutos
# Realiza commits por arquivo modificado, seguindo Conventional Commits

function Try-Push {
  try {
    $remotes = git remote | Where-Object { $_ -ne '' }
    if ($remotes) {
      $branch = git rev-parse --abbrev-ref HEAD
      $upstream = git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null
      if (-not $upstream) {
        # Primeiro push: usa o primeiro remoto disponível caso não exista upstream
        $remote = (git remote | Select-Object -First 1)
        Write-Host "[auto-commit] Definindo upstream em $remote/$branch"
        git push -u $remote $branch
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

function Get-ChangedEntries {
  $lines = git status --porcelain
  $entries = @()
  foreach ($line in $lines) {
    if ($line -match '^(..)[ ](.+)$') {
      $status = $matches[1].Trim()
      $path = $matches[2].Trim()
      $entries += @{ status = $status; path = $path }
    }
  }
  return $entries
}

function Select-Scope($path) {
  if ($path -match 'force-app/main/default/lwc/') { return 'lwc' }
  elseif ($path -match 'force-app/main/default/classes/') { return 'apex' }
  elseif ($path -match 'force-app/main/default/objects/') { return 'objects' }
  elseif ($path -match '^scripts/') { return 'scripts' }
  elseif ($path -match '^config/') { return 'config' }
  else { return 'repo' }
}

function Commit-Entry($entry) {
  $path = $entry.path
  $status = $entry.status
  git add -- "$path"
  $scope = Select-Scope $path
  $name = [System.IO.Path]::GetFileName($path)
  $type = 'chore'
  $desc = "update $name"
  if ($status -match '^\?\?') { $type = 'feat'; $desc = "add $name" }
  elseif ($status -match '^A') { $type = 'feat'; $desc = "add $name" }
  elseif ($status -match '^M') { $type = 'chore'; $desc = "update $name" }
  elseif ($status -match '^D') { $type = 'chore'; $desc = "remove $name" }
  elseif ($status -match '^R') { $type = 'refactor'; $desc = "rename $name" }
  $msg = "$type($scope): $desc"
  git commit -m $msg
}

function Process-Changes {
  $entries = Get-ChangedEntries
  if (-not $entries -or $entries.Count -eq 0) {
    Write-Host '[auto-commit] Sem alterações; aguardando próximo ciclo.'
    return
  }
  foreach ($e in $entries) {
    try {
      Commit-Entry $e
      Try-Push
    } catch {
      Write-Host "[auto-commit] Falha ao commitar '$($e.path)': $($_.Exception.Message)"
    }
  }
}

function Invoke-AutoCommit {
  while ($true) {
    Process-Changes
    Start-Sleep -Seconds 600 # 10 minutos
  }
}

Invoke-AutoCommit