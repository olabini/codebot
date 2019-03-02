# frozen_string_literal: true

require 'codebot/formatters/gitlab_helpers'

RSpec.describe Codebot::Formatters::Gitlab::PushHook do
  describe '.format' do
    it 'formats correctly one entry' do
      formatter = load_formatter_from('gitlab_push_hook_1.json',
                                      Codebot::Formatters::Gitlab::PushHook)
      result = remove_color_highlight(formatter.format)
      expect(result.length).to eq 3
      expect(result[0]).to eq '[Diaspora] John Smith pushed 4 new commits to master: shortened://http://example.com/mike/diaspora/compare/95790bf891e76fee5e1747ab589903a6a1f80f22...95790bf891e76fee5e1747ab589903a6a1f80f22'
      expect(result[1]).to eq 'Diaspora/master b6568db Jordi Mallach: Update Catalan translation to e38cb41. ...'
      expect(result[2]).to eq 'Diaspora/master da15608 GitLab dev user: fixed readme'
    end

    it 'formats correctly another entry' do
      formatter = load_formatter_from('gitlab_push_hook_2.json',
                                      Codebot::Formatters::Gitlab::PushHook)
      result = remove_color_highlight(formatter.format)
      expect(result.length).to eq 4
      expect(result[0]).to eq '[website-autonomia.digital] Ola Bini pushed 3 new commits to master: shortened://https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital/compare/2e01949d75647f5d3ac0f76729e71c60ca79431a...2e01949d75647f5d3ac0f76729e71c60ca79431a'
      expect(result[1]).to eq 'website-autonomia.digital/master 119f844 Ola Bini: Remove the testing text'
      expect(result[2]).to eq 'website-autonomia.digital/master 5ace583 Ola Bini: It\'s great to have rsync installed...'
      expect(result[3]).to eq 'website-autonomia.digital/master 2e01949 Ola Bini: Add staging and production passes'
    end
  end
end
