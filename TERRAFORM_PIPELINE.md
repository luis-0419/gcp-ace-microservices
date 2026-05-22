# Pipeline de Terraform para GCP

## Descripción

Este pipeline de GitHub Actions automatiza la validación, planificación y despliegue de la infraestructura de Terraform a Google Cloud Platform (GCP) para los ambientes de desarrollo y producción.

## Características

- ✅ **Validación de código Terraform**: Verificación de formato y sintaxis
- 📋 **Plan de cambios**: Genera planes de Terraform antes del despliegue
- 🚀 **Despliegue automático**: Aplica cambios en main con aprobación manual
- 🔐 **Ambientes protegidos**: Aprobación requerida para producción
- 📝 **Comentarios en PR**: Visualiza los cambios directamente en pull requests
- 🗂️ **Múltiples ambientes**: Soporte para dev y prod

## Flujo de trabajo

### En Pull Request (PR)
1. Valida el código Terraform
2. Genera planes para dev y prod
3. Comenta el plan en el PR
4. Requiere aprobación para mergear

### En Push a main
1. Valida el código Terraform
2. Genera planes para dev y prod
3. **Aplica automáticamente** los cambios (con aprobación de ambiente)
4. Guarda los outputs de Terraform

### Manual (workflow_dispatch)
Puedes disparar manualmente seleccionando:
- Ambiente: dev o prod
- Acción: plan o apply

## Configuración requerida

### 1. Crear una Service Account en GCP

```bash
# Crear service account
gcloud iam service-accounts create github-actions-sa \
  --display-name="GitHub Actions Service Account"

# Otorgar permisos necesarios
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin" \
  --role="roles/iam.securityAdmin" \
  --role="roles/storage.admin"

# Crear clave JSON
gcloud iam service-accounts keys create key.json \
  --iam-account=github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### 2. Configurar secretos en GitHub

En tu repositorio, ve a **Settings → Secrets and variables → Actions** y agrega:

| Secreto | Descripción |
|---------|-------------|
| `GCP_PROJECT_ID` | ID del proyecto en GCP (ej: my-project-123) |
| `GCP_SA_KEY` | Contenido completo del archivo `key.json` |

### 3. Configurar ambientes en GitHub (opcional pero recomendado)

Para producción, ve a **Settings → Environments** y crea:

**Ambiente: `prod`**
- Requerir revisores (selecciona usuarios que deben aprobar despliegues)
- Branches de despliegue: `main`

## Archivos tfvars

El pipeline utiliza automáticamente:
- `tfvars/dev/dev.tfvars` para desarrollo
- `tfvars/prod/prod.tfvars` para producción

Asegúrate de que estos archivos existan y contengan las variables necesarias.

Ejemplo de contenido:

```hcl
# tfvars/dev/dev.tfvars
project_id = "my-project-dev"
environment = "dev"

# tfvars/prod/prod.tfvars
project_id = "my-project-prod"
environment = "prod"
```

## Desencadenantes

El pipeline se ejecuta automáticamente cuando:
- Se hace push a `main` o `develop`
- Se abre un PR a `main` o `develop`
- Se modifican archivos en `environments/` o `tfvars/`
- Se dispara manualmente desde GitHub

## Visualizar ejecuciones

1. Ve a tu repositorio en GitHub
2. Click en **Actions**
3. Selecciona **Terraform Deploy to GCP**

## Solución de problemas

### Error: "Authentication to Google Cloud failed"
- Verifica que el secreto `GCP_SA_KEY` está correctamente configurado
- Asegúrate de que la service account tiene permisos suficientes

### Error: "Terraform plan failed"
- Revisa los logs del paso "Terraform Plan"
- Verifica que los archivos `.tfvars` son válidos
- Valida la configuración de Terraform localmente

### Error: "Module not found"
- Asegúrate de que el backend de Terraform está configurado correctamente
- Verifica la conectividad a los módulos (especialmente si son remotos)

## Variables de entorno

Puedes agregar más variables de entorno en la sección `env:` del workflow:

```yaml
env:
  TERRAFORM_VERSION: '1.5.0'
  GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  TF_LOG: DEBUG  # Para debugging
```

## Próximos pasos

- [ ] Configurar los secretos en GitHub
- [ ] Verificar que los archivos `.tfvars` existen
- [ ] Hacer un PR para probar el pipeline
- [ ] Revisar los logs de la primera ejecución
- [ ] Configurar aprobadores para el ambiente de producción

---

**Documentación útil:**
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/vcs.html)
- [Google Cloud Authentication](https://cloud.google.com/docs/authentication)
