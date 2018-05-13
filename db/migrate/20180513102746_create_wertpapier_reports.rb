class CreateWertpapierReports < ActiveRecord::Migration[5.1]
  def change
    create_table :wertpapier_reports do |t|
      t.string :ticker_symbol
      t.string :entry_id
      t.string :title
      t.string :content_type
      t.datetime :entry_updated
      t.timestamps
    end
  end
end
