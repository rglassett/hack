require_relative 'core_extensions/string/string'
require_relative 'hack/assembly'
require_relative 'hack/virtual_machine'

module Hack; end

String.include(CoreExtensions::String)
