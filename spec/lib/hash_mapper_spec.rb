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

        p = HashMapper.convert(h) do
          map "key1", "a"
          map "key2", "b"
          map "key3", "c"
        end

        p.should == { :a => "val1", :b => "val2", :c => "val3" }
      end

      it "should map keys that not exists as nil value" do
        HashMapper.convert({ :key => "value", :nilkey => nil }) {
          map "key", "foo"
          map "foobar", "foobar"
          map "nilkey", "nil"
        }.should == {
          :foo => "value",
          :foobar => nil,
          :nil => nil
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
        p = HashMapper.convert(@hash) do
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

        p.should == { :barfoo => "foobar", :testfoo => "text" }
      end

      it "should allow take string as argument" do
        p = HashMapper.convert(@hash) do
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

        p.should == { :barfoo => "foobar", :testfoo => "text" }
      end
    end

    describe "conditional mapping" do
      it "should map argument" do
        h = {
          :test => {
            :valid => 123
          }
        }

        p = HashMapper.convert(h) do
          path "test" do
            map "valid", "foobar" do |value|
              value < 200
            end
          end
        end

        p.should == { :foobar => 123 }
      end

      it "should not map argument" do
        h = {
          :test => {
            :valid => 123
          }
        }

        p = HashMapper.convert(h) do
          path "test" do
            map "valid", "foobar" do |value|
              value > 200
            end
          end
        end

        p.should == {}
      end
    end

    describe "typecasting" do
      it "should typecast to given type" do
        HashMapper.convert({ :foobar => "123" }){
          map :foobar, :foo, Integer
        }.should == {
          :foo => 123
        }
      end

      it "should invoke method given by symbol" do
        HashMapper.convert({ :foobar => "123" }){
          map :foobar, :foo, :to_i
        }.should == {
          :foo => 123
        }
      end
    end

    describe "#get" do
      before do
        @hash = { :foo => { :bar => "foobar" }}
      end

      it "should return value from given hash" do
        HashMapper.convert(@hash) {
         @@var = get "foo.bar"
        }
        @@var.should == "foobar"
      end

      it "should works properly when nested into path" do
        HashMapper.convert(@hash) {
          path "foo" do
            @@var = get "bar"
          end
        }

        @@var.should == "foobar"
      end
    end

    describe "#set" do
      it "should set value for key" do
        HashMapper.convert {
          set "foo", "bar"
        }.should == {
          :foo => "bar"
        }
      end

      it "should set value for namespaced key" do
        HashMapper.convert {
          set "foo.bar", "foobar"
        }.should == {
          :foo => {
            :bar => "foobar"
          }
        }
      end

      it "should set value for namespaced key inside path" do
        HashMapper.convert do
          path "ns" do
            set "foo.bar", "foobar"
          end
        end.should == {
          :ns => {
            :foo => {
              :bar => "foobar"
            }
          }
        }
      end
    end

    describe "get and set combined" do
      it "should set value from #get" do
        HashMapper.convert({ "foo" => { "bar" => "foobar" }}) {
          set "test", get("foo.bar")
        }.should == {
          :test => "foobar"
        }
      end
    end
  end

  describe "#typecast" do
    describe "casting to type" do
      it "string" do
        HashMapper.typecast(123, String).should == "123"
      end

      it "integer" do
        HashMapper.typecast("123", Integer).should == 123
      end

      it "float" do
        HashMapper.typecast("123.45", Float).should == 123.45
      end

      it "time" do
        HashMapper.typecast("16:30", Time).should == Time.parse("16:30")
      end

      it "date" do
        HashMapper.typecast("01-02-2003", Date).should == Date.parse("01-02-2003")
      end

      it "datetime" do
        HashMapper.typecast("01-02-2003 15:30", DateTime).should == DateTime.parse("01-02-2003 15:30")
      end
    end
  end
end
