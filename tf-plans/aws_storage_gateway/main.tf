# AWS Storage Gateway wrapper plan.
# Calls the root Storage Gateway module and passes all variables through.
# Adjust terraform.tfvars to match your gateway, share, volume, and tape pool
# requirements. See README.md for prerequisites and architecture details.

# Step 1: Call the reusable AWS Storage Gateway module.
module "storage_gateway" {
  source = "../../modules/storage/aws-storage-gateway"

  # Step 2: Set the deployment region and merge the auto-generated created_date tag.
  region = var.region
  tags   = merge(var.tags, { created_date = local.created_date })

  # Step 3: Pass gateway definitions (type, activation, timezone, bandwidth).
  gateways = var.gateways

  # Step 4: Pass cache disk definitions (required for File and CACHED gateways).
  cache_disks = var.cache_disks

  # Step 5: Pass upload buffer definitions (required for Volume/Tape gateways).
  upload_buffers = var.upload_buffers

  # Step 6: Pass NFS file share definitions (FILE_S3 gateways).
  nfs_file_shares = var.nfs_file_shares

  # Step 7: Pass SMB file share definitions (FILE_S3 and FILE_FSX_SMB gateways).
  smb_file_shares = var.smb_file_shares

  # Step 8: Pass cached iSCSI volume definitions (CACHED gateways).
  cached_volumes = var.cached_volumes

  # Step 9: Pass stored iSCSI volume definitions (STORED gateways).
  stored_volumes = var.stored_volumes

  # Step 10: Pass virtual tape pool definitions (VTL gateways).
  tape_pools = var.tape_pools
}
