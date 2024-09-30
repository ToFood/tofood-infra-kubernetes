🍽️ ToFood - Infraestrutura com Terraform
Bem-vindo ao repositório de infraestrutura do ToFood, responsável por configurar e gerenciar toda a estrutura necessária para o backend do projeto tofood na AWS usando Terraform. Este README fornece todas as informações necessárias para você começar rapidamente, seja para testar, modificar ou aprender com o projeto.

🚀 Tecnologias Utilizadas
Terraform: Utilizado para gerenciamento da infraestrutura como código, permitindo a criação, atualização e destruição de recursos na nuvem de maneira declarativa.
Amazon Web Services (AWS): Provedor de nuvem onde toda a infraestrutura é hospedada, oferecendo escalabilidade, segurança e alta disponibilidade para a aplicação.
📂 Estrutura do Projeto
O projeto segue uma estrutura simples e organizada para facilitar a navegação e o entendimento:

bash
Copiar código
.
/tofood-infra-kubernetes
  ├── main.tf               # Arquivo principal do Terraform
  ├── variables.tf          # Definição das variáveis utilizadas no projeto
  ├── outputs.tf            # Saídas do Terraform (outputs)
  ├── eks.tf                # Configuração específica do EKS
  ├── vpc.tf                # Configuração de rede (VPC)
  ├── provider.tf           # Configuração do provider AWS
  ├── README.md             # Documentação do projeto


📜 Arquivos Explicados:

provider.tf:
Configura o provider AWS e o provider Kubernetes para que o Terraform possa gerenciar recursos na AWS e interagir com o Kubernetes.
Assegura que os comandos do Terraform possam criar e configurar recursos na AWS e, depois, conectar ao cluster Kubernetes para aplicar configurações.


vpc.tf:
Cria uma VPC e subnets para fornecer a infraestrutura de rede necessária para o cluster EKS.
Utiliza subnets em múltiplas zonas de disponibilidade para garantir alta disponibilidade.


eks.tf:
Cria um Cluster EKS na AWS, incluindo uma role necessária para o EKS.
Configura a rede do cluster usando as subnets criadas no vpc.tf.


variables.tf:
Define variáveis reutilizáveis para a configuração do Terraform, tornando o código flexível e fácil de modificar para diferentes ambientes.


outputs.tf:
Fornece informações úteis sobre a infraestrutura criada, como o endpoint do cluster EKS, que pode ser utilizado para configurar o kubectl ou para outras operações de integração.

⚙️ Como Configurar o Terraform
Pré-requisitos
Antes de começar, certifique-se de que os seguintes itens estejam configurados:

Terraform instalado na máquina (versão mais recente recomendada).
AWS CLI configurada com suas credenciais AWS, garantindo o acesso adequado ao provedor.
Passos para Executar o Projeto
Clone o Repositório

Comece clonando este repositório para sua máquina local:

sh
Copiar código
git clone https://github.com/seu_usuario/tofood-backend.git
cd tofood-backend/infra
Inicialize o Terraform

Inicialize o diretório de trabalho do Terraform. Esta etapa baixa todos os plugins necessários:

sh
Copiar código
terraform init
Verifique o Plano de Execução

Antes de aplicar as mudanças, verifique o que será criado ou modificado, garantindo que tudo esteja de acordo com o esperado:

sh
Copiar código
terraform plan
Aplique as Configurações

Caso tudo esteja correto no plano de execução, aplique a configuração para provisionar os recursos na AWS:

sh
Copiar código
terraform apply
Durante a aplicação, o Terraform solicitará uma confirmação. Digite yes para prosseguir.

Destruir a Infraestrutura (Se Necessário)

Para remover toda a infraestrutura criada, utilize o comando abaixo e confirme a destruição digitando yes:

sh
Copiar código
terraform destroy
🛠️ Recursos e Configurações Provisionadas
O arquivo main.tf inclui as configurações para provisionar diversos recursos na AWS, como:

Instâncias EC2: Servidores virtuais que executam o backend da aplicação, garantindo processamento e armazenamento necessários para o projeto.
Grupos de Segurança (Security Groups): Regras de firewall que controlam o tráfego de entrada e saída para as instâncias, garantindo um nível adequado de segurança.
📚 Considerações Finais
Esta configuração de infraestrutura foi projetada para ser facilmente compreendida e estendida. Ela serve tanto para ambientes de desenvolvimento quanto de produção, possibilitando escalabilidade conforme a aplicação cresce.

Se você tiver alguma dúvida, sugestão ou quiser contribuir, fique à vontade para abrir uma Issue ou Pull Request.

✨ Contribuições
Sua contribuição é muito bem-vinda! Confira as orientações de contribuição no repositório principal do projeto.

🔗 Links Importantes
Documentação do Terraform
AWS CLI – Guia de Referência
Obrigado por fazer parte deste projeto. Vamos juntos construir uma infraestrutura sólida e escalável para o ToFood!

x
