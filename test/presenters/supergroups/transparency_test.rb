require 'test_helper'

include RummagerHelpers

describe Supergroups::Transparency do
  let(:taxon_id) { '12345' }
  let(:transparency_supergroup) { Supergroups::Transparency.new }

  describe '#document_list' do
    it 'returns a document list for the transparency supergroup' do
      MostRecentContent.any_instance
        .stubs(:fetch)
        .returns(section_tagged_content_list('statistics'))

      expected = [
        {
          link: {
            text: 'Tagged Content Title',
            path: '/government/tagged/content'
          },
          metadata: {
            public_updated_at: '2018-02-28T08:01:00.000+00:00',
            organisations: 'Tagged Content Organisation',
            document_type: 'Statistics'
          }
        }
      ]

      assert_equal expected, transparency_supergroup.document_list(taxon_id)
    end
  end
end
