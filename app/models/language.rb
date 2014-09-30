require 'yaml'

class Language < ActiveRecord::Base
  attr_accessible :name

  has_many :linguistic_abilities
  has_many :profiles, through: :linguistic_abilities

  validates_presence_of :name

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

  def self.code_for(language_name)
    possible_code = list_language_name_with_code.find do |(lang_string, lang_code)|
      lang_strings = lang_string.split(';').map(&:strip)
      lang_strings.include? language_name
    end
    if possible_code
      possible_code.last
    end
  end

  def self.list_language_name_with_code 
    @list_language_name_with_code ||= Language::LANGUAGES_COLLECTION.values.reduce(:+) #.map{|(name,code)| [name.downcase, code]}
  end
end


