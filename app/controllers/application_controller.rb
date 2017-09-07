class ApplicationController < ActionController::Base
  include Slimmer::Template
  include Slimmer::GovukComponents

  protect_from_forgery with: :exception

  before_action :set_expiry
  before_action :restrict_request_formats

  rescue_from GdsApi::ContentStore::ItemNotFound, with: :error_404

  # Allows additional request formats to be enabled.
  #
  # By default, PublicFacingController actions will only respond to HTML requests. To enable
  # additional formats on any given action, use this helper method. For example:
  #
  #   enable_request_formats index: [:atom, :json]
  #
  # That would allow both atom and JSON requests for the :index action to be processed.
  #
  def self.enable_request_formats(options)
    options.each do |action, formats|
      self.acceptable_formats[action.to_sym] ||= Set.new
      self.acceptable_formats[action.to_sym] += Array(formats)
    end
  end

  def self.acceptable_formats
    @acceptable_formats ||= {}
  end

  def education_ab_test
    @education_ab_test ||= begin
      ab_test_request = EducationNavigationAbTestRequest.new(request)
      ab_test_request.set_response_vary_header(response)
      ab_test_request
    end
  end

  def ab_variant
    dimension = Rails.application.config.navigation_ab_test_dimension
    ab_test = GovukAbTesting::AbTest.new("EducationNavigation", dimension: dimension)
    ab_test.requested_variant(request.headers)
  end

  def configure_ab_response
    ab_variant.configure_response(response)
  end

private

  def restrict_request_formats
    unless can_handle_format?(request.format)
      render status: :not_acceptable, plain: "Request format #{request.format} not handled."
    end
  end

  def can_handle_format?(format)
    return true if format == Mime[:html] || format == Mime::ALL
    format && self.class.acceptable_formats.fetch(params[:action].to_sym, []).include?(format.to_sym)
  end

  def error_404; error 404; end

  def error_410; error 410; end

  def error_503(e); error(503, e); end

  def error(status_code, exception = nil)
    GovukError.notify(exception) if exception
    render status: status_code, plain: "#{status_code} error"
  end

  def set_expiry(duration = 30.minutes)
    unless Rails.env.development?
      expires_in(duration, public: true)
    end
  end

  def setup_content_item_and_navigation_helpers(model)
    @content_item = model.content_item.to_hash
    @navigation_helpers =
      GovukNavigationHelpers::NavigationHelper.new(@content_item)
  end

  def breadcrumb_content
    render_partial(
      '_breadcrumbs',
      navigation_helpers: @navigation_helpers
    )
  end

  def render_partial(partial_name, locals = {})
    render_to_string(partial_name, formats: 'html', layout: false, locals: locals)
  end
end
