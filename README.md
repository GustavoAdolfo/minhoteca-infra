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

## Documentos versionados

O bucket privado `minhoteca-contratos` armazena documentos de texto de diferentes
formatos, sem restrição por extensão. Informe o `Content-Type` apropriado ao
enviar cada objeto (por exemplo, `text/plain`, `text/html` ou `application/pdf`).
O versionamento está habilitado e versões anteriores não expiram automaticamente.

O bucket usa SSE-KMS com a chave Minhoteca e S3 Bucket Keys. Uploads sem headers
de criptografia usam a configuração padrão. Se informar headers, use `aws:kms`
e o ARN exato da chave; outras chaves, SSE-S3 e SSE-C são recusados. A política
também exige HTTPS, bloqueia acesso público e desabilita ACLs.

API Gateway deve acessar S3 por uma role de integração, e Lambdas por suas roles
de execução. Na mesma conta, as policies dessas roles devem permitir
`s3:GetObject` e `s3:GetObjectVersion` no prefixo necessário, além de
`kms:Decrypt` na chave Minhoteca. Uploads exigem `s3:PutObject` e
`kms:GenerateDataKey`; uploads multipart também exigem `kms:Decrypt`.
Listar versões exige `s3:ListBucketVersions` no ARN do bucket.
Essas permissões devem ser configuradas nos módulos dos consumidores; o bucket
não concede acesso genérico aos principals de serviço.

Para ler uma versão específica, envie `versionId` ao S3. No API Gateway, mapeie
esse parâmetro de query na integração S3; retornar apenas a chave do objeto
seleciona a versão atual. CORS é responsabilidade do endpoint do API Gateway,
não do bucket, quando o navegador acessa apenas esse endpoint.

Produção recebe a chave de `module.security.minhoteca_encrypt_arn`. O ambiente
local resolve a chave existente por `kms_log_alias_name`, pois seu módulo de
segurança está desabilitado. A chave deve existir na mesma região do bucket.
Configurar SSE-KMS padrão não recriptografa versões já armazenadas.

Testes de contrato com provider simulado (Terraform >= 1.7, sem acesso AWS):

```bash
terraform -chdir=modules/buckets init -backend=false
terraform -chdir=modules/buckets test
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