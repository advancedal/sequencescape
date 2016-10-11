# This file is part of SEQUENCESCAPE; it is distributed under the terms of
# GNU General Public License version 1 or later;
# Please refer to the LICENSE and README files for information on licensing and
# authorship of this file.
# Copyright (C) 2015 Genome Research Ltd.

class IlluminaHtp::MxTubeNoQcPurpose < IlluminaHtp::MxTubePurpose

  def mappings
    { 'cancelled' => 'cancelled', 'failed' => 'failed', 'passed' => 'passed' }
  end
  private :mappings

end
