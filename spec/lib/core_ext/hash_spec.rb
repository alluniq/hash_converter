require "spec_helper"

describe Hash do
  describe "#namespace_flatten" do
    before do
      @hash = {
        :foobar => "a",
        :foo => {
          :bar => {
            :text => "foobar"
          },
          :a => [1,2,3]
        },
        :b => "b"
      }
    end

    it "should return flatten hash with namespaced keys" do
      result = {
        "foobar" => "a",
        "foo.bar.text" => "foobar",
        "foo.a" => [1,2,3],
        "b" => "b"
      }

      @hash.namespace_flatten.should == result
    end

    it "should flatten with custom separator" do
      result = {
        "foobar" => "a",
        "foo/bar/text" => "foobar",
        "foo/a" => [1,2,3],
        "b" => "b"
      }

      @hash.namespace_flatten("/").should == result
    end
  end
end