# Changelog

Todas as mudanças relevantes deste projeto serão documentadas aqui.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Versionamento Semântico](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Planned
- Route53: zonas e registros DNS
- CloudFront: distribuição CDN
- S3: buckets de assets estáticos
- WAF: regras de segurança
- ACM: certificados SSL/TLS

---

## [1.0.0] - 2025-06-06

### Added
- Módulo `modules/application` com recurso AWS Service Catalog AppRegistry
- Variável `nome_projeto` para padronização de nomes de recursos
- Outputs do AppRegistry: `appregistry_name`, `appregistry_id`, `appregistry_tags`
- Ambiente `envs/prod` com configuração do provider AWS (`us-east-1`)
- Backend remoto S3 com lock de estado e criptografia habilitados (`envs/prod/default.conf`)
- Pipeline CI/CD via GitHub Actions (`.github/workflows/ci.yml`):
  - Job `build-and-test`: valida o Terraform em todo push e PR
  - Job `create-pr-to-main`: abre PR automático de `develop` para `main`
  - Job `terraform`: executa `plan` e `apply` na `main` via OIDC
- Autenticação AWS no CI via OIDC (sem chaves de acesso estáticas)
- Tags padrão `Terraform: true` e `Projeto: Minhoteca` aplicadas a todos os recursos

[Unreleased]: https://github.com/GustavoAdolfo/minhoteca-infra/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/GustavoAdolfo/minhoteca-infra/releases/tag/v1.0.0
