class Genre

  def self.load_config
    File.open(File.join(Rails.root, 'config/genres.yml'), 'r') do |f|
      return YAML.load(f)
    end
  end

  def self.config
    @config ||= load_config

  end

  attr_accessor :type, :name, :c_model
  
  def initialize(params = {})
    self.type = params[:type] if params[:type]
    self.name = params[:name] if params[:name]
    self.c_model = params[:c_model] if params[:c_model]
  end

  def self.find(name)
    if name == :all
      config.map { |key, value| row_to_obj(key, value) }
    else 
      row_to_obj(name, config[name])
    end
  end

  def self.row_to_obj(name, row)
      Genre.new(:type=>row["type"], :name=>name, :c_model=>row["c_model"])
  end

end
