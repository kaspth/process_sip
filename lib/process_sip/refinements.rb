# frozen_string_literal: true

module ProcessSip::Refinements
  refine(Symbol) { def dasherize = name.dasherize }
  refine(String) { def dasherize = tr("_", "-") }

  refine Object do
    def clone_with(**instance_variables)
      clone.tap do |object|
        instance_variables.each { object.instance_variable_set "@#{_1}", _2 }
      end
    end
  end
end
