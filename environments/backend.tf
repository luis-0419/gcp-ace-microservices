terraform {
  backend "gcs" {
    # bucket will be set via -backend-config flag
    # prefix will be set via -backend-config flag
  }
}
