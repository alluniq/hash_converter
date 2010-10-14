require "spec_helper"

describe HashConverter do
  describe "DSL" do
    describe "maping" do
      it "should map from flat hash" do
        HashConverter.convert({ :key1 => "val1", :key2 => "val2", :key3 => "val3" }) do
          map "key1", "a"
          map "key2", "b"
          map "key3", "c"
        end.should == { :a => "val1", :b => "val2", :c => "val3" }
      end

      it "should map keys that not exists as nil value" do
        HashConverter.convert({ :key => "value", :nilkey => nil }) {
          map "key", "foo"
          map "foobar", "foobar"
          map "nilkey", "nil"
        }.should == {
          :foo => "value",
          :foobar => nil,
          :nil => nil
        }
      end

      it "should map keys given as symbol" do
        h = { :key => "value" }
        hh = { :new_key => "value" }

        HashConverter.convert(h) do
          map :key, :new_key
        end.should == hh

        HashConverter.convert(h) do
          map "key", :new_key
        end.should == hh

        HashConverter.convert(h) do
          map :key, "new_key"
        end.should == hh
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

      it "should take namespaced path name" do
        HashConverter.convert(@hash) do
          path "foo.bar" do
            map :text, :foo
          end
        end.should == { :foo => "foobar" }
      end

      it "should allow take symbol as argument" do
        HashConverter.convert(@hash) do
          path :foo do
            path :bar do
              map :text, :barfoo
            end
          end
          path :foo do
            path :test do
              map :text, :testfoo
            end
          end
        end.should == { :barfoo => "foobar", :testfoo => "text" }
      end

      it "should allow take string as argument" do
        HashConverter.convert(@hash) do
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
        end.should == { :barfoo => "foobar", :testfoo => "text" }
      end
    end

    describe "combined input keys" do
      it "should join with given white chars" do
        HashConverter.convert({ :foo => "foo", :bar => "bar" }){
          map "{foo}\s{bar}", :foobar
        }.should == {
          :foobar => "foo\sbar"
        }
      end

      it "should join namespaecd keys with given white chars" do
        HashConverter.convert({ :ns => { :foo => "foo", :bar => "bar" }}){
          map "{ns.foo}\s{ns.bar}", :foobar
        }.should == {
          :foobar => "foo\sbar"
        }
      end
    end

    describe "value conversion" do
      it "should change value passed in block" do
        h = {
          :test => {
            :valid => "test"
          }
        }

        HashConverter.convert(h) do
          path "test" do
            map "valid", "foobar" do |value|
              "value_from_block_#{value}"
            end
          end
        end.should == { :foobar => "value_from_block_test" }
      end
    end

    describe "typecasting" do
      it "should typecast to given type" do
        HashConverter.convert({ :foobar => "123" }){
          map :foobar, :foo, Integer
        }.should == {
          :foo => 123
        }
      end

      it "should invoke method given by symbol" do
        HashConverter.convert({ :foobar => "123" }){
          map :foobar, :foo, :to_i
        }.should == {
          :foo => 123
        }
      end
    end

    describe "#get" do
      before do
        @hash = { :foo => { :bar => "foobar" }, :bar => "foo"}
      end

      it "should return value from given hash" do
        HashConverter.convert(@hash) {
         @@var = get "foo.bar"
        }
        @@var.should == "foobar"
      end

      it "should return array of values" do
        HashConverter.convert(@hash) {
         @@var = get("foo.bar", "bar")
        }
        @@var.should == ["foobar", "foo"]
      end

      it "should works properly when nested into path" do
        HashConverter.convert(@hash) {
          path "foo" do
            @@var = get "bar"
          end
        }

        @@var.should == "foobar"
      end
    end

    describe "#set" do
      it "should set value for key" do
        HashConverter.convert {
          set "foo", "bar"
        }.should == {
          :foo => "bar"
        }
      end

      it "should set value for namespaced key" do
        HashConverter.convert {
          set "foo.bar", "foobar"
        }.should == {
          :foo => {
            :bar => "foobar"
          }
        }
      end

      it "should ignore path" do
        HashConverter.convert do
          path "ns" do
            set "foo.bar", "foobar"
          end
        end.should == {
          :foo => {
            :bar => "foobar"
          }
        }
      end
    end

    describe "get and set combined" do
      it "should set value from #get" do
        HashConverter.convert({ "foo" => { "bar" => "foobar" }}) {
          set "test", get("foo.bar")
        }.should == {
          :test => "foobar"
        }
      end
    end
  end

  describe "#typecast" do
    describe "casting to type" do

      it "should handle nils properly" do
        lambda {
          HashConverter.convert do
            map "foo", "foobar", Date
          end
        }.should_not raise_error
      end

      it "string" do
        HashConverter.typecast(123, String).should == "123"
      end

      it "integer" do
        HashConverter.typecast("123", Integer).should == 123
      end

      it "float" do
        HashConverter.typecast("123.45", Float).should == 123.45
      end

      it "time" do
        HashConverter.typecast("16:30", Time).should == Time.parse("16:30")
      end

      it "date" do
        HashConverter.typecast("01-02-2003", Date).should == Date.parse("01-02-2003")
      end

      it "datetime" do
        HashConverter.typecast("01-02-2003 15:30", DateTime).should == DateTime.parse("01-02-2003 15:30")
      end
    end
  end
end
