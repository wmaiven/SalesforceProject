// Validador simples de Conventional Commits
// Uso: node scripts/commit-msg.js <path>

const fs = require('fs');

function exitWithError(msg) {
  console.error(`Commit inválido: ${msg}`);
  console.error('Formato esperado: type(scope): descrição (máx. 80 caracteres)');
  console.error('Tipos permitidos: build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test');
  process.exit(1);
}

try {
  const file = process.argv[2];
  if (!file) exitWithError('arquivo da mensagem não informado');
  const message = fs.readFileSync(file, 'utf8').trim();

  // Regex básica de Conventional Commits
  const re = /^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\(.+\))?:\s.{1,80}$/;
  if (!re.test(message)) {
    exitWithError('mensagem não segue o padrão Conventional Commits');
  }
} catch (err) {
  exitWithError(err.message);
}