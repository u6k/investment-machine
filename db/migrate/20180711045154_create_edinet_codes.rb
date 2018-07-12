class CreateEdinetCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :edinet_codes do |t|
      t.string :edinet_code
      t.string :submitter_type
      t.string :listed
      t.string :consolidated
      t.decimal :capital
      t.string :settlement_date
      t.string :submitter_name
      t.string :submitter_name_en
      t.string :submitter_name_yomi
      t.string :address
      t.string :industry
      t.string :ticker_symbol
      t.string :corporate_number

      t.timestamps
    end
  end
end
