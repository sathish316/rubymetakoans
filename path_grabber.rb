class PathGrabber
  def koan_filenames
    eval(IO.read("koans/path_to_enlightenment.rb").gsub('require', 'load_koan'))
    koans
  end

  def in_ruby_version(version)
    false
  end

  def load_koan(file_name)
    koans << file_name
  end

  def koans
    @koans ||= []
  end
end
