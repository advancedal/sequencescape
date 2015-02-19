#This file is part of SEQUENCESCAPE is distributed under the terms of GNU General Public License version 1 or later;
#Please refer to the LICENSE and README files for information on licensing and authorship of this file.
#Copyright (C) 2014 Genome Research Ltd.
##
# A Qcable is an element of a lot which must be approved
# before it may be used.

# require 'qcable/state_machine'

class Qcable < ActiveRecord::Base

  include Uuid::Uuidable
  include AASM
  include Qcable::Statemachine

  belongs_to :lot, :inverse_of => :qcables
  belongs_to :asset
  belongs_to :qcable_creator, :inverse_of => :qcables

  has_one :stamp_qcable, :inverse_of => :qcable, :class_name => 'Stamp::StampQcable'
  has_one :stamp, :through => :stamp_qcable

  validates_presence_of :lot, :asset, :state, :qcable_creator

  before_validation :create_asset!

  delegate :bed, :order, :to => :stamp_qcable, :nil => true

  named_scope :include_for_json, { :include => [:asset,:lot,:stamp,:stamp_qcable] }

  named_scope :stamped, {
    :include => [:stamp_qcable, :stamp],
    :conditions => 'stamp_qcables.id IS NOT NULL',
      :order => 'stamps.created_at ASC, stamp_qcables.order ASC'
  }

  # We accept not only an individual barcode but also an array of them.  This builds an appropriate
  # set of conditions that can find any one of these barcodes.  We map each of the individual barcodes
  # to their appropriate query conditions (as though they operated on their own) and then we join
  # them together with 'OR' to get the overall conditions.
  named_scope :with_machine_barcode, lambda { |*barcodes|
    query_details = barcodes.flatten.map do |source_barcode|
      barcode_number = Barcode.number_to_human(source_barcode)
      prefix_string  = Barcode.prefix_from_barcode(source_barcode)
      barcode_prefix = BarcodePrefix.find_by_prefix(prefix_string)

      if barcode_number.nil? or prefix_string.nil? or barcode_prefix.nil?
        { :query => 'FALSE' }
      else
        { :query => '(wam_asset.barcode=? AND wam_asset.barcode_prefix_id=?)', :conditions => [ barcode_number, barcode_prefix.id ] }
      end
    end.inject({ :query => ['FALSE'], :conditions => [nil], :joins=>['LEFT JOIN assets AS wam_asset ON qcables.asset_id = wam_asset.id'] }) do |building, current|
      building.tap do
        building[:joins]      << current[:joins]
        building[:query]      << current[:query]
        building[:conditions] << current[:conditions]
      end
    end

    {
      :conditions => [ query_details[:query].join(' OR '), *query_details[:conditions].flatten.compact ],
      :joins => query_details[:joins].compact.uniq
    }
  }

  def stamp_index
    return nil if stamp_qcable.nil?
    lot.qcables.stamped.index(self)
  end

  private

  def asset_purpose
    lot.target_purpose
  end

  def create_asset!
    return true if lot.nil?
    self.asset ||= asset_purpose.create!()
  end

end
