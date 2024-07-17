# frozen_string_literal: true

class AlterMetadataType < ActiveRecord::Migration[7.1]
  def up
    change_column(:users, :metadata, :string)
  end

  def down
    change_column(:users, :metadata, :text)
  end
end
