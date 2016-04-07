
require 'pp'

gems = []
gem = nil
versions = nil

File.readlines('list.txt').each do |line|

  line = line.strip
  next if line == ''
  next if line.match(/\A#/)

  if line.match(/\A[a-z-]+/)
    gems << [ gem, versions ] if gem
    gem = line.split(' ')[0]
    versions = []
  else
    versions << line.strip.split(' ')[0]
  end
end
gems << [ gem, versions ]

pp gems

def verify(gem, version)
  system(
    "cd out && gem fetch #{gem} -v #{version}")
  system(
    "cd out && gem unpack #{gem}-#{version}.gem")
  system(
    "cd out && gem spec #{gem}-#{version}.gem > #{gem}-#{version}.gemspec")
  system(
    "cd out && git clone -b v#{version} git@github.com:jmettraux/#{gem}.git #{gem}-#{version}-git")
  system(
    "cd out && git diff --no-index #{gem}-#{version}-git/lib #{gem}-#{version}/lib" +
    " > #{gem}-#{version}-lib.diff")
  system(
    "cd out && git diff --no-index #{gem}-#{version}-git/#{gem}.gemspec #{gem}-#{version}/#{gem}.gemspec" +
    " > #{gem}-#{version}-gemspec.diff")
end

gems.each do |gem, versions|
  versions.each { |v| verify(gem, v) }
end

