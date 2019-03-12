# frozen_string_literal: true

require 'codebot/formatters/gitlab_helpers'

RSpec.describe Codebot::Formatters::Gitlab::NoteHook do
  describe '.format' do
    context 'on issue note' do
      it 'formats correctly one entry' do
        result = do_format_test('gitlab_note_hook_issue_1',
                                Codebot::Formatters::Gitlab::NoteHook)
        expect(result).to eq ['[gitlab-org/gitlab-test] Administrator commented on issue #17: Hello world: shortened://http://example.com/gitlab-org/gitlab-test/issues/17#note_1241']
      end

      it 'formats correctly another entry' do
        result = do_format_test('gitlab_note_hook_issue_2',
                                Codebot::Formatters::Gitlab::NoteHook)
        expect(result).to eq ['[infrastructure/website-autonomia.digital] Ola Bini commented on issue #1: mentioned in commit bd05f5326f6fc05c2d2f0f35095c68a5c4fc94c1: shortened://https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital/issues/1#note_4336']
      end
    end

    context 'on code snippet' do
      it 'formats correctly one entry' do
        result = do_format_test('gitlab_note_hook_code_snippet_1',
                                Codebot::Formatters::Gitlab::NoteHook)
        expect(result).to eq ['[gitlab-org/gitlab-test] Administrator commented on code snippet \'test\': Is this snippet doing what it\'s supposed to be doing? ...: shortened://http://example.com/gitlab-org/gitlab-test/snippets/53#note_1245']
      end
    end

    context 'on merge request' do
      it 'formats correctly one entry' do
        result = do_format_test('gitlab_note_hook_merge_request_1',
                                Codebot::Formatters::Gitlab::NoteHook)
        expect(result).to eq ['[gitlab-org/gitlab-test] Administrator commented on merge request \'Tempora et eos debitis quae laborum et.\': This MR needs work. ...: shortened://http://example.com/gitlab-org/gitlab-test/merge_requests/1#note_1244']
      end
    end

    context 'on commit' do
      it 'formats correctly one entry' do
        result = do_format_test('gitlab_note_hook_commit_1',
                                Codebot::Formatters::Gitlab::NoteHook)
        expect(result).to eq ['[gitlabhq/gitlab-test] Administrator commented on commit cfe32cf: This is a commit comment. How does this work? ...: shortened://http://example.com/gitlab-org/gitlab-test/commit/cfe32cf61b73a0d5e9f13e774abde7ff789b1660#note_1243']
      end
    end
  end
end
