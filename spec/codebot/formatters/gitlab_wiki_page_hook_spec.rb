# frozen_string_literal: true

require 'codebot/formatters/gitlab_helpers'

RSpec.describe Codebot::Formatters::Gitlab::WikiPageHook do
  describe '.format' do
    it 'formats correctly one entry' do
      result = do_format_test('gitlab_wiki_page_hook_1',
                              Codebot::Formatters::Gitlab::WikiPageHook)
      expect(result).to eq ['[root/awesome-project] Administrator created page \'Awesome\': shortened://http://example.com/root/awesome-project/wikis/awesome']
    end

    it 'formats correctly another entry' do
      result = do_format_test('gitlab_wiki_page_hook_2',
                              Codebot::Formatters::Gitlab::WikiPageHook)
      expect(result).to eq ['[infrastructure/management] Ola Bini created page \'Infrastructure Onboarding\': shortened://https://gitlab.autonomia.digital/infrastructure/management/wikis/Infrastructure-Onboarding']
    end
  end
end
