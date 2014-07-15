# Set @@variable_name in a before(:all) block and give access to it
# via let(:variable_name)
#
# Example:
# describe Transaction do
#   set(:transaction) { Factory(:transaction) }
#
#   it "should be in progress" do
#     transaction.state.should == 'in_progress'
#   end
# end
def set(variable_name, &block)
  before(:all) do
    self.class.send(:class_variable_set,
                    "@@#{variable_name}".to_sym, instance_eval(&block))
  end
  let(variable_name) do
    self.class.send(:class_variable_get, "@@#{variable_name}".to_sym
                   ).tap do |i|
      i.reload if i.respond_to?(:new_record?) && !i.new_record?
    end
  end
end
