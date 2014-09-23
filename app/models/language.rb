require 'yaml'

class Language < ActiveRecord::Base
  attr_accessible :name

  has_many :linguistic_abilities
  has_many :profiles, through: :linguistic_abilities

  LANGUAGES = {
    en: YAML::load_file(Rails.root.join("lib/languages/languages_en.yml")),
    de: YAML::load_file(Rails.root.join("lib/languages/languages_de.yml"))
  }

  LANGUAGES_COLLECTION = {
    en: Language::LANGUAGES[:en].to_a.map(&:reverse).sort,
    de: Language::LANGUAGES[:de].to_a.map(&:reverse).sort
  }

  def self.language_for(locale, code)
    LANGUAGES[locale].fetch(code, '')
  end
end


