# frozen_string_literal: true

module ProcessSip::Extensions
  refine Symbol do
    def dasherize
      name.dasherize
    end
  end

  refine String do
    def dasherize
      tr("_", "-")
    end
  end

  refine Enumerable do
    def index_with(default)
      to_h { [ _1, default ] }
    end
  end
end
