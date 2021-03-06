# frozen_string_literal: true

# Autogenerated migration to convert plate_volumes to utf8mb4
class MigratePlateVolumesToUtf8mb4 < ActiveRecord::Migration[5.1]
  include MigrationExtensions::EncodingChanges

  def change
    change_encoding('plate_volumes', from: 'latin1', to: 'utf8mb4')
  end
end
