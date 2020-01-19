require File.dirname(__FILE__) + '/../test_helper'
require 'qufoto_controller'

# Re-raise errors caught by the controller.
class QufotoController; def rescue_action(e) raise e end; end

class QufotoControllerTest < Test::Unit::TestCase
  def setup
    @controller = QufotoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
