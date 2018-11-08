ActiveRecord::Base.establish_connection(ENV['DATABASE_URL']||"sqlite3:db/development.db")
class Runner < ActiveRecord::Base
  belongs_to :marathon
end

class Marathon < ActiveRecord::Base
  has_many :runners
end
