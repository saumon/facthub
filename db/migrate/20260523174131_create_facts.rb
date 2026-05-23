class CreateFacts < ActiveRecord::Migration[8.1]
  def change
    create_table :facts do |t|
      t.string :body, null: false, limit: 500

      t.timestamps
    end

    add_index :facts, :body, unique: true
  end
end
