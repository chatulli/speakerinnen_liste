class CreateLinguisticAbilities < ActiveRecord::Migration
  def change
    create_table :linguistic_abilities do |t|
      t.integer :profile_id
      t.integer :language_id
      t.boolean :main

      t.timestamps
    end
  end
end
