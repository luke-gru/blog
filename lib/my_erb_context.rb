# frozen_string_literal: true
class MyErbContext < Erubis::Context
  include Rails.application.routes.url_helpers
  # allow url_for in erb template
  include ActionView::RoutingUrlFor

  def initialize(vars = {})
    super()
    vars.each do |var, val|
      self[var] = val
      self.singleton_class.attr_reader(var)
    end
  end

  def routes
    Rails.application.routes
  end

  def controller # this is needed
  end

  def default_url_options
    { only_path: true }
  end
end
