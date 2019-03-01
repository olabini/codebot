# frozen_string_literal: true

module Codebot
  module Formatters
    # This class formats ping events.
    class Ping < Formatter
      # Formats IRC messages for a ping event.
      #
      # @return [Array<String>] the formatted messages
      def format
        ["#{summary}: #{format_url url}"]
      end

      def summary
        default_format.format(
          scope: format_scope,
          sender: format_user(sender_name),
          events: format_events
        )
      end

      def default_format
        '[%<scope>s] %<sender>s added a webhook for %<events>s'
      end

      def summary_url
        case extract(:hook, :type)
        when /\Aorganization\z/i
          login = extract(:organization, :login).to_s
          "https://github.com/#{login}"
        when /\Arepository\z/i
          extract(:repository, :html_url).to_s
        end
      end

      def format_events
        if hook_events.empty?
          'no events'
        elsif hook_events.include? '*'
          format_event 'all events'
        else
          format_events_some
        end
      end

      def format_events_some
        if hook_events.length > 5
          "#{format_number(hook_events.length)} events"
        elsif hook_events.one?
          "the #{format_event hook_events.first} event"
        else
          "the #{formatted_hook_events} events"
        end
      end

      def hook_events
        extract(:hook, :events).to_a.uniq
      end

      def formatted_hook_events
        ary_to_sentence(hook_events.sort.map { |event| format_event event })
      end

      # Formats the name of the repository or organization the webhook belongs
      # to.
      #
      # @return [String] the formatted scope
      def format_scope
        case extract(:hook, :type)
        when /\Aorganization\z/i
          format_user extract(:organization, :login)
        when /\Arepository\z/i
          login = extract(:repository, :owner, :login)
          "#{format_user login}/#{format_repository repository_name}"
        end
      end
    end
  end
end
