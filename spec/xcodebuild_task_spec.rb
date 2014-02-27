require 'rxc/xcodebuild_task'
include RXC

describe XcodebuildTask do

  let(:configure)  { proc {} }
  let(:task)       { XcodebuildTask.new(&configure) }

  let(:build_task) { Rake::Task[:build] }
  let(:clean_task) { Rake::Task[:clean] }

  before do
    Rake.application = Rake::Application.new
    task.scheme = :noscheme
  end

  describe "defined tasks" do
    specify { build_task.wont_be_nil }
    specify { clean_task.wont_be_nil }
  end

  describe "build task" do
    let(:options) { {} }
    let(:capture_shell_command) do
      proc { |cmd| @shell_command = cmd }
    end
    let(:configure) do
      proc { |task| apply_options_to(task, options.merge({executor: capture_shell_command})) }
    end

    before { build_task.invoke }

    describe "defaults" do
      it "uses xcodebuild" do
        @shell_command.must_match(/^xcodebuild/)
      end

      it "executes a build action" do
        @shell_command.must_match(/(?<= )build(?=(\s|$))/)
      end
    end

    describe "custom runner" do
      let(:options) { {:runner => 'xctool'} }
      specify { @shell_command.must_match(/^xctool/) }
    end

    describe "setting the project" do
      let(:options) { {:xcodeproj => 'Foo.xcodeproj'} }

      it "sets the -project option" do
        @shell_command.must_match(/-project Foo.xcodeproj/)
      end

      describe "with no extension" do
        let(:options) { {:xcodeproj => 'Foo'} }

        it "automatically adds the .xcodeproj extension" do
          @shell_command.must_match(/-project Foo.xcodeproj/)
        end
      end
    end
  end

end
