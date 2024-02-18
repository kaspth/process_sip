# frozen_string_literal: true

require "test_helper"

class ProcessSipTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ProcessSip::VERSION
  end

  def test_execution
    skip "apparently assert_output can't capture stdout from other process"

    assert_output "hey" do
      ProcessSip.echo.call "hey"
    end
  end
end
