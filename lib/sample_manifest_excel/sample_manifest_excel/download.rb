module SampleManifestExcel
  module Download
    STYLES = {unlock: {locked: false, border: { style: :thin, color: "00" }},
              empty_cell: {bg_color: '82CAFA', type: :dxf},
              wrong_value: {bg_color: "FF0000", type: :dxf},
              wrap_text: {alignment: {horizontal: :center, vertical: :center, wrap_text: true}, border: { style: :thin, color: "00", edges: [:left, :right, :top, :bottom] }},
              borders_only: {border: { style: :thin, color: "00" }}}
  end
end