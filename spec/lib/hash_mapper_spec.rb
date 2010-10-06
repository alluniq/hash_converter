require "spec_helper"

describe HashMapper do
  describe "DSL" do
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
  end
end
