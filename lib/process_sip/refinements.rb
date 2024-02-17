# frozen_string_literal: true

module ProcessSip::Refinements
  refine(Symbol) { def dasherize = name.dasherize }
  refine(String) { def dasherize = tr("_", "-") }
end
