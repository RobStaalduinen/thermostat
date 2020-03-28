class CreateReading < ActiveRecord::Migration[5.1]
  def change
    create_table :readings do |t|
      t.belongs_to :thermostat, index: true
      t.integer :number, index: true
      t.float :temperature
      t.float :humidity
      t.float :battery_charge

      t.timestamps null: false
    end
  end
end
