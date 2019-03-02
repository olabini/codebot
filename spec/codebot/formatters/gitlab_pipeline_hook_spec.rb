# frozen_string_literal: true

require 'codebot/formatters/gitlab_helpers'

RSpec.describe Codebot::Formatters::Gitlab::PipelineHook do
  describe '.format' do
    it 'formats correctly one entry' do
      formatter = load_formatter_from('gitlab_pipeline_hook_1',
                                      Codebot::Formatters::Gitlab::PipelineHook)
      result = remove_color_highlight(formatter.format)
      expect(result).to eq(['[gitlab-org/gitlab-test] pipeline succeeded (shortened://http://192.168.64.1:3005/gitlab-org/gitlab-test/pipelines/31)'])
    end

    it 'formats correctly another entry' do
      formatter = load_formatter_from('gitlab_pipeline_hook_2',
                                      Codebot::Formatters::Gitlab::PipelineHook)
      result = remove_color_highlight(formatter.format)
      expect(result).to eq(['[infrastructure/website-autonomia.digital] pipeline succeeded (shortened://https://gitlab.autonomia.digital/infrastructure/website-autonomia.digital/pipelines/288)'])
    end
  end
end
