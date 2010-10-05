require "spec_helper"

describe Hash do
  describe "#namespace_flatten" do
    it "should return flatten hash with namespaced keys" do
      h = {
        :foobar => "a",
        :foo => {
          :bar => {
            :text => "foobar"
          },
          :a => [1,2,3]
        },
        :b => "b"
      }

      result = {
        "foobar" => "a",
        "foo.bar.text" => "foobar",
        "foo.a" => [1,2,3],
        "b" => "b"
      }

      h.namespace_flatten.should == result
    end
  end
end