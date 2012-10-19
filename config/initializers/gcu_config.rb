# GCU specific configurations

  raw_config = File.read(Rails.root.to_s + "/config/gcu.yml")
  GCU_CONFIG = YAML.load(raw_config)[Rails.env]

