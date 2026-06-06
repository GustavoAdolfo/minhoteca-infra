# Contribuindo com o minhoteca-infra

Obrigado por contribuir! Este guia cobre tudo que você precisa para colaborar com o repositório de infraestrutura do projeto Minhoteca.

## Índice

- [Pré-requisitos](#pré-requisitos)
- [Configurando o ambiente](#configurando-o-ambiente)
- [Fluxo de trabalho](#fluxo-de-trabalho)
- [Convenção de commits](#convenção-de-commits)
- [Padrões de código Terraform](#padrões-de-código-terraform)
- [Abrindo um Pull Request](#abrindo-um-pull-request)
- [Reportando bugs](#reportando-bugs)
- [Sugerindo melhorias](#sugerindo-melhorias)

---

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.x
- [AWS CLI](https://aws.amazon.com/cli/) configurado
- [terraform-docs](https://terraform-docs.io/) (opcional, para gerar documentação de módulos)
- [tflint](https://github.com/terraform-linters/tflint) (recomendado para lint local)
- Acesso de leitura ao bucket S3 de estado remoto (para contribuidores externos, use um backend local)

---

## Configurando o ambiente

1. Faça um fork do repositório e clone localmente:

```bash
git clone https://github.com/<seu-usuario>/minhoteca-infra.git
cd minhoteca-infra
```

2. Inicialize o Terraform no ambiente desejado:

```bash
cd envs/prod
terraform init --backend-config=default.conf
```

> Para desenvolvimento local sem acesso ao backend remoto, use um backend local temporário:
> ```bash
> terraform init -backend=false
> ```

3. Valide sua configuração antes de qualquer mudança:

```bash
terraform validate
terraform fmt -check -recursive
```

---

## Fluxo de trabalho

Usamos o modelo de branches com `main` e `develop`:

| Branch | Propósito |
|---|---|
| `main` | Código estável em produção |
| `develop` | Integração de novas features |
| `feat/<nome>` | Nova feature ou módulo |
| `fix/<nome>` | Correção de bug ou configuração |
| `chore/<nome>` | Tarefas de manutenção sem impacto funcional |

1. Crie sua branch a partir de `develop`:

```bash
git checkout develop
git pull origin develop
git checkout -b feat/nome-do-recurso
```

2. Faça suas alterações e valide localmente.
3. Abra um PR para `develop`. O merge em `main` é feito via PR automático gerado pelo CI.

---

## Convenção de commits

Seguimos o padrão [Conventional Commits](https://www.conventionalcommits.org/pt-br/):

```
<tipo>(escopo opcional): descrição curta
```

### Tipos aceitos

| Tipo | Quando usar |
|---|---|
| `feat` | Novo módulo ou recurso de infraestrutura |
| `fix` | Correção em configuração existente |
| `docs` | Alterações em documentação |
| `chore` | Atualização de versões, reorganização de arquivos |
| `refactor` | Refatoração sem mudança de comportamento |
| `ci` | Alterações no pipeline CI/CD |

### Exemplos

```
feat(route53): adiciona módulo de zonas DNS
fix(appregistry): corrige nome do recurso no ambiente de prod
docs: atualiza README com novos módulos
ci: adiciona step de tflint no workflow
```

---

## Padrões de código Terraform

- Formate o código antes de commitar:

```bash
terraform fmt -recursive
```

- Cada módulo deve ter:
  - `variables.tf` — todas as variáveis com `description` e `type`
  - `outputs.tf` — outputs relevantes para consumo externo
  - `main.tf` ou arquivo nomeado pelo recurso (ex: `appregistry.tf`)

- Use `default_tags` no provider para evitar repetição de tags nos recursos.
- Evite hardcode de valores sensíveis; use variáveis ou `data sources`.
- Prefira `~>` para versões de providers e do Terraform (pessimistic constraint operator).

---

## Abrindo um Pull Request

1. Certifique-se de que `terraform validate` e `terraform fmt -check -recursive` passam sem erros.
2. Descreva claramente no PR:
   - O que foi adicionado ou alterado
   - Qual o impacto esperado na infraestrutura
   - Se há necessidade de `terraform apply` manual ou se o CI resolve
3. PRs para `main` são abertos automaticamente pelo CI a partir de `develop`. Não abra PRs diretos para `main` sem justificativa.
4. Pelo menos uma aprovação é necessária antes do merge.

---

## Reportando bugs

Abra uma [Issue](https://github.com/GustavoAdolfo/minhoteca-infra/issues) com:

- Descrição do comportamento inesperado
- Ambiente afetado (prod, etc.)
- Saída relevante do Terraform (`plan`, `apply`, ou mensagem de erro)
- Versão do Terraform utilizada

---

## Sugerindo melhorias

Abra uma [Issue](https://github.com/GustavoAdolfo/minhoteca-infra/issues) com o label `enhancement` descrevendo:

- O recurso ou módulo que deseja adicionar
- Justificativa e caso de uso
- Referências à documentação AWS ou Terraform relevante

---

Contribuições em qualquer nível são bem-vindas. Obrigado por ajudar a construir a infraestrutura da Minhoteca! 📚
