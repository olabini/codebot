# frozen_string_literal: true

module Codebot
  module Formatters
    module Gitlab
      # Triggered on status change of pipeline
      class PipelineHook < Formatter
        def pipeline_status
          extract(:object_attributes, :status)
        end

        def format_job_status # rubocop:disable Metrics/MethodLength
          case pipeline_status
          when 'created'
            'was created from commit'
          when 'success'
            'succeeded'
          when 'skipped'
            'was skipped'
          when /^fail/, /^err/
            "failed: #{extract(:object_attributes, :detailed_status)}"
          else
            "did something: #{pipeline_status}"
          end
        end

        def pipeline_id
          extract(:object_attributes, :id)
        end

        def format # rubocop:disable Metrics/MethodLength
          repo_url = extract(:project, :web_url)
          repo_name = extract(:project, :path_with_namespace)

          pipeline_url = shorten_url "#{repo_url}/pipelines/#{pipeline_id}"
          reply = '[%<repository>s] pipeline %<status>s (%<url>s)'.format(
            repository: format_repository(repo_name),
            status: format_job_status,
            url: pipeline_url
          )

          if pipeline_status == 'created'
            [reply + ':'] + [format_commit(extract(:commit))]
          else
            [reply]
          end
        end
      end
    end
  end
end
