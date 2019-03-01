# frozen_string_literal: true

# Portions (c) 2008 Logical Awesome, LLC (released under the MIT license).
# See the LICENSE file for the full MIT license text.

module Codebot
  module Formatters
    # This class formats gollum events.
    class Gollum < Formatter
      # Formats IRC messages for a gollum event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{summary}: #{format_url url}"]
      end

      def summary
        default_format % {
          repository: format_repository(repository_name),
          sender: format_user(sender_name),
          summary: (pages.one? ? single_page_summary : multi_page_summary)
        }
      end

      def default_format
        '[%<repository>s] %<sender>s %<summary>s'
      end

      def single_page_summary
        page = pages.first.to_h
        short = prettify page['summary']
        suffix = ": #{short}" unless short.empty?
        "#{page['action']} wiki page #{page['title']}#{suffix}"
      end

      def multi_page_summary
        actions = []
        counts = action_counts
        counts.each { |verb, num| actions << "#{verb} #{format_number num}" }
        changes = ary_to_sentence(
          actions,
          'pushed an empty commit that did not affect any'
        )
        singular_noun = counts.last.to_a.last.to_i.eql?(1)
        "#{changes} wiki #{singular_noun ? 'page' : 'pages'}"
      end

      def action_counts
        Hash.new(0).tap do |hash|
          pages.each { |page| hash[page['action']] += 1 }
        end.sort
      end

      def summary_url
        if pages.one?
          pages.first['html_url'].to_s
        else
          "#{repository_url}/wiki"
        end
      end

      def pages
        extract(:pages).to_a
      end
    end
  end
end
