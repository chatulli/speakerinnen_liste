class ChangeLanguagesToMainLanguageForProfiles < ActiveRecord::Migration
  def up
    rename_column :profiles, :languages, :main_language
  end

  def down
    rename_column :profiles, :main_language, :languages
  end
end
