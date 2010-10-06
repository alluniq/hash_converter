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

    it "should parse properly various hashes" do
      {
        :foo => {
          :bar => {
            :text => "foobar"
          },
          :test => {
            :text => "tralalala"
          },
          :footest => {
            :text => "asd"
          }
        }
      }.namespace_flatten.should == {
        "foo.bar.text" => "foobar",
        "foo.test.text" => "tralalala",
        "foo.footest.text" => "asd"
      }

      {
        :foo => {
          :bar => {
            :text => "foobar"
          },
          :test => {
            :text => "tralalala",
            :text2 => "test"
          }
        }
      }.namespace_flatten.should == {
        "foo.bar.text" => "foobar",
        "foo.test.text" => "tralalala",
        "foo.test.text2" => "test"
      }

      {
        :foo => {
          :bar => "bar",
          :foo => "foo",
          :foobar => {
            :bar => "bar",
            :foo => "foo"
          },
          :barfoo => {
            :bar => "bar",
            :foo => "foo"
          }
        }
      }.namespace_flatten.should == {
        "foo.bar" => "bar",
        "foo.foo" => "foo",
        "foo.foobar.bar" => "bar",
        "foo.foobar.foo" => "foo",
        "foo.barfoo.bar" => "bar",
        "foo.barfoo.foo" => "foo"
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
