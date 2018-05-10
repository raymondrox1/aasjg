module Models
  class Base < ActiveRecord::Base

    establish_connection Rails.env.to_sym
    self.abstract_class = true

  end
end
