#!/usr/bin/env ruby
# frozen_string_literal: true
#
# File: dependency.rb
# Author: HipByte
# Copyright (c) 2012-2019, HipByte SPRL and contributors
# All rights reserved.
##
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
##
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
##
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Date:          Author:  Comments:
#  2nd Apr 2018  eweb     #0008 cyclic dependency check
#  7th Apr 2018  eweb     #0007 rubocop
# 19th Jul 2018  eweb     #0008 ruby dependencies
#  5th Aug 2018  eweb     #0008 pass folder to search
# 23rd Nov 2018  eweb     #0007 rubocop
# 16th Nov 2019  eweb     #0008 pass dirs to check and dirs to ignore
# 17th Dec 2019  eweb     #0008 ignore built in classes
# 17th Dec 2019  eweb     #0008 ignore constant assigns
# 17th Dec 2019  eweb     #0008 ignore modules

require 'ripper'

module Dependencies
  class Dependency
    @file_paths = []

    def initialize(paths, dependencies)
      @file_paths = paths.flatten.sort
      @dependencies = dependencies
    end

    def warnings
      @warnings ||= []
    end

    def warn(warning)
      # App.warn(warning)
      warnings << warning
    end

    def cyclic?(dependencies, def_path, ref_path, const)
      deps = dependencies[def_path]
      if deps
        if deps.include?(ref_path)
          warn("Possible cyclical dependency #{const} between #{def_path} and #{ref_path}")
          return true
        end
        deps.each do |file|
          return true if cyclic?(dependencies, file, ref_path, const)
        end
      end

      false
    end

    def consts_defined
      @consts_defined ||= {}
    end

    def consts_referred
      @consts_referred ||= {}
    end

    def run
      @file_paths.each do |path|
        parser = Constant.new(File.read(path))
        parser.parse
        parser.defined.each do |const|
          consts_defined[const] = path
        end
        parser.referred.each do |const|
          consts_referred[const] ||= []
          consts_referred[const] << path
        end
      end

      dependency = @dependencies.dup
      consts_defined.each do |const, def_path|
        if consts_referred[const]
          consts_referred[const].each do |ref_path|
            if def_path != ref_path
              if cyclic?(dependency, def_path, ref_path, const)
                # remove cyclic dependencies
                next
              end

              dependency[ref_path] ||= []
              dependency[ref_path] << def_path
              dependency[ref_path].uniq!
            end
          end
        end
      end
      dependency
    end

    class Constant < Ripper::SexpBuilder
      attr_accessor :defined
      attr_accessor :referred

      def initialize(source)
        @defined  = []
        @referred = []
        super
      end

      def on_const_ref(args)
        return if %w[String Symbol Hash Array Class Module NilClass TrueClass FalseClass Object Integer Numeric].include?(args[1])

        args
      end

      def on_var_field(args)
        args
      end

      def on_var_ref(args)
        type, name, _position = args
        if type == :@const
          @referred << name
          [:referred, name]
        end
      end

      def on_const_path_ref(parent, args)
        type, name, _position = args
        if type == :@const
          @referred << name
          if parent && parent[0] == :referred
            register_referred_constants(parent[1], name)
          end
        end
        args
      end

      def not_on_assign(const, *_args)
        type, name, _position = const
        if type == :@const
          @defined << name
          [:defined, name]
        end
      end

      def on_module(const, *args)
        # handle_module_class_event(const, args)
      end

      def on_class(const, *args)
        handle_module_class_event(const, args)
      end

      def handle_module_class_event(const, *args)
        type, name, _position = const
        if type == :@const
          @defined << name
          @referred.delete(name)
          children = args.flatten
          children.each_with_index do |key, i|
            if key == :defined
              register_defined_constants(name, children[i + 1])
            end
          end
          [:defined, name]
        end
      end

      def register_defined_constants(parent, child)
        construct_nest_constants!(@defined, parent, child)
      end

      def register_referred_constants(parent, child)
        construct_nest_constants!(@referred, parent, child)
      end

      def construct_nest_constants!(consts, parent, child)
        nested = []
        consts.each do |const|
          md = const.match(/^([^:]+)/)
          if md
            nested << "#{parent}::#{const}" if md[0] == child
          end
        end
        consts.concat(nested)
      end
    end
  end
end

def main(argv)
  dependencies = {}
  if argv.empty?
    files = Dir.glob('app/**/*.rb') + Dir.glob('lib/**/*.rb') + Dir.glob('config/**/*.rb')
  else
    files = []
    argv.each do |arg|
      if arg[0] == '-'
        if arg['*']
          files -= Dir.glob(arg[1..-1])
        else
          files -= Dir.glob("#{arg[1..-1]}/**/*.rb")
        end
      else
        files += Dir.glob("#{arg}/**/*.rb")
      end
    end
  end
  d = Dependencies::Dependency.new(files, dependencies)
  d.run
  puts d.warnings.uniq
  puts d.warnings.uniq.count
end

if $PROGRAM_NAME == __FILE__
  main(ARGV)
end
