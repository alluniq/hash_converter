require "spec_helper"

describe HashMapper do
  describe "DSL" do
    it "should allow to nest paths" do
      h = {
        :foo => {
          :bar => {
            :text => "foobar"
          },
          :test => {
            :text => "text"
          }
        }
      }

      p = HashMapper.parse(h) do
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
end
