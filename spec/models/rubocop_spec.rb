require 'spec_helper'

describe 'rubocop' do

  it 'should conform' do
    system('rubocop').should be_true
  end

end
