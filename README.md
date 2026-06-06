![GitHub](https://img.shields.io/github/license/GustavoAdolfo/minhoteca-infra)
![CI](https://github.com/GustavoAdolfo/minhoteca-infra/actions/workflows/ci.yml/badge.svg)

# minhoteca-infra

Infraestrutura AWS do projeto Minhoteca, gerenciada com Terraform. Contempla recursos como AppRegistry, Route53, CloudFront, entre outros.

## 🎯 Propósito Social

Minhoteca tem como missão facilitar o acesso gratuito à leitura, gestão de empréstimos e organização de pequenas bibliotecas em comunidades, ONGs e projetos sociais, contribuindo para os Objetivos de Desenvolvimento Sustentável (ODS) da ONU — especialmente os que tratam de educação de qualidade e redução das desigualdades.

**Alinhamento aos ODS:**

- 🎓 ODS 4: Educação de Qualidade
- 📚 ODS 10: Redução das Desigualdades
- 💚 ODS 17: Parcerias para a Implementação dos Objetivos

## Visão geral

Este repositório contém os módulos e ambientes Terraform responsáveis por provisionar a infraestrutura base da Minhoteca na AWS. O estado remoto é armazenado em S3 com lock habilitado.

### Principais arquivos

- `envs/prod/main.tf` — configuração do provider AWS e chamada dos módulos para o ambiente de produção
- `envs/prod/default.conf` — configuração do backend S3 para o estado remoto
- `modules/application/appregistry.tf` — recurso AWS Service Catalog AppRegistry
- `modules/application/variables.tf` — variáveis compartilhadas dos módulos
- `.github/workflows/ci.yml` — pipeline de CI/CD com validação e deploy automático

## Estrutura do projeto

```
CHANGELOG.md
LICENSE
README.md
envs/
  prod/
    main.tf
    default.conf
modules/
  application/
    appregistry.tf
    variables.tf
.github/
  workflows/
    ci.yml
```

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.x
- [AWS CLI](https://aws.amazon.com/cli/) configurado com as credenciais adequadas
- Acesso ao bucket S3 `projetos-terraform` para o estado remoto

## Como executar localmente

1. Inicialize o Terraform apontando para o backend:

```bash
cd envs/prod
terraform init --backend-config=default.conf
```

2. Valide a configuração:

```bash
terraform validate
```

3. Visualize o plano de execução:

```bash
terraform plan
```

4. Aplique as mudanças:

```bash
terraform apply
```

## Pipeline CI/CD

O workflow `.github/workflows/ci.yml` executa automaticamente nas branches `main` e `develop`:

- `build-and-test` — roda `terraform init` e `terraform validate` em todo push e PR
- `create-pr-to-main` — abre um PR para `main` automaticamente após merge na `develop`
- `terraform` — executa `terraform plan` e `terraform apply` após push na `main`, autenticando na AWS via OIDC

## Módulos disponíveis

| Módulo | Descrição |
|---|---|
| `modules/application` | AppRegistry do AWS Service Catalog |

## Backend remoto

O estado é armazenado no S3 com as seguintes configurações (veja `envs/prod/default.conf`):

- Bucket: `projetos-terraform`
- Key: `prod/minhoteca-infra.tfstate`
- Região: `us-east-1`
- Lock de estado habilitado
- Criptografia habilitada

## 🤝 Contribuir

Queremos sua contribuição! Veja [CONTRIBUTING.md](./CONTRIBUTING.md) para:

- Padrões de código
- Como escrever testes
- Processo de PR
- Convenção de commits

Contribuições em qualquer nível são bem-vindas:

- 🐛 Reportar bugs
- 📝 Melhorar documentação
- ✨ Sugerir features
- 🔧 Submeter PRs

## 📋 Roadmap

**v1.1.0** (Próximo):

- [ ] Route53 (DNS e zonas hostedas)
- [ ] CloudFront (distribuição CDN)
- [ ] S3 (buckets de assets)

**v1.2.0**:

- [ ] WAF (regras de segurança)
- [ ] ACM (certificados SSL)
- [ ] Ambientes de staging e dev

## 📄 Licença

Distribuído sob licença **MIT** (veja [LICENSE](./LICENSE)).

Escolhemos MIT para incentivar:

- ✅ Uso comercial
- ✅ Modificações
- ✅ Distribuição
- ✅ Uso privado

**Único requisito**: Incluir aviso de copyright e licença.

## 🔗 Links

- [GitHub](https://github.com/GustavoAdolfo/minhoteca-infra)
- [Issues](https://github.com/GustavoAdolfo/minhoteca-infra/issues)

## 💬 Suporte

- 🐛 Abra uma [Issue](https://github.com/GustavoAdolfo/minhoteca-infra/issues)

---

**Minhoteca é código aberto e feito com ❤️ para a comunidade.**

Junte-se a nós na missão de democratizar o acesso à leitura! 📚