class CreateThermostat < ActiveRecord::Migration[5.1]
  def change
    create_table :thermostats do |t|
      t.string :household_token, index: true
      t.text :address

      t.timestamps null: false
    end
  end
end
