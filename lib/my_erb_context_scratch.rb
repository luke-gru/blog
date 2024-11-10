# frozen_string_literal: true
class MyErbContext < Erubis::Context
  include Rails.application.routes.url_helpers
  # allow url_for in erb template
  include ActionView::RoutingUrlFor
  # allow calling `render`
  include ActionView::Helpers::RenderingHelper
  include PostHelper

  delegate :in_rendering_context, :view_renderer, :compiled_method_container, :_run, to: :@base

  class MyViewClass < ActionView::Base
    def initialize(lookup_context, assigns, controller, erb_context, params = {})
      super(lookup_context, assigns, controller)
      @_my_erb_context = erb_context
      @_my_params = params
    end

    def compiled_method_container
      singleton_class
    end

    def controller
      fake = Object.new
      params = @_my_params
      fake.define_singleton_method(:params) do
        params
      end
      fake
    end

    def method_missing(name, *args, &block)
      if @_my_erb_context.respond_to?(name, true)
        @_my_erb_context.send(name, *args, &block)
      else
        super
      end
    end
  end

  def initialize(vars = {})
    super()
    params = vars[:params] || {}
    vars.each do |var, val|
      self[var] = val
      self.singleton_class.attr_reader(var)
    end
    lookup_context = ActionView::LookupContext.new(
      Dir.glob(Rails.root.join('app', 'views', '*'))
    )
    # this object renders partials in the context
    @base = MyViewClass.new(lookup_context, vars.dup, nil, self, params)
  end

  def routes
    Rails.application.routes
  end

  def controller # this is needed
  end

  def default_url_options
    { only_path: true, locale: I18n.locale }
  end
end
