# ─────────────────────────────────────────────────────────────────────────────
# AWS Region
# ─────────────────────────────────────────────────────────────────────────────
region = "us-east-1"

# ─────────────────────────────────────────────────────────────────────────────
# Global Tags
# ─────────────────────────────────────────────────────────────────────────────
tags = {
  environment = "production"
  team        = "platform"
  project     = "event-driven-architecture"
  managed_by  = "terraform"
}

# ─────────────────────────────────────────────────────────────────────────────
# Custom Event Buses
# ─────────────────────────────────────────────────────────────────────────────
event_buses = [
  # Custom bus for all internal e-commerce domain events.
  # Rules on this bus only receive events explicitly published to it.
  {
    key  = "ecommerce"
    name = "ecommerce-events"
    tags = { domain = "ecommerce" }
  },
  # Custom bus for all internal HR domain events.
  # Used for routing employee lifecycle events to various HR systems.
  {
    key  = "hr"
    name = "hr-events"
    tags = { domain = "hr" }
  }
]

# ─────────────────────────────────────────────────────────────────────────────
# Rules and Targets
# Defined in locals.tf so that event patterns and input templates can be
# loaded from the templates/ folder via file(). See:
#   templates/ec2-state-change-pattern.json
#   templates/order-placed-pattern.json
#   templates/s3-upload-pattern.json
#   templates/ec2-lambda-input-template.json
# ─────────────────────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────────────────────
# Event Archives
# ─────────────────────────────────────────────────────────────────────────────
archives = [
  # Archive all events on the ecommerce custom bus for 90 days.
  # Events can be replayed to any rule on the bus for debugging or backfilling.
  {
    key            = "ecommerce-archive"
    name           = "ecommerce-events-archive"
    description    = "90-day archive of all ecommerce domain events"
    bus_key        = "ecommerce"
    retention_days = 90
  }
]
