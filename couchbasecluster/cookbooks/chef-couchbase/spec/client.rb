# encoding: utf-8
require 'chefspec'
require 'spec_helper'
require 'fauxhai'

describe 'couchbase::client_clibrary' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
    end.converge(described_recipe)
  end

  it 'run install client library' do
    expect(chef_run).to couchbase_install_clientlibrary('self')
  end
end
