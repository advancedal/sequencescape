# frozen_string_literal: true

# Class to test SPrint.
class Sprint < ApplicationRecord
  # rubocop:disable Rails/Output
  require 'uri'
  require 'erb'

  def self.send_print_request(printer_name, label_template_name, merge_fields_list)
    response = SprintClient.send_print_request(printer_name, label_template_name, merge_fields_list)

    puts 'response'
    puts response
  end
  # rubocop:enable Rails/Output
end
