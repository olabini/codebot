# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'codebot/metadata'

def description
  text = <<-DESCRIPTION
    Codebot is an IRC bot that receives GitHub webhooks and forwards them to
    IRC channels. It is designed to send messages in a format similar to that
    of the official GitHub IRC Service. Codebot is able to stay connected after
    sending messages. This eliminates the delays and visual clutter caused by
    reconnecting each time a new message has to be delivered.
  DESCRIPTION
  text.gsub(/\s+/, ' ').strip
end

Gem::Specification.new do |spec|
  spec.name          = 'codebot'
  spec.version       = Codebot::VERSION
  spec.authors       = ['Janik Rabe']
  spec.email         = ['codebot@janikrabe.com']
  spec.summary       = 'Forward GitHub webhooks to IRC channels'
  spec.description   = description
  spec.homepage      = 'https://github.com/janikrabe/codebot'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.has_rdoc      = 'yard'
  spec.license       = 'MIT'
  spec.require_paths = ['lib']

  spec.post_install_message = <<-EOF
*****
  ======================
  Discontinuation Notice
  ======================

  As of June 5, 2018, Codebot is no longer maintained.
  For more information, please see https://git.io/codebot#.

  Codebot will continue to receive security updates until May 31, 2019.
*****
EOF

  spec.required_ruby_version = '>= 2.2.0'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.56.0'

  spec.add_runtime_dependency 'cinch', '~> 2.3'
  spec.add_runtime_dependency 'sinatra', '~> 2.0'
  spec.add_runtime_dependency 'thor', '~> 0.20.0'
end
