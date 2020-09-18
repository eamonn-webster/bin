# frozen_string_literal: true

#
# File: dependency_spec.rb
# Author: eweb
# Copyright eweb, 2020-2020
# Contents:
#
# Date:          Author:  Comments:
# 18th Sep 2020  eweb     #0006 specish
#
require 'rspec'

$LOAD_PATH << File.dirname(__FILE__)

require 'dependency'

module Dependencies
  RSpec.describe Dependency do
    let(:source) do
      %(class Foo
ATTRS = %i[name, size]
end)
    end
    let(:parser) { Dependency::Constant.new(source) }

    before do
      parser.parse
    end

    subject { parser.defined }

    it 'prefixes constants' do
      expect(subject).to eq(['Foo::ATTRS', 'Foo'])
    end
  end
end

