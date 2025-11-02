# Documentação Local do Projeto (não versionada)

Este arquivo é local e está configurado para NÃO ser versionado nem enviado ao remoto. Ele descreve em detalhes o que foi feito no projeto, a arquitetura adotada, a lógica de funcionamento e os design patterns utilizados.

## Visão Geral

- Projeto Salesforce DX com foco em consulta de endereços via CEP, integração com serviço externo (ViaCep) e persistência do resultado no objeto customizado `Address__c`.
- Frontend em LWC (`addressSearch`) consumindo serviços Apex.
- Camadas bem definidas: Interface (contratos), Serviço (orquestração), Repositório (persistência) e Adaptador/Cliente externo (integração).
- Automação de commits usando mensagens no padrão Conventional Commits e push automático (apenas para arquivos versionáveis; este MD está excluído).

## Arquitetura

- Camada de **Interface**:
  - `IAddressRepository`: contrato para persistência e consulta de endereços.
  - `IExternalAddressService`: contrato para buscar dados de endereço em provedores externos.
- Camada de **Serviço**:
  - `AddressService`: orquestra a consulta de CEP, chama o serviço externo, transforma a resposta e persiste via repositório.
  - `AddressServiceFactory`: ponto único para construir `AddressService` e injetar dependências (repositório e serviço externo). Facilita testes e troca de implementações.
- Camada de **Repositório**:
  - `AddressRepository`: implementação de `IAddressRepository` utilizando DML/queries (SOQL) para salvar e consultar registros `Address__c`.
- Camada de **Integração Externa**:
  - `ViaCepService`: implementação de `IExternalAddressService` chamando o endpoint ViaCep, com tratamento de erro e normalização dos campos (ex.: `logradouro`, `bairro`, `localidade`, `uf`).
  - `ExternalServiceException`: exceção específica para falhas de integração, propagada para diagnóstico consistente.
- Camada de **Teste**:
  - `AddressRepositoryTest`, `AddressServiceTest`, `ViaCepServiceTest`: testes unitários cobrindo cenários de sucesso, erro e contratos (interfaces). 

## Estrutura de Pastas (principais)

- `SalesforceProject/force-app/main/default/classes`: classes Apex (interfaces, serviços, repositórios, testes).
- `SalesforceProject/force-app/main/default/objects/Address__c`: objeto e campos customizados (CEP, Logradouro, Bairro, Localidade, UF).
- `SalesforceProject/force-app/main/default/lwc/addressSearch`: componente LWC (HTML/CSS/JS/meta).
- `SalesforceProject/scripts`: automações (auto-commit, validador de mensagens).

## Fluxo Lógico

1. Usuário informa um CEP no LWC `addressSearch`.
2. LWC chama método Apex (ex.: em `AddressService`) para buscar dados no serviço externo (`ViaCepService`).
3. `AddressService` valida o CEP, chama `IExternalAddressService`, converte a resposta para o modelo de domínio.
4. `AddressService` chama `IAddressRepository` para persistir/atualizar `Address__c`.
5. Resposta é retornada ao LWC, que atualiza a UI (campos e estados) e exibe erros amigáveis quando necessário.

## Design Patterns Utilizados

- **Interface Segregation & Dependency Inversion**: contratos `IAddressRepository` e `IExternalAddressService` isolam dependências e permitem trocar implementações sem afetar consumidores.
- **Repository**: abstrai persistência de `Address__c` e concentra SOQL/DML em um ponto, simplificando testes.
- **Service Layer**: `AddressService` orquestra regras de negócio e integrações, mantendo UI e repositório desacoplados.
- **Factory**: `AddressServiceFactory` centraliza criação com injeção de dependências, facilitando composição e testes.
- **Adapter/Facade**: `ViaCepService` adapta a resposta do provedor externo ao nosso modelo de domínio e encapsula chamadas HTTP.
- **Exception Handling**: `ExternalServiceException` padroniza o tratamento de falhas externas.

## Lógica do Componente LWC `addressSearch`

- Campos: entrada para CEP e exibição de `Logradouro`, `Bairro`, `Localidade`, `UF`.
- Estados: loading, erro, limpeza de campos e feedback ao usuário.
- Chamadas: utiliza métodos Apex expostos por `AddressService` para obter e persistir dados.
- Boas práticas: validação básica do CEP antes da chamada, exibição de mensagens claras, separação de estilo (CSS) e estrutura (HTML).

## Objeto `Address__c` e Campos

- `Cep__c`, `Logradouro__c`, `Bairro__c`, `Localidade__c`, `Uf__c`.
- Pensado para suportar consulta rápida por CEP e exibição agregada de informações em UI ou relatórios.

## Testes

- Cenários cobertos:
  - Consulta de CEP válido (sucesso).
  - CEP inválido/formatação incorreta (erro esperado).
  - Falha do serviço externo (lançamento de `ExternalServiceException`).
  - Persistência e recuperação de `Address__c` via `AddressRepository`.

## Convenções de Commit e Automação

- Mensagens no padrão **Conventional Commits** (ex.: `feat(lwc): adicionar componente addressSearch`).
- Script de **auto-commit** por arquivo a cada 10 minutos, com push automático após cada commit.
- Observação: este arquivo está excluído do versionamento via `.git/info/exclude` e nunca será enviado ao remoto.

## Decisões e Trade-offs

- Separação clara de camadas para facilitar manutenção e testes.
- Uso de interfaces permite trocar facilmente o provedor externo (ex.: outro serviço além do ViaCep).
- Automação de commits reduz fricção no fluxo de trabalho; exclusão local deste MD evita ruído no histórico remoto.

## Próximos Passos

- Implementar validações mais robustas para CEP (ex.: máscara, normalização).
- Adicionar logging centralizado para integrações externas.
- Expandir testes com cenários de rede e timeouts.
- Considerar cache de respostas de CEP frequentes para reduzir chamadas externas.