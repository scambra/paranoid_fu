require 'rubygems'

require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/testtask'

PKG_NAME      = 'acts_as_paranoid'
PKG_VERSION   = '0.4.0'
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the acts_as_paranoid plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the acts_as_paranoid plugin.'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'html'
  rdoc.title    = "#{PKG_NAME} -- protect your ActiveRecord objects from accidental deletion"
  rdoc.options << '--line-numbers --inline-source --accessor cattr_accessor=object'
  rdoc.template = "#{ENV['template']}.rb" if ENV['template']
  rdoc.rdoc_files.include('README', 'CHANGELOG', 'RUNNING_UNIT_TESTS')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec = Gem::Specification.new do |s|
  s.name            = PKG_NAME
  s.version         = PKG_VERSION
  s.platform        = Gem::Platform::RUBY
  s.summary         = "acts_as_paranoid keeps models from actually being deleted by setting a deleted_at field."
  s.files           = FileList["{lib,test}/**/*"].to_a + %w(README MIT-LICENSE CHANGELOG RUNNING_UNIT_TESTS)
  s.files.delete      "acts_as_paranoid_plugin.sqlite.db"
  s.files.delete      "acts_as_paranoid_plugin.sqlite3.db"
  s.require_path    = 'lib'
  s.autorequire     = 'acts_as_paranoid'
  s.has_rdoc        = true
  s.test_files      = Dir['test/**/*_test.rb']
  s.author          = "Sergio Cambra"
  s.email           = "sergio@entrecables.com"
  s.homepage        = "http://github.com/scambra/acts_as_paranoid"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
