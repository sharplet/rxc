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

    it "uses xcodebuild by default" do
      @shell_command.must_match(/^xcodebuild/)
    end

    describe "custom runner" do
      let(:options) { {:runner => 'xctool'} }
      specify { @shell_command.must_match(/^xctool/) }
    end
  end

end
