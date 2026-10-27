variable "entra_user_object_id" {
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.entra_user_object_id))
    error_message = "The entra_user_object_id variable must be a valid GUID in standard UUID/GUID format (e.g., 123e4567-e89b-12d3-a456-426614174000)."
  }
}
