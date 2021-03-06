# frozen_string_literal: true

# Validates the program attribute for PrimerPanel
# A program identifies the PCR program that should be operated at different
# stages of the pipeline (Stages listed in PROGRAMS_LABELS) and the expected
# duration of that step.
class ProgramsValidator < ActiveModel::EachValidator
  # attribute should be of the form:
  # {'pcr 1' => { 'name' => "pcr1 program", 'duration' => 45 },
  #  'pcr 2' => { 'name' => "pcr2 program" , 'duration' => 20 }}

  PROGRAMS_LABELS = ['pcr 1', 'pcr 2'].freeze
  PROGRAMS_PARAMS = %w[name duration].freeze

  def validate_each(record, attribute, value)
    return unless check_hash(record, attribute, value)

    value.each do |program, params|
      record.errors.add attribute, "invalid label #{program}" unless program.in?(PROGRAMS_LABELS)
      params.each do |key, val|
        record.errors.add attribute, "invalid attribute #{key}" unless key.in?(PROGRAMS_PARAMS)
        validate_duration(record, attribute, val) if key == 'duration'
      end
    end
  end

  private

  def check_hash(record, attribute, value)
    return true if value.is_a?(Hash)

    record.errors.add attribute, "is a #{value.class.name}, not a hash"
    false
  end

  def validate_duration(record, attribute, val)
    record.errors.add attribute, 'duration must be a number' if !val.nil? && !valid_number?(val)
  end

  def valid_number?(val)
    true if Integer val
  rescue StandardError
    false
  end
end
