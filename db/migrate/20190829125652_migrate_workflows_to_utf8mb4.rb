# frozen_string_literal: true

# Autogenerated migration to convert workflows to utf8mb4
class MigrateWorkflowsToUtf8mb4 < ActiveRecord::Migration[5.1]
  include MigrationExtensions::EncodingChanges

  def change
    change_encoding('workflows', from: 'latin1', to: 'utf8mb4')
  end
end