require 'rubygems'

require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/testtask'

PKG_NAME      = 'paranoid_fu'
PKG_VERSION   = '0.4.1'
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the paranoid_fu plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the paranoid_fu plugin.'
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
  s.summary         = "paranoid_fu keeps models from actually being deleted by setting a deleted_at field. It adds without_deleted and only_deleted named_scopes"
  s.files           = FileList["{lib,test}/**/*"].to_a + %w(README MIT-LICENSE CHANGELOG RUNNING_UNIT_TESTS)
  s.files.delete      "paranoid_fu_plugin.sqlite.db"
  s.files.delete      "paranoid_fu_plugin.sqlite3.db"
  s.require_path    = 'lib'
  s.autorequire     = 'paranoid_fu'
  s.has_rdoc        = true
  s.test_files      = Dir['test/**/*_test.rb']
  s.author          = "Sergio Cambra"
  s.email           = "sergio@entrecables.com"
  s.homepage        = "http://github.com/scambra/paranoid_fu"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
