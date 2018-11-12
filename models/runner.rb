ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)
class Runner < ActiveRecord::Base
  belongs_to :marathon
end

class Marathon < ActiveRecord::Base
  has_many :runners
end
