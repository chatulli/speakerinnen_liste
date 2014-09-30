class DistinguishBetweenMainAndOtherLanguages < ActiveRecord::Migration
  def up
    Profile.find_each do |profile|
      profile.languages.clear
      profile.main_language = nil
      profile.save

      existing_languages_string = profile.read_attribute("main_language")
      if existing_languages_string.present?
        existing_languages = existing_languages_string.scan(/([\p{L}]+)/).flatten.map(&:strip)
      else
        existing_languages = []
      end

      puts "#{profile.id} - #{existing_languages.inspect}" 

      first_language = existing_languages.shift

      if first_language
        first_language_code = Language.code_for(first_language)

        if first_language_code
          language = Language.find_or_create_by_name first_language_code
          set_language_to_main = LinguisticAbility.find_or_create_by_profile_id_and_language_id profile.id, language.id
          set_language_to_main.update_attributes(main: true)
        else
          puts "no code found for #{first_language}"
        end
      end

      existing_languages.each do |name|
        language_code = Language.code_for(name)

        if language_code
          language = Language.find_or_create_by_name language_code
          la = LinguisticAbility.find_or_create_by_profile_id_and_language_id profile.id, language.id
          la.update_attributes main: false
        else
          puts "no code found for #{name}"
        end
      end

      profile.reload
      puts "=>  #{([profile.main_language_name] + profile.languages.reload.map(&:name)).inspect}"
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
