# frozen_string_literal: true

require 'codebot/formatters/gitlab_helpers'

RSpec.describe Codebot::Formatters::Gitlab::IssueHook do
  describe '.format' do
    it 'formats correctly one entry' do
      formatter = load_formatter_from('gitlab_issue_hook_1.json',
                                      Codebot::Formatters::Gitlab::IssueHook)
      result = remove_color_highlight(formatter.format)
      expect(result).to eq(['[gitlabhq/gitlab-test] Administrator opened issue #23: New API: create/update/delete file: shortened://http://example.com/diaspora/issues/23'])
    end

    # it 'formats correctly another entry' do
    # end
  end
end
