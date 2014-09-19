class LinguisticAbility < ActiveRecord::Base
  
  attr_accessible :language_id, :main, :profile_id

  belongs_to :language
  belongs_to :profile

end
