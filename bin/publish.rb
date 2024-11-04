#! /usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "fileutils"
require "optparse"

DRAFT_DIRECTORY = Pathname.new(File.expand_path("../_drafts", __dir__)).freeze
POST_DIRECTORY = Pathname.new(File.expand_path("../_posts", __dir__)).freeze

file_utils = FileUtils
verbose = false
now = Time.now

opt = OptionParser.new
opt.on("--dry-run") { file_utils = FileUtils::DryRun }
opt.on("--verbose") { verbose = true }
opt.parse!(ARGV)

draft_paths = Dir.glob(DRAFT_DIRECTORY.join("*.md")).reject do |x|
  File.basename(x).start_with?("_")
end

draft_paths.each do |draft_path|
  post_path = POST_DIRECTORY.join(now.strftime("%Y-%m-%d-#{File.basename(draft_path)}"))
  file_utils.mv(draft_path, post_path, verbose: verbose)
  puts("published: #{File.basename(post_path)}")
end
