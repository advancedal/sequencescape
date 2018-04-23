# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2011,2012,2013,2014,2015 Genome Research Ltd.

class Io::Tube < Io::Asset
  set_model_for_input(::Tube)
  set_json_root(:tube)
  set_eager_loading { |model| model.include_aliquots_for_api.include_scanned_into_lab_event }

  define_attribute_and_json_mapping("
                                  state  => state
                            purpose.name => purpose.name
                            purpose.uuid => purpose.uuid

                                 closed  => closed
                     concentration.to_f  => concentration
                            volume.to_f  => volume
                        scanned_in_date  => scanned_in_date
                                    role => label.prefix
                            purpose.name => label.text

                       source_plate.uuid  => stock_plate.uuid
            source_plate.barcode_summary  => stock_plate.barcode

                               aliquots  => aliquots

                        barcode_summary  => barcode
  ")
end
