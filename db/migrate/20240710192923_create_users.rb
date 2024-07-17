# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, limit: 200, null: false
      t.string :phone_number, limit: 20, null: false
      t.string :full_name, limit: 200
      t.string :password, limit: 100, null: false
      t.string :key, limit: 100, null: false
      t.string :account_key, limit: 100
      t.text :metadata, limit: 2000

      t.timestamps
    end
  end
end
