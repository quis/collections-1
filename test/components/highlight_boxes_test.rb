require 'component_test_helper'

class HighlightBoxesTest < ComponentTestCase
  def component_name
    "highlight-boxes"
  end

  test "renders nothing if no items are provided" do
    assert_empty render_component(
      items: []
    )
  end

  test "fails to render highlight boxes when no link text is provided" do
    assert_raise do
      render_component(
        items: [
          link: {
            path: '/education'
          },
          metadata: {
            organisation: "Department of Education"
          }
        ]
      )
    end
  end

  test "fails to render highlight boxes when no link path is provided" do
    assert_raise do
      render_component(
        items: [
          link: {
            text: 'Department of Education'
          },
          metadata: {
            organisation: "Department of Education"
          }
        ]
      )
    end
  end

  test "renders correct link text and path" do
    render_component(
      items: [
        link: {
          text: 'Become an apprentice',
          path: '/become-an-apprentice'
        }
      ]
    )

    assert_select ".app-c-highlight-boxes__title[href=\"/become-an-apprentice\"]", text: 'Become an apprentice'
  end

  test "renders a description if provided" do
    render_component(
      items: [
        link: {
          text: 'Become an apprentice',
          path: '/become-an-apprentice',
          description: "How to become an apprentice"
        }
      ]
    )

    assert_select ".app-c-highlight-boxes__description", text: 'How to become an apprentice'
  end

  test "renders metadata if provided" do
    render_component(
      items: [
        link: {
          text: 'Become an apprentice',
          path: '/become-an-apprentice',
          description: "How to become an apprentice"
        },
        metadata: {
          public_updated_at: Time.zone.parse("2017-01-05 14:50:33 +0000"),
          organisations: 'Department of Education',
          document_type: 'Guide'
        }
      ]
    )

    assert_select ".app-c-highlight-boxes__metadata", text: 'Guide'
    assert_select "time[datetime='2017-01-05T14:50:33Z']"
    assert_select ".app-c-highlight-boxes__metadata", text: 'Department of Education'
  end

  test "renders multiple content items" do
    render_component(
      items: [
        {
          link: {
            text: 'Become an apprentice',
            path: '/become-an-apprentice',
            description: "How to become an apprentice"
          },
          metadata: {
            public_updated_at: Time.zone.parse("2016-06-27 14:50:33 +0000"),
            organisations: 'Department of Education',
            document_type: 'Guide'
          }
        },
        {
          link: {
            text: 'Student finance',
            path: '/student-finance',
            description: "Student finance"
          },
          metadata: {
            public_updated_at: Time.zone.parse("1994-11-21 14:50:33 +0000"),
            organisations: 'Department of Education',
            document_type: 'Detailed Guide'
          }
        }
      ]
    )

    assert_select ".app-c-highlight-boxes__item .app-c-highlight-boxes__title[href=\"/become-an-apprentice\"]", text: 'Become an apprentice'
    assert_select ".app-c-highlight-boxes__item .app-c-highlight-boxes__description", text: 'How to become an apprentice'
    assert_select ".app-c-highlight-boxes__metadata", text: 'Guide'
    assert_select "time[datetime='2016-06-27T14:50:33Z']"
    assert_select ".app-c-highlight-boxes__metadata", text: 'Department of Education'

    assert_select ".app-c-highlight-boxes__item .app-c-highlight-boxes__title[href=\"/student-finance\"]", text: 'Student finance'
    assert_select ".app-c-highlight-boxes__item .app-c-highlight-boxes__description", text: 'Student finance'
    assert_select ".app-c-highlight-boxes__metadata", text: 'Detailed Guide'
    assert_select "time[datetime='1994-11-21T14:50:33Z']"
    assert_select ".app-c-highlight-boxes__metadata", text: 'Department of Education'
  end

  test "adds inverse class when inverse flag passed" do
    render_component(
      inverse: true,
      items: [
        link: {
          text: 'Become an apprentice',
          path: '/become-an-apprentice',
          description: "How to become an apprentice"
        },
        metadata: {
          public_updated_at: Time.zone.parse("2017-01-05 14:50:33 +0000"),
          organisations: 'Department of Education',
          document_type: 'Guide'
        }
      ]
    )

    assert_select ".app-c-highlight-boxes__item.app-c-highlight-boxes--inverse"
  end

  test "adds featured class when featured flag passed" do
    render_component(
      items: [
        link: {
          text: 'Become an apprentice',
          path: '/become-an-apprentice',
          description: "How to become an apprentice",
          featured: true
        },
        metadata: {
          public_updated_at: Time.zone.parse("2017-01-05 14:50:33 +0000"),
          organisations: 'Department of Education',
          document_type: 'Guide'
        }
      ]
    )

    assert_select ".app-c-highlight-boxes__title.app-c-highlight-boxes__title--featured"
  end

  test "adds data tracking attributes when data_attributes provided" do
    render_component(
      items: [
        {
          link: {
            text: 'Become an apprentice',
            path: '/become-an-apprentice',
            description: "How to become an apprentice",
            data_attributes: {
              track_category: "servicesHighlightBoxClicked",
              track_action: 1,
              track_label: "/becoming-an-apprentice"
            }
          },
          metadata: {
            public_updated_at: Time.zone.parse("2016-06-27 14:50:33 +0000"),
            organisations: 'Department of Education',
            document_type: 'Guide'
          }
        },
        {
          link: {
            text: 'Student finance',
            path: '/student-finance',
            description: "Student finance",
            data_attributes: {
              track_category: "servicesHighlightBoxClicked",
              track_action: 2,
              track_label: "/student-finance",
              track_options: {
                dimension28: 2,
                dimension29: "Student Finance"
              }
            }
          },
          metadata: {
            public_updated_at: Time.zone.parse("1994-11-21 14:50:33 +0000"),
            organisations: 'Department of Education',
            document_type: 'Detailed Guide'
          }
        }
      ]
    )

    assert_select ".app-c-highlight-boxes__title[data-track-category='servicesHighlightBoxClicked']"
    assert_select ".app-c-highlight-boxes__title[data-track-action='1']"
    assert_select ".app-c-highlight-boxes__title[data-track-label='/becoming-an-apprentice']"

    assert_select ".app-c-highlight-boxes__title[data-track-action='2']"
    assert_select ".app-c-highlight-boxes__title[data-track-label='/student-finance']"
    assert_select ".app-c-highlight-boxes__title[data-track-options='{\"dimension28\":2,\"dimension29\":\"Student Finance\"}']"
  end
end
