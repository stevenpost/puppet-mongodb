# frozen_string_literal: true

require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  describe 'mongodb_version' do
    context 'with value' do
      before do
        allow(Facter::Core::Execution).to receive(:which).with('mongod').and_return(true)
        allow(Facter::Core::Execution).to receive(:execute).with('mongod --version 2>&1').and_return('db version v5.0.6')
      end

      it {
        expect(Facter.fact(:mongodb_version).value).to eq('5.0.6')
      }
    end
  end
end
