class AddAliasToClients < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :alias, :string
  end
end
