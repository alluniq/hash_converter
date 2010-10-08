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

  describe "#namespace_unflatten" do
    before do
      @hash = {
        "foobar" => "a",
        "foo" => {
          "bar" => {
            "text" => "foobar"
          },
          "a" => [1,2,3]
        },
        "b" => "b"
      }
    end

    it "should properly convert various hashes" do
      {
        "foo.bar.text" => "foobar",
        "foo.test.text" => "tralalala",
        "foo.footest.text" => "asd"
      }.namespace_unflatten.should == {
        "foo" => {
          "bar" => {
            "text" => "foobar"
          },
          "test" => {
            "text" => "tralalala"
          },
          "footest" => {
            "text" => "asd"
          }
        }
      }

      {
        "foo.bar.text" => "foobar",
        "foo.test.text" => "tralalala",
        "foo.test.text2" => "test"
      }.namespace_unflatten.should == {
        "foo" => {
          "bar" => {
            "text" => "foobar"
          },
          "test" => {
            "text" => "tralalala",
            "text2" => "test"
          }
        }
      }

      {
        "foo.bar" => "bar",
        "foo.foo" => "foo",
        "foo.foobar.bar" => "bar",
        "foo.foobar.foo" => "foo",
        "foo.barfoo.bar" => "bar",
        "foo.barfoo.foo" => "foo"
      }.namespace_unflatten.should == {
        "foo" => {
          "bar" => "bar",
          "foo" => "foo",
          "foobar" => {
            "bar" => "bar",
            "foo" => "foo"
          },
          "barfoo" => {
            "bar" => "bar",
            "foo" => "foo"
          }
        }
      }
    end

    it "should return flatten hash with namespaced keys" do
      {
        "foobar" => "a",
        "foo.bar.text" => "foobar",
        "foo.a" => [1,2,3],
        "b" => "b"
      }.namespace_unflatten.should == @hash
    end

    it "should flatten with custom separator" do
      {
        "foobar" => "a",
        "foo/bar/text" => "foobar",
        "foo/a" => [1,2,3],
        "b" => "b"
      }.namespace_unflatten("/").should == @hash
    end
  end

  describe "#nested_value" do
    it "should generated nested hash" do
      Hash.nested_value("value", ["foo", "bar", "foobar"]).should == {
        "foo" => {
          "bar" => {
            "foobar" => "value"
          }
        }
      }
    end
  end

  describe "#def recursive_symbolize_keys!" do
    it "should symbolize keys in nested hashes" do
      { 
        "foo" => {
          "bar" => {
            "foobar" => "foobar"
          }
        }
      }.recursive_symbolize_keys!.should == {
        :foo => {
          :bar => {
            :foobar => "foobar"
          }
        }
      }
    end
  end
end
