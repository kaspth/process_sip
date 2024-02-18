# frozen_string_literal: true

require "test_helper"

class ProcessSipTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ProcessSip::VERSION
  end

  def test_execution
    assert_equal "hey", ProcessSip.echo.call("hey")
  end
end
