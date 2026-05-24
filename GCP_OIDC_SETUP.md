# Configuración de Workload Identity Federation (OIDC) para GitHub Actions

Esta guía describe cómo configurar la autenticación segura sin JSON keys usando Workload Identity Federation (OIDC).

## ¿Por qué Workload Identity Federation?

✅ **Ventajas:**
- ✨ Sin necesidad de almacenar secrets de JSON keys en GitHub
- 🔐 Más seguro - no hay claves permanentes en el repositorio
- 🔄 Tokens de corta duración (~1 hora)
- 📋 Trazabilidad - Auditoría de quién/qué se autenticó

## Pasos de Configuración

### 1. Crear un Workload Identity Pool

```bash
gcloud iam workload-identity-pools create "github-pool" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --display-name="GitHub Actions"
```

### 2. Obtener el Resource Name del Pool

```bash
gcloud iam workload-identity-pools describe "github-pool" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --format='value(name)'
```

Guarda el resultado, será algo como:
```
projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool
```

### 3. Crear un Workload Identity Provider

```bash
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.aud=assertion.aud,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-condition="assertion.repository_owner == 'YOUR_GITHUB_ORG'"
```

### 4. Obtener el Provider URI

```bash
gcloud iam workload-identity-pools providers describe "github-provider" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --format='value(name)'
```

Guarda el resultado, será algo como:
```
projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider
```

### 5. Crear una Service Account (si no existe)

```bash
gcloud iam service-accounts create github-terraform-sa \
  --display-name="GitHub Terraform Service Account" \
  --project="YOUR_PROJECT_ID"
```

### 6. Otorgar Permisos a la Service Account

```bash
# Para Terraform necesita acceso a:
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"

# O permisos más granulares:
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.securityAdmin"
```

### 7. Permitir que GitHub se Autentique como la Service Account

```bash
gcloud iam service-accounts add-iam-policy-binding \
  "github-terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --project="YOUR_PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/YOUR_GITHUB_ORG/YOUR_REPO_NAME"
```

Reemplaza:
- `YOUR_PROJECT_ID` - Tu Project ID en GCP
- `PROJECT_NUMBER` - Tu Project Number en GCP (obtén con `gcloud projects list`)
- `YOUR_GITHUB_ORG` - Tu organización de GitHub (ej: luis-0419)
- `YOUR_REPO_NAME` - El nombre del repositorio (ej: gcp-ace-microservices)

## Configurar Secrets en GitHub

Ve a **Settings → Secrets and variables → Actions** y crea:

| Nombre | Descripción | Ejemplo |
|--------|-------------|---------|
| `GCP_WIF_PROVIDER` | Workload Identity Provider URI | `projects/123456/locations/global/workloadIdentityPools/github-pool/providers/github-provider` |
| `GCP_WIF_SERVICE_ACCOUNT` | Email de la Service Account | `github-terraform-sa@my-project-123.iam.gserviceaccount.com` |
| `GCP_PROJECT_ID` | ID del proyecto GCP | `my-project-123` |
| `GCP_TERRAFORM_BUCKET_DEV` | Nombre del bucket de Terraform (dev) | `my-project-terraform-dev` |
| `GCP_TERRAFORM_BUCKET_PROD` | Nombre del bucket de Terraform (prod) | `my-project-terraform-prod` |

## Verificar la Configuración

Ejecuta el pipeline en GitHub Actions para verificar que funciona correctamente.

## Troubleshooting

### Error: "Invalid JWT"
- Verifica que el `GCP_WIF_PROVIDER` es correcto
- Verifica que la Service Account existe

### Error: "Permission denied"
- Verifica que la Service Account tiene los permisos necesarios
- Verifica que `roles/iam.workloadIdentityUser` está asignado correctamente

### Error: "Repository not found"
- Verifica que `YOUR_GITHUB_ORG/YOUR_REPO_NAME` es correcto
- Verifica que el repositorio es público o que GitHub tiene acceso

## Referencias

- [Google Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [GitHub Actions - Google Cloud Authentication](https://github.com/google-github-actions/auth#workload-identity-federation-via-oidc)
- [Terraform - GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
