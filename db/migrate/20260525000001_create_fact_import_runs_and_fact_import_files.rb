class CreateFactImportRunsAndFactImportFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :fact_import_runs do |t|
      t.references :admin, null: false, foreign_key: true
      t.string  :status,                    null: false, default: "pending"
      t.integer :total_files,               null: false, default: 0
      t.integer :processed_files,           null: false, default: 0
      t.integer :total_lines,               null: false, default: 0
      t.integer :processed_lines,           null: false, default: 0
      t.integer :added_facts_count,         null: false, default: 0
      t.integer :ignored_duplicates_count,  null: false, default: 0
      t.integer :invalid_files_count,       null: false, default: 0
      t.string  :error_message
      t.datetime :started_at
      t.datetime :completed_at
      t.timestamps
    end

    create_table :fact_import_files do |t|
      t.references :fact_import_run, null: false, foreign_key: true
      t.string  :filename,                  null: false
      t.string  :status,                    null: false, default: "pending"
      t.integer :total_lines,               null: false, default: 0
      t.integer :processed_lines,           null: false, default: 0
      t.integer :added_facts_count,         null: false, default: 0
      t.integer :ignored_duplicates_count,  null: false, default: 0
      t.string  :error_message
      t.timestamps
    end
  end
end
