require 'rubygems'
require 'sinatra'
require 'haml'
require 'timeout'
require 'pp'
require File.expand_path(File.dirname(__FILE__) + '/string')
require File.expand_path(File.dirname(__FILE__) + '/path_grabber')
KOAN_FILENAMES     = PathGrabber.new.koan_filenames
EDGECASE_CODE      = IO.read("koans/edgecase.rb").remove_require_lines.split(/END\s?\{/).first
EDGECASE_OVERRIDES = IO.read("overrides.rb")

class FakeFile
  CONTENT = "this\nis\na\ntest"

  def self.gimme(x=nil, &block)
    ff = FakeFile.new
    return block.call(ff) if block
    ff
  end

  def initialize
    @lines = CONTENT.split("\n")
  end

  def gets
    @current_line_index ||= 0
    line = @lines[@current_line_index]
    @current_line_index += 1
    "#{line}\n" if line
  end

  def close;end

  def self.exist?(name)
    raise TypeError unless name.respond_to? :to_str
    name.to_str == 'example_file.txt'
  end

  def self.open(*x)
    CONTENT
  end
end

def input
  (params[:input] ||= [])
end
def current_koan_name
  return '' if @end
  claimed = params[:koan].to_s
  if KOAN_FILENAMES.include? claimed
    claimed
  else
    KOAN_FILENAMES.first
  end
end
def edgecaser_images
  require 'net/http'
  require 'uri'

  url = URI.parse('http://edgecase.com/')
  res = Net::HTTP.start(url.host, url.port) {|http| http.get('/about') }
  res.body.scan(/\/images\/team\/\w*?\.jpg/)
end
def next_koan_name
  KOAN_FILENAMES[current_koan_count]
end
def current_koan_count
  KOAN_FILENAMES.index(current_koan_name)+1
end
def current_koan
  IO.read("koans/#{current_koan_name}.rb").remove_require_lines.gsub("assert false", "assert __")
end

def runnable_code(session={})
  unique_id = rand(10000)
  code = current_koan.swap_user_values(input,session).gsub(" ::About", " About").gsub("File", "FakeFile").gsub(" open(", "FakeFile.gimme(")
  index = code.rindex(/class About\w*? \< EdgeCase::Koan/)
  global_code = code[0...index]
  reset_global_classes = global_code.scan(/class (\w+)/).collect{|c| "Object.send(:remove_const, :#{c}) if defined? #{c};" }.join
  global_code = "#{reset_global_classes}#{global_code}"
  code = code[index..-1]
  require 'pp'
  pp global_code
  <<-RUNNABLE_CODE
    require 'timeout'
    require 'test/unit'
    require 'test/unit/assertions'

    RESULTS = {:failures => {}, :pass_count => 0}
    $SAFE = 3
    Timeout.timeout(2) {
      #{global_code}
      module KoanArena
        module UniqueRun#{unique_id}
          #{::EDGECASE_CODE}
          #{::EDGECASE_OVERRIDES}
          #{code}
          path = EdgeCase::ThePath.new
          path.online_walk
          RESULTS[:pass_count] = path.sensei.pass_count
          RESULTS[:failures] = path.sensei.failures
        end
      end
      KoanArena.send(:remove_const, :UniqueRun#{unique_id})
    }
    RESULTS
  RUNNABLE_CODE
end

enable :sessions

get '/' do
  return haml '%pre= runnable_code' if params[:dump]
  count = 0
  begin
    results = {}
    results = Thread.new { eval runnable_code(session), TOPLEVEL_BINDING }.value
  rescue SecurityError => se
    @error = "What do you think you're doing, Dave?"
  rescue TimeoutError => te
    @error = 'Do you have an infinite loop?'
  rescue StandardError => e
    @error = ['standarderror', e.message, e.backtrace, e.inspect].flatten.join('<br/>')
  rescue Exception => e
    @error = ['syntax error', e.message].flatten.join('<br/>')
  rescue Error => e
    @error = ['error', e.message].flatten.join('<br/>')
  end
  @pass_count = results[:pass_count]
  @failures   = results[:failures]

  if @error
    return "#{@error.gsub(/\n/, "<br/>")} <br/><br/> Click your browser back button to return."
  elsif (@failures && @failures.count > 0) || params["input"].nil?
    @inputs = current_koan.swap_input_fields(input, @pass_count, @failures, session)
    return haml :koans
  else
    if KOAN_FILENAMES.last == current_koan_name
      @end = true
      return haml :end
    else
      return haml :next_koan
    end
  end
end
