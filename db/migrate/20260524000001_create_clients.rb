class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :client_identifier, null: false
      t.integer :last_fact_id

      t.timestamps
    end

    add_index :clients, :client_identifier, unique: true
  end
end
