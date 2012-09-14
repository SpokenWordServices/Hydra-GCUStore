# GCU specific configurations

  raw_config = File.read(RAILS_ROOT + "/config/gcu.yml")
  GCU_CONFIG = YAML.load(raw_config)[RAILS_ENV]

