class CreateWertpapierReports < ActiveRecord::Migration[5.1]
  def change
    create_table :wertpapier_reports do |t|
      t.string :ticker_symbol
      t.string :doc_id
      t.string :title
      t.date :date_from
      t.date :date_to

      t.timestamps
    end
  end
end
