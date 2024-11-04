#! /usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "fileutils"
require "optparse"

DRAFT_DIRECTORY = Pathname.new(File.expand_path("../_drafts", __dir__)).freeze

file_utils = FileUtils
verbose = false
dry_run = false
title = "no title"
now = Time.now

opt = OptionParser.new
opt.on("--dry-run") do
  dry_run = true
  file_utils = FileUtils::DryRun
end
opt.on("--verbose") { verbose = true }
opt.on("--title TITLE") { |v| title = v }
opt.parse!(ARGV)

template_path = DRAFT_DIRECTORY.join("_template.md")

basename = ARGV.shift || title.split(/\s+/).join("-")
draft_path = DRAFT_DIRECTORY.join("#{basename}.md")
content = File.read(template_path)
  .gsub(/^title:.*$/, "title: #{title}")
  .gsub(/last_modified_at:.*/, "last_modified_at: #{now.strftime("%Y-%m-%dT%H:%M:%S%z")}")
if !dry_run
  File.open(draft_path, "w") do |f|
    f.write(content)
  end
end
