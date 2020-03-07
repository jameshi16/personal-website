require 'fileutils'
require 'pathname'
require 'time'
require './update_dates'

include RSpec

describe "running script" do
  before(:all) do
    FileUtils.cp_r("./fixtures/input", "./fixtures/.test") # copy fixtures
  end

  test_dir = Pathname.new "./fixtures/.test/"
  expected_dir = Pathname.new "./fixtures/expected/"

  it "doesn't have arguments" do
    expect(command(nil, [])).to eq(false)
  end

  it "has more than one argument" do
    expect(command(nil, ["hello", "world"])).to eq(false)
  end

  it "works normally" do
    filename = Pathname.new "2020-02-13-test-blog-post.md"
    time = Time.parse "2021-12-25 01:00:00 +0800"
    expected_filename = Pathname.new "2021-12-25-test-blog-post.md" 

    expect(command(time, [(test_dir + filename).to_s])).to eq(true)
    expect(FileUtils.compare_file(test_dir + expected_filename, expected_dir + expected_filename)).to eq(true)
  end

  after(:all) do
    FileUtils.rm_rf("./fixtures/.test") # delete fixtures
  end
end

