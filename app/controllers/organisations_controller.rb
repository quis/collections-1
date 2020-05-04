class OrganisationsController < ApplicationController
  skip_before_action :set_expiry
  before_action -> { set_expiry(5.minutes) }
  before_action :set_locale, only: %i[show court]

  def index
    @organisations = ContentStoreOrganisations.find!("/government/organisations")
    @presented_organisations = presented_organisations
    setup_content_item_and_navigation_helpers(@organisations)
  end

  def show
    raise "This is an intended exception"
    @organisation = Organisation.find!(request.path)
    setup_content_item_and_navigation_helpers(@organisation)

    @show = Organisations::ShowPresenter.new(@organisation)
    @header = Organisations::HeaderPresenter.new(@organisation)
    @documents = Organisations::DocumentsPresenter.new(@organisation)
    @supergroups = Organisations::SupergroupsPresenter.new(@organisation)
    @what_we_do = Organisations::WhatWeDoPresenter.new(@organisation)
    @people = Organisations::PeoplePresenter.new(@organisation)
    @not_live = Organisations::NotLivePresenter.new(@organisation)
    @contacts = Organisations::ContactsPresenter.new(@organisation)

    render organisation_view, locals: { organisation: @organisation }
  end

  def court
    @organisation = Organisation.find!(request.path)
    setup_content_item_and_navigation_helpers(@organisation)

    @show = Organisations::ShowPresenter.new(@organisation)
    @header = Organisations::HeaderPresenter.new(@organisation)
    @what_we_do = Organisations::WhatWeDoPresenter.new(@organisation)
    @contacts = Organisations::ContactsPresenter.new(@organisation)

    render organisation: @organisation
  end

private

  def organisation_view
    @organisation.is_live? ? "show" : "separate_website"
  end

  def presented_organisations
    @presented_organisations ||= Organisations::IndexPresenter.new(@organisations)
  end

  def locale
    ".#{params[:locale]}" if params[:locale]
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
