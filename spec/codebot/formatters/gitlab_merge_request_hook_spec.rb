# frozen_string_literal: true

require 'codebot/formatters/gitlab_helpers'

RSpec.describe Codebot::Formatters::Gitlab::MergeRequestHook do
  describe '.format' do
    it 'formats correctly one entry' do
      result = do_format_test('gitlab_merge_request_hook_1',
                              Codebot::Formatters::Gitlab::MergeRequestHook)
      expect(result).to eq ['[gitlabhq/gitlab-test] Administrator opened merge request \'MS-Viewport\': shortened://http://example.com/diaspora/merge_requests/1']
    end
  end
end
