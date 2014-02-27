require 'rxc/project_info'
include RXC

describe ProjectInfo do

  describe "::format_xcodeproj" do
    it "returns a valid xcodeproj without changing it" do
      ProjectInfo.format_xcodeproj('Foo.xcodeproj').must_equal('Foo.xcodeproj')
    end

    it "appends a .xcodeproj extension if necessary" do
      ProjectInfo.format_xcodeproj('Foo').must_equal('Foo.xcodeproj')
    end

    it "returns nil if the name is nil" do
      ProjectInfo.format_xcodeproj(nil).must_be_nil
    end
  end

end
