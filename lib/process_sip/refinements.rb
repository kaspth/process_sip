# frozen_string_literal: true

module ProcessSip::Refinements
  refine(String) { def dasherize = tr("_", "-") }
  refine(Symbol) { def dasherize = name.dasherize }

  refine Enumerable do
    def index_with(default) = to_h { [ _1, default ] }
  end
end
