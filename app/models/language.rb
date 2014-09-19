class Language < ActiveRecord::Base
  attr_accessible :name

  has_many :linguistic_abilities
  has_many :profiles, through: :linguistic_abilities

end
