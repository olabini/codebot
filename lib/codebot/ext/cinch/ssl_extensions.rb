# frozen_string_literal: true

require 'cinch'

module Codebot
  # Extensions
  module Ext
    # Cinch extensions
    module Cinch
      # Cinch SSL extensions
      module SSLExtensions
        # Patch the OpenSSL::SSL::SSLContext#ca_path= method to set cert_store
        # to the default certificate store, which Cinch does not currently do.
        def ca_path=(path)
          if caller(1..1).first.include?('/lib/cinch/')
            puts "Codebot: patching Cinch to use the default certificate store"
            self.cert_store = OpenSSL::X509::Store.new.tap(&:set_default_paths)
          end
          super
        end
      end
    end
  end
end

module OpenSSL
  module SSL
    # Patch class OpenSSL::SSL::SSLContext
    class SSLContext
      prepend Codebot::Ext::Cinch::SSLExtensions
    end
  end
end
