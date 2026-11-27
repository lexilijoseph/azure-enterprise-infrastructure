# Azure Enterprise Infrastructure - Terraform

Terraform repository to create and manage:
- Azure Resource Group
- Azure Storage Account
- Microsoft Entra App Registration and Service Principal
- Microsoft Entra Security Group
- Microsoft Entra users
- Membership of all created users in the security group
- Azure RBAC assignment: the app's Service Principal receives `Contributor` on the created Resource Group

Environments: `dev`, `test`, `prod`.

## Important design notes

1. **App Registration vs Service Principal:** The App Registration is the application definition. Its Enterprise Application / Service Principal is the security principal that receives Azure RBAC permissions.
2. **Resource Group assignment:** This project assigns the Service Principal the configured Azure role (default `Contributor`) at the newly created Resource Group scope. It does not attach an Azure Resource Group to the App Registration object itself.
3. **Permissions:** The identity running Terraform needs permissions to create resource groups/storage resources and to create Entra applications, service principals, users, groups and group memberships. It also needs permission to create role assignments, typically `Owner` or `User Access Administrator` plus suitable resource permissions at the subscription/resource-group scope. Entra directory roles / Graph permissions may also be required, such as Application Administrator or appropriate user/group administration privileges.
4. **User passwords:** The initial password is supplied at runtime via `TF_VAR_initial_user_password`. Never commit it to Git. Terraform state contains sensitive user attributes; secure the state backend and restrict access.
5. **Backend bootstrap:** A backend cannot create the storage account that it needs in order to initialize. For a new environment, create the Resource Group and Storage Account once using local state, then migrate the state to the remote backend. Repeat per environment, using that environment's tfvars/backend config.
6. **Storage account name:** Must be globally unique, lowercase, 3-24 characters. Change each environment's example value before deployment.

## Repository layout

```text
azure-enterprise-infrastructure/
├── .github/workflows/
│   ├── terraform-ci.yml
│   └── terraform-cd.yml
├── environments/{dev,test,prod}/
├── modules/
│   ├── resource-group/
│   ├── storage-account/
│   ├── app-registration/
│   ├── security-group/
│   ├── users/
│   └── role-assignment/
├── main.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── locals.tf
└── outputs.tf
```

## 1. Local prerequisites

- Terraform >= 1.6
- Azure CLI (`az`) and a logged-in identity: `az login`
- An Azure subscription and Microsoft Entra tenant
- Git

Check:
```bash
terraform version
az version
az account show
```

Set the subscription:
```bash
az account set --subscription "<SUBSCRIPTION_ID>"
```

## 2. Configure an environment

Copy the example if desired, then edit the selected environment file:
```bash
cp terraform.tfvars.example environments/dev/terraform.tfvars
```

Update `subscription_id`, `tenant_id`, resource names, users, UPN domain and storage account name. Do not put a real password in the tfvars file.

Set the initial password in your shell:

**Git Bash**
```bash
export TF_VAR_initial_user_password='Use-A-Strong-Temporary-Password!'
```

**Windows PowerShell**
```powershell
$env:TF_VAR_initial_user_password = "Use-A-Strong-Temporary-Password!"
```

## 3. First-time backend bootstrap (per environment)

The example backend uses the same Resource Group and Storage Account that this stack creates. For the first run, use local state:

```bash
terraform init -backend=false
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/dev/terraform.tfvars" -out=bootstrap.tfplan
terraform apply bootstrap.tfplan
```

The first apply creates the Resource Group and Storage Account as well as the Entra resources. Then migrate the local state to Azure Storage:

```bash
terraform init -migrate-state -backend-config="environments/dev/backend.hcl"
```

Terraform asks whether to copy the existing state; answer `yes`. After migration:
```bash
terraform plan -var-file="environments/dev/terraform.tfvars"
```

For `test` and `prod`, repeat the bootstrap using the matching tfvars and backend file. Keep each environment's state key unique.

> If your organization requires the state backend to exist before any infrastructure deployment, use a separate, centrally managed bootstrap stack for the state Resource Group and Storage Account instead of creating the backend in this workload stack.

## 4. Normal deployment

After backend migration:
```bash
terraform init -backend-config="environments/dev/backend.hcl"
terraform plan -var-file="environments/dev/terraform.tfvars" -out=dev.tfplan
terraform apply dev.tfplan
```

For test/prod, substitute the environment directory. Review plans carefully, especially user creation and RBAC permissions.

## 5. GitHub Actions configuration

Configure repository **Settings → Secrets and variables → Actions**.

### Variables
- `AZURE_CLIENT_ID`: client ID of the GitHub deployment identity / federated app registration
- `AZURE_TENANT_ID`: tenant ID
- `AZURE_SUBSCRIPTION_ID`: subscription ID

### Secrets
- `TF_VAR_initial_user_password`: temporary password for newly created Entra users

Use GitHub OIDC federation for Azure login; do not store a client secret. Configure a federated credential on the GitHub deployment App Registration for:
- Issuer: `https://token.actions.githubusercontent.com`
- Subject for main deployment: `repo:OWNER/REPOSITORY:environment:dev` (or the relevant GitHub environment)
- Audience: `api://AzureADTokenExchange`

Create GitHub Environments named `dev`, `test`, and `prod`. Add required reviewers for `prod`. Ensure the federated credential subject exactly matches the GitHub environment and repository.

The GitHub deployment identity must have the Azure and Entra permissions described above. For `azure/login`, the federated App Registration is the identity Terraform uses too, unless you deliberately configure separate identities.

### Remote backend
Create the backend storage account/container by completing the bootstrap procedure above before running CI plans or CD applies. The workflow expects the backend resources to exist.

## 6. CI and CD workflow

- `terraform-ci.yml` runs on pull requests and pushes to `dev`, `test`, and `main`. It checks formatting, initializes providers without a backend, validates Terraform, and runs Checkov.
- `terraform-cd.yml` can be manually dispatched to open a PR from a source branch to a target branch. The PR triggers CI. Deployment runs only after code is merged to `main`; it runs plan and apply for the selected GitHub Environment.
- Configure branch protection / rulesets so the CI check is required before merge. The workflow does not bypass branch protection or approve its own PR.

## 7. Security and production recommendations

- Enable GitHub branch protection: require pull request, required CI status check, and at least one reviewer.
- Require approval for `prod` GitHub Environment.
- Prefer separate deployment identities and state storage per environment.
- Use least-privilege custom roles where possible. `Contributor` is broad and cannot manage RBAC; this project only uses it because it was requested as the application role.
- Rotate initial passwords and distribute them securely. Consider creating users with a controlled identity lifecycle instead of static Terraform-managed passwords.
- Restrict state container access and enable storage versioning/soft delete and diagnostic logging in a production baseline.
- Do not output passwords, client secrets, or tokens.
