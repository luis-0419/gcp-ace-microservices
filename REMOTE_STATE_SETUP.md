# Configuración del Remote State en GCS

## Descripción

El pipeline de Terraform ahora utiliza Google Cloud Storage (GCS) como backend remoto para almacenar el estado de Terraform. Esto permite que el estado sea compartido entre ejecutores del pipeline y proporciona un control de concurrencia centralizado.

## Estructura del Estado

El estado se organizará de la siguiente manera en el bucket:
```
gs://tu-bucket-terraform/
├── dev/terraform.tfstate
├── prod/terraform.tfstate
└── (archivos de bloqueo y backups)
```

## Pasos de Configuración

### 1. Crear el Bucket de GCS

Ejecuta estos comandos en tu terminal:

```bash
# Variables
PROJECT_ID="tu-proyecto-gcp"
BUCKET_NAME="terraform-state-${PROJECT_ID}"
REGION="us-central1"

# Crear bucket
gsutil mb -p ${PROJECT_ID} -l ${REGION} gs://${BUCKET_NAME}/

# Habilitar versionamiento (recomendado para recuperación)
gsutil versioning set on gs://${BUCKET_NAME}/

# Habilitar registro de acceso (opcional, para auditoría)
gsutil logging set on -b gs://${BUCKET_NAME}-logs gs://${BUCKET_NAME}/

# Configurar permisos (solo la service account de GitHub Actions)
gsutil iam ch serviceAccount:github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com:objectAdmin \
  gs://${BUCKET_NAME}/

gsutil iam ch serviceAccount:github-actions-sa@${PROJECT_ID}.iam.gserviceaccount.com:legacyBucketReader \
  gs://${BUCKET_NAME}/
```

### 2. Agregar Secreto en GitHub

1. Ve a tu repositorio en GitHub
2. **Settings → Secrets and variables → Actions**
3. Crea un nuevo secreto llamado `GCP_TERRAFORM_BUCKET`
4. Valor: `terraform-state-tu-proyecto-gcp` (o el nombre que hayas usado)

El secreto debe contener **solo el nombre del bucket**, sin el prefijo `gs://`

Ejemplo:
```
GCP_TERRAFORM_BUCKET = terraform-state-my-project-123
```

### 3. Validar la Configuración

Una vez configurado, puedes verificar que funciona:

```bash
# Ver contenido del bucket
gsutil ls -r gs://terraform-state-${PROJECT_ID}/

# Ver los archivos de estado
gsutil ls -l gs://terraform-state-${PROJECT_ID}/dev/
gsutil ls -l gs://terraform-state-${PROJECT_ID}/prod/
```

## Cambios en el Pipeline

El pipeline ahora:

1. **Inicializa Terraform** con configuración del backend remoto:
   ```bash
   terraform init \
     -backend-config="bucket=terraform-state-my-project" \
     -backend-config="prefix=dev"
   ```

2. **Crea estados separados** para cada ambiente:
   - `dev/terraform.tfstate` → Estado para desarrollo
   - `prod/terraform.tfstate` → Estado para producción

3. **Mantiene sincronización automática** del estado remoto

## Archivo de Backend

Se ha creado el archivo `environments/backend.tf`:

```hcl
terraform {
  backend "gcs" {
    # bucket will be set via -backend-config flag
    # prefix will be set via -backend-config flag
  }
}
```

Este archivo define que usaremos GCS como backend, y los valores específicos se proporcionan dinámicamente desde el pipeline.

## Variables de Entorno en el Pipeline

Se han agregado las siguientes variables:

```yaml
env:
  TERRAFORM_VERSION: '1.15.4'
  GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
  TF_BACKEND_BUCKET: ${{ secrets.GCP_TERRAFORM_BUCKET }}
```

## Comandos `terraform init` Actualizados

### En `terraform-plan`
```bash
terraform init \
  -backend-config="bucket=${TF_BACKEND_BUCKET}" \
  -backend-config="prefix=${environment}"
```

### En `terraform-apply`
```bash
terraform init \
  -backend-config="bucket=${TF_BACKEND_BUCKET}" \
  -backend-config="prefix=${environment}"
```

### En `terraform-validate`
Mantiene: `terraform init -backend=false` (sin backend remoto para validación)

## Permisos Necesarios en GCP

La service account de GitHub Actions necesita estos permisos en el bucket:

| Rol | Descripción |
|-----|-------------|
| `roles/storage.objectAdmin` | Crear, leer y modificar objetos de estado |
| `roles/storage.legacyBucketReader` | Leer información del bucket |

O un rol personalizado con estos permisos:
- `storage.objects.create`
- `storage.objects.delete`
- `storage.objects.get`
- `storage.objects.update`
- `storage.objects.list`
- `storage.buckets.get`

## Ventajas del Remote State

✅ **Compartido**: Múltiples usuarios pueden trabajar con el mismo estado
✅ **Centralizado**: Un único punto de verdad para la infraestructura
✅ **Versionado**: Histórico de cambios disponible
✅ **Seguro**: Control de acceso granular mediante IAM
✅ **Auditable**: Logs de acceso disponibles
✅ **Concurrencia**: Bloqueos automáticos para operaciones simultáneas

## Solución de Problemas

### Error: "Failed to read bucket..."
- Verifica que el secreto `GCP_TERRAFORM_BUCKET` está correctamente configurado
- Confirma que el bucket existe: `gsutil ls gs://tu-bucket/`
- Revisa que la service account tiene acceso: `gsutil iam get gs://tu-bucket/`

### Error: "Permission denied"
- Verifica que la service account tiene el rol `roles/storage.objectAdmin`
- Ejecuta: `gsutil iam ch serviceAccount:github-actions-sa@PROJECT_ID.iam.gserviceaccount.com:objectAdmin gs://tu-bucket/`

### Estado bloqueado
Si el estado queda bloqueado por una ejecución fallida:
```bash
gsutil rm gs://tu-bucket/dev/.terraform.lock
```

## Próximos Pasos

- [ ] Crear el bucket de GCS
- [ ] Configurar el secreto en GitHub
- [ ] Hacer un push para disparar el pipeline
- [ ] Verificar que el archivo de estado se crea en `gs://tu-bucket/dev/terraform.tfstate`
- [ ] Configurar cifrado en el bucket (opcional pero recomendado)

## Cifrado del Bucket (Opcional)

Para agregar cifrado en reposo:

```bash
# Crear una clave de GCP
gcloud kms keys create terraform-state \
  --location us-central1 \
  --keyring terraform-keyring

# Configurar el bucket para usarla
gsutil encryption set gs://kms/projects/PROJECT_ID/locations/us-central1/keyRings/terraform-keyring/cryptoKeys/terraform-state gs://tu-bucket/
```

---

**Referencias:**
- [GCS Backend Documentation](https://www.terraform.io/language/settings/backends/gcs)
- [GCP Storage Documentation](https://cloud.google.com/storage/docs)
- [Terraform State Management](https://www.terraform.io/language/state)
