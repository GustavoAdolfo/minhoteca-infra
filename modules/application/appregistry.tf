resource "aws_servicecatalogappregistry_application" "minhoteca_catalog" {
  name        = "${var.nome_projeto}-appregistry"
  description = "Projeto Minhoteca - gerenciado com Terraform"
}

output "appregistry_name" {
  value = aws_servicecatalogappregistry_application.minhoteca_catalog.name
}

output "appregistry_id" {
  value = aws_servicecatalogappregistry_application.minhoteca_catalog.id
}

output "appregistry_tags" {
  value = aws_servicecatalogappregistry_application.minhoteca_catalog.application_tag
}