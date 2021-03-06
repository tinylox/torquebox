require 'torquespec'
require 'fileutils'
require 'rbconfig'
require 'torquebox-rake-support'

$: << File.dirname( __FILE__ )

TorqueSpec.local {
  require 'spec_helper_integ'
}

TorqueSpec.configure do |config|
  config.jboss_home = File.expand_path( File.join( File.dirname( __FILE__ ), '..', 'target', 'integ-dist', 'jboss' ) )
  config.max_heap = java.lang::System.getProperty( 'max.heap' )
  config.lazy = java.lang::System.getProperty( 'jboss.lazy' ) == "true"
  config.jvm_args += " -Dgem.path=default"
  #config.jvm_args += " -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=y"
  config.knob_root = File.expand_path( File.join( File.dirname( __FILE__ ), '..', 'target', 'knobs' ) )
  config.spec_dir = File.dirname( __FILE__ )
end
FileUtils.mkdir_p(TorqueSpec.knob_root) unless File.exist?(TorqueSpec.knob_root)

MUTABLE_APP_BASE_PATH  = File.join( File.dirname( __FILE__ ), '..', 'target', 'apps' )
TESTING_ON_WINDOWS = ( java.lang::System.getProperty( "os.name" ) =~ /windows/i )

def mutable_app(path)
  full_path = File.join( MUTABLE_APP_BASE_PATH, path )
  dest_path = File.dirname( full_path )
  FileUtils.rm_rf( full_path )
  FileUtils.mkdir_p( dest_path )
  FileUtils.cp_r( File.join( File.dirname( __FILE__ ), '..', 'apps', path ), dest_path )
end

def jruby_binary
  bin = File.expand_path( File.join( File.dirname( __FILE__ ), '..', 'target', 'integ-dist', 'jruby', 'bin', 'jruby' ) )
  bin << ".exe" if TESTING_ON_WINDOWS
  bin
end

def integ_jruby_launcher
  File.expand_path( File.join( File.dirname( __FILE__ ), 'integ_jruby_launcher.rb' ) )
end

def integ_jruby(command)
  `#{jruby_binary} #{integ_jruby_launcher} "#{command}"`
end

def normalize_path(path)
    path = path.slice(0..0).downcase + path.slice(1..-1) if TESTING_ON_WINDOWS
    File.expand_path(path.strip)
end

def assert_paths_are_equal(actual, expected) 
  normalize_path(actual).should eql(normalize_path(expected))
end

# Because DRb requires ObjectSpace and 1.9 disables it
require 'jruby'
JRuby.objectspace = true
