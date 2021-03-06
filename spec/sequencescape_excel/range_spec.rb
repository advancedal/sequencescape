# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SequencescapeExcel::Range, type: :model, sample_manifest_excel: true, sample_manifest: true do
  let(:options) { %w[option1 option2 option3] }

  it 'is comparable' do
    attributes = { options: options, first_column: 4, first_row: 5, last_column: 8, last_row: 10, worksheet_name: 'Sheet1' }
    expect(described_class.new(attributes)).to eq(described_class.new(attributes))
    expect(described_class.new(attributes.except(:last_row))).not_to eq(described_class.new(attributes))
  end

  context 'with static options' do
    let(:range) { described_class.new(options: options, first_row: 4) }

    it 'has some options' do
      expect(range.options).to eq(options)
    end

    it 'has a first row' do # rubocop:todo RSpec/AggregateExamples
      expect(range.first_row).to eq(4)
    end

    it 'sets the first column' do # rubocop:todo RSpec/AggregateExamples
      expect(range.first_column).to eq(1)
    end

    it 'sets the last column' do # rubocop:todo RSpec/AggregateExamples
      expect(range.last_column).to eq(3)
      expect(described_class.new(options: options, first_column: 4, first_row: 4).last_column).to eq(6)
    end

    it 'has a first_cell' do # rubocop:todo RSpec/AggregateExamples
      expect(range.first_cell).to eq(SequencescapeExcel::Cell.new(range.first_row, range.first_column))
    end

    it 'has a last_cell' do # rubocop:todo RSpec/AggregateExamples
      expect(range.last_cell).to eq(SequencescapeExcel::Cell.new(range.last_row, range.last_column))
    end

    it 'has a first cell reference' do # rubocop:todo RSpec/AggregateExamples
      expect(range.first_cell_reference).to eq(range.first_cell.reference)
    end

    it 'sets the reference' do # rubocop:todo RSpec/AggregateExamples
      expect(range.reference).to eq("#{range.first_cell.reference}:#{range.last_cell.reference}")
    end

    it 'sets the fixed reference' do # rubocop:todo RSpec/AggregateExamples
      expect(range.fixed_reference).to eq("#{range.first_cell.fixed}:#{range.last_cell.fixed}")
    end

    it '#references should return first_cell reference, reference, fixed_reference and absolute_reference' do # rubocop:todo RSpec/AggregateExamples
      expect(range.references).to eq(first_cell_reference: range.first_cell_reference,
                                     reference: range.reference, fixed_reference: range.fixed_reference,
                                     absolute_reference: range.absolute_reference)
    end

    it 'is static, not dynamic' do # rubocop:todo RSpec/AggregateExamples
      expect(range).to be_static
      expect(range).not_to be_dynamic
    end
  end

  context 'with dynamic options' do
    # Ensure we have at least one option.
    let!(:library_type) { create :library_type }
    let!(:original_option_size) { LibraryType.count }
    let(:attributes) { { name: 'library_type', identifier: :name, scope: :alphabetical, first_row: 4 } }
    let(:range) { described_class.new(attributes) }

    it 'has identifier, scope, options' do
      assert range.identifier
      assert range.scope
      assert_equal original_option_size, range.options.count
    end

    it 'has a first row' do
      assert_equal 4, range.first_row
    end

    it 'sets the first column' do
      assert_equal 1, range.first_column
    end

    it 'sets the last column' do
      assert_equal original_option_size, range.last_column
      assert_equal 3 + original_option_size, described_class.new(attributes.merge(first_column: 4)).last_column
    end

    it 'has a first_cell' do
      assert_equal SequencescapeExcel::Cell.new(range.first_row, range.first_column), range.first_cell
    end

    it 'has a last_cell' do
      assert_equal SequencescapeExcel::Cell.new(range.last_row, range.last_column), range.last_cell
    end

    it 'has a first cell reference' do
      assert_equal range.first_cell.reference, range.first_cell_reference
    end

    it 'sets the reference' do
      assert_equal "#{range.first_cell.reference}:#{range.last_cell.reference}", range.reference
    end

    it 'sets the fixed reference' do
      assert_equal "#{range.first_cell.fixed}:#{range.last_cell.fixed}", range.fixed_reference
    end

    it '#references should return first_cell reference, reference, fixed_reference and absolute_reference' do
      assert_equal({ first_cell_reference: range.first_cell_reference,
                     reference: range.reference, fixed_reference: range.fixed_reference,
                     absolute_reference: range.absolute_reference }, range.references)
    end

    it 'knows it is dynamic' do
      expect(range).not_to be_static
      expect(range).to be_dynamic
    end

    it 'adjusts to changes in option number' do
      previous_last_cell = range.last_cell.column
      create :library_type
      assert_equal original_option_size + 1, range.last_column
      assert_equal previous_last_cell.next, range.last_cell.column
    end
  end

  context 'without first row' do
    let(:range) { described_class.new(options: options) }

    it 'is be valid' do
      expect(range).not_to be_valid
    end

    it 'does not have a first cell' do # rubocop:todo RSpec/AggregateExamples
      expect(range.first_cell).to be_nil
    end

    it 'does not have a last cell' do # rubocop:todo RSpec/AggregateExamples
      expect(range.last_cell).to be_nil
    end
  end

  context 'without options' do
    let(:range) { described_class.new(first_row: 10, last_row: 15, first_column: 3, last_column: 60) }

    it 'has some empty options' do
      expect(range.options).to be_empty
    end

    it 'has a first row' do # rubocop:todo RSpec/AggregateExamples
      expect(range.first_row).to eq(10)
    end

    it 'has a first column' do # rubocop:todo RSpec/AggregateExamples
      expect(range.first_column).to eq(3)
    end

    it 'has a last column' do # rubocop:todo RSpec/AggregateExamples
      expect(range.last_column).to eq(60)
    end

    it 'has a first_cell' do # rubocop:todo RSpec/AggregateExamples
      expect(range.first_cell).to eq(SequencescapeExcel::Cell.new(range.first_row, range.first_column))
    end

    it 'has a last_cell' do # rubocop:todo RSpec/AggregateExamples
      expect(range.last_cell).to eq(SequencescapeExcel::Cell.new(range.last_row, range.last_column))
    end

    it 'sets the fixed_reference' do # rubocop:todo RSpec/AggregateExamples
      expect(range.reference).to eq("#{range.first_cell.reference}:#{range.last_cell.reference}")
    end

    it 'sets the fixed reference' do # rubocop:todo RSpec/AggregateExamples
      expect(range.fixed_reference).to eq("#{range.first_cell.fixed}:#{range.last_cell.fixed}")
    end

    it 'has an absolute reference' do # rubocop:todo RSpec/AggregateExamples
      expect(range.absolute_reference).to eq(range.fixed_reference)
    end

    it '#set_worksheet_name should set worksheet name and modify absolute reference' do
      range.set_worksheet_name 'Sheet1'
      expect(range.worksheet_name).to eq('Sheet1')
      expect(range.absolute_reference).to eq("#{range.worksheet_name}!#{range.fixed_reference}")
    end

    context 'without last row' do
      let(:range) { described_class.new(first_row: 15, first_column: 5, last_column: 15) }

      it 'set last row to first row' do
        expect(range.last_row).to eq(15)
      end
    end

    context 'without last column' do
      let(:range) { described_class.new(first_row: 14, last_row: 25, first_column: 33) }

      it 'set last column to first column' do
        expect(range.last_column).to eq(33)
      end
    end

    context 'with worksheet name' do
      let(:range) { described_class.new(first_row: 10, last_row: 15, first_column: 3, last_column: 60, worksheet_name: 'Sheet1') }

      it 'set worksheet name' do
        expect(range.worksheet_name).to eq('Sheet1')
      end

      it 'set absolute reference' do # rubocop:todo RSpec/AggregateExamples
        expect(range.absolute_reference).to eq("Sheet1!#{range.fixed_reference}")
      end
    end
  end
end
