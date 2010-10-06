require "spec_helper"

describe HashMapper do
  describe "DSL" do
    describe "maping" do
      it "should map from flat hash" do
        h = {
          :key1 => "val1",
          :key2 => "val2",
          :key3 => "val3"
        }

        p = HashMapper.parse(h) do
          map "key1", "a"
          map "key2", "b"
          map "key3", "c"
        end

        p.should == { "a" => "val1", "b" => "val2", "c" => "val3" }
      end

      it "should not map keys that not exists" do
        h = {
          :key  => "value"
        }

        HashMapper.parse(h) {
          map "key", "foo"
          map "foobar", "foobar"
        }.should == {
          "foo" => "value"
        }
      end
    end

    describe "nesting paths" do
      before do
        @hash = {
          :foo => {
            :bar => {
              :text => "foobar"
            },
            :test => {
              :text => "text"
            }
          }
        }
      end

      it "should allow take symbol as argument" do
        p = HashMapper.parse(@hash) do
          path "foo" do
            path "bar" do
              map "text", "barfoo"
            end
          end
          path "foo" do
            path "test" do
              map "text", "testfoo"
            end
          end
        end

        p.should == { "barfoo" => "foobar", "testfoo" => "text" }
      end

      it "should allow take string as argument" do
        p = HashMapper.parse(@hash) do
          path "foo" do
            path "bar" do
              map :text, :barfoo
            end
          end
          path "foo" do
            path "test" do
              map :text, :testfoo
            end
          end
        end

        p.should == { "barfoo" => "foobar", "testfoo" => "text" }
      end
    end

    describe "conditional mapping" do
      it "should map argument" do
        h = {
          :test => {
            :valid => 123
          }
        }

        p = HashMapper.parse(h) do
          path "test" do
            map "valid", "foobar" do |value|
              value < 200
            end
          end
        end

        p.should == { "foobar" => 123 }
      end

      it "should not map argument" do
        h = {
          :test => {
            :valid => 123
          }
        }

        p = HashMapper.parse(h) do
          path "test" do
            map "valid", "foobar" do |value|
              value > 200
            end
          end
        end

        p.should == {}
      end
    end
  end
end
