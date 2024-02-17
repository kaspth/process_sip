# frozen_string_literal: true

require "test_helper"

class TestProcessSip < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ProcessSip::VERSION
  end

  def test_execution
    assert_output "hey" do
      ProcessSip.echo.exec "hey"
    end
  end
end
