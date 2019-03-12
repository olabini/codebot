# frozen_string_literal: true

require 'codebot/formatters/gitlab_helpers'

RSpec.describe Codebot::Formatters::Gitlab::JobHook do
  describe '.format' do
    it 'formats correctly one entry' do
      formatter = load_formatter_from('gitlab_job_hook_1',
                                      Codebot::Formatters::Gitlab::JobHook)
      result = remove_color_highlight(formatter.format)
      expect(result).to eq(['[gitlab_test] job \'test\' (shortened://http://192.168.64.1:3005/gitlab-org/gitlab-test/-/jobs/1977) was created from commit:', 'gitlab_test/gitlab-script-trigger 2366 : test'])
    end

    it 'formats correctly another entry' do
      formatter = load_formatter_from('gitlab_job_hook_2',
                                      Codebot::Formatters::Gitlab::JobHook)
      result = remove_color_highlight(formatter.format)
      expect(result).to eq(['[website-autonomia.digital] job \'build\' (shortened://https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital/-/jobs/526) succeeded'])
    end
  end
end
