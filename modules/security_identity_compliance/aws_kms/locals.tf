locals {
  # Record the date when Terraform is run to tag resources
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Maps key_type to the AWS key_usage it requires and a sensible default key_spec.
  # Users can still override key_usage / key_spec explicitly in the keys list.
  key_type_defaults = {
    SYMMETRIC_ENCRYPTION = { key_usage = "ENCRYPT_DECRYPT", key_spec = "SYMMETRIC_DEFAULT" }
    RSA_ENCRYPT_DECRYPT  = { key_usage = "ENCRYPT_DECRYPT", key_spec = "RSA_2048" }
    RSA_SIGN_VERIFY      = { key_usage = "SIGN_VERIFY", key_spec = "RSA_2048" }
    ECC_SIGN_VERIFY      = { key_usage = "SIGN_VERIFY", key_spec = "ECC_NIST_P256" }
    HMAC                 = { key_usage = "GENERATE_VERIFY_MAC", key_spec = "HMAC_256" }
  }

  # Resolved keys map — explicit key_usage / key_spec override key_type defaults.
  # enable_key_rotation is automatically forced to false for any non-SYMMETRIC_DEFAULT key
  # because AWS KMS does not support rotation on asymmetric or HMAC keys.
  # policy resolution order: policy_file (file path) → policy_json (inline) → null (AWS default)
  resolved_keys = {
    for k in var.keys : k.name => merge(k, {
      key_usage = k.key_usage != null ? k.key_usage : local.key_type_defaults[k.key_type].key_usage
      key_spec  = k.key_spec != null ? k.key_spec : local.key_type_defaults[k.key_type].key_spec
      enable_key_rotation = (
        (k.key_spec != null ? k.key_spec : local.key_type_defaults[k.key_type].key_spec) == "SYMMETRIC_DEFAULT"
        ? coalesce(k.enable_key_rotation, true)
        : false
      )
      policy_json = (
        k.policy_file != null ? file(k.policy_file)
        : k.policy_json
      )
    })
  }
}