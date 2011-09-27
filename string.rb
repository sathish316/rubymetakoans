require 'cgi'
class String
  TEXT_AREA_MATCHER = /_[\w_]+?\.rb_\n([\w\s\#\:\.]+?\n)\s*_[\w_]+?\.rb_/
  FILL_ME_IN = /_(?:textarea)?(?:n)?__*/
  def remove_require_lines
    self.split("\n").reject{|line| line.start_with? 'require' }.join("\n")
  end

  def preify
    self.gsub('<','&lt;').gsub('>','&gt;').gsub("\n","<br/>").gsub("\s","&nbsp;")
  end

  def swap_user_values(input_values, session)
    p input_values
    count = 0
    method_area = false
    method_name = nil
    method_indentation = 0
    in_ruby_v = nil
    in_ruby_indentation = 0
    in_correct_ruby_v = true
    default_textarea_contents = ''
    session_code_match_name = ''

    self.gsub(TEXT_AREA_MATCHER) do |match|
      session_code_match_name = CGI.unescape((match.match(/_[\w_]+?\.rb_/)||[])[0])
      default_textarea_contents = $1
      "_textarea_"
    end.split("\n").map do |line|
      if match = line.match(/^(\s{2}*)in_ruby_version.*[\"\'](.*)[\"\']/)
        in_ruby_indentation = match[1].size
        in_ruby_v = match[2]
        in_correct_ruby_v = in_ruby_v.include? "1.8"
        next
      elsif in_ruby_v
        if line.match(/^\s{#{in_ruby_indentation}}end/)
          in_ruby_v = nil
          in_ruby_indentation = 0
          in_correct_ruby_v = true
          next
        else
          line = line[in_ruby_indentation..-1].to_s
        end
      end
      next unless in_correct_ruby_v
      if match = line.match(/^(\s{2}*)def test_/)
        method_area = true
        method_indentation = match[1].size
        method_name = (methodx = line.match(/test_\S*/)) && methodx[0]
      elsif line.start_with?(/\s{#{method_indentation}}end/) && method_area
        method_area = false
        method_name = nil
      end

      if line.strip.start_with? "#"
        line
      else
        line.gsub('__send__', '**send**').gsub(FILL_ME_IN) do |match|
          if %w{test_assert_truth test_assert_with_message}.include?(method_name) &&
              (input_values[count].nil? || input_values[count].empty?)
            input_values[count] = 'false'
          end

          x = if input_values[count].to_s == ""
            if match.include?('textarea')
              if previously_entered = session[session_code_match_name.to_sym]
                previously_entered
              else
                default_textarea_contents
              end
            elsif match.include? 'n'
              999999
            else
              match
            end
          else
            v = "#{input_values[count]}"
            puts v
            v
          end
          session[session_code_match_name.to_sym] = x unless session_code_match_name.empty?
          count = count + 1
          x
        end.gsub('**send**', '__send__')
      end
    end.compact.join("\n")
  end

  def swap_input_fields(input_values, passes, failures, session={})
    count        = 0
    method_count = 0
    method_area  = false
    method_name = nil
    method_indentation = 0
    in_ruby_v = nil
    in_ruby_indentation = 0
    in_correct_ruby_v = true
    default_textarea_contents = ''
    session_code_match_name = ''

    self.gsub(TEXT_AREA_MATCHER) do |match|
      default_textarea_contents = $1
      session_code_match_name = (match.match(/_[\w_]+?\.rb_/)||[])[0]
      "_textarea_"
    end.gsub("\s", "&nbsp;").gsub("<","&lt;").split("\n").map do |line|
      true_line = line.gsub('&nbsp;',' ')
      if match = true_line.match(/^(\s{2}*)in_ruby_version.*[\"\'](.*)[\"\']/)
        in_ruby_indentation = match[1].size
        in_ruby_v = match[2]
        in_correct_ruby_v = in_ruby_v.include? "1.8"
        next
      elsif in_ruby_v
        if true_line.match(/^\s{#{in_ruby_indentation}}end/)
          in_ruby_v = nil
          in_ruby_indentation = 0
          in_correct_ruby_v = true
          next
        else
          line = line[(in_ruby_indentation*('&nbsp;'.size))..-1].to_s
          true_line = line.gsub('&nbsp;',' ')
        end
      end
      next unless in_correct_ruby_v
      if match = true_line.match(/^(\s{2}*)def test_/)
        method_area = true
        method_indentation = match[1].size
        method_count = method_count + 1
        method_name = (methodx = true_line.match(/test_\S*/)) && methodx[0]
        failure = failures[method_name.to_sym]
        "#{fail_message(failure)}
        <div nowrap='nowrap' class='#{failure ? 'failed' : 'passed'}'>
        #{line}"
      elsif method_area && true_line.match(/^\s{#{method_indentation}}end/)
        method_area = false
        "#{line}</div>"
      elsif line.gsub("&nbsp;","").start_with?("#")
        line
      else
        line.gsub(/__send__/, '**send**').gsub(FILL_ME_IN) do |match|
          if %w{test_assert_truth test_assert_with_message}.include?(method_name) &&
              (input_values[count].nil? || input_values[count].empty?)
            x = 'false'
          else
            x = input_values[count].to_s
          end

          count = count + 1
          if match.include? 'textarea'
            val = if x.to_s.empty?
              session[session_code_match_name.to_sym] || default_textarea_contents
            else
              x
            end
            "<textarea class='koanInput' name='input[]' cols='80' rows='10'>#{val.gsub("'", "&apos;").gsub(/\r?\n/, "\r")}</textarea>"
          else
            x = '999999' if(x.empty? && match.include?('n'))
            "<input class='koanInput' type='text' name='input[]' value='#{x.gsub("'", "&apos;")}\' />"
          end
        end.gsub('**send**', '__send__')
      end
    end.compact.join('<br/>')
  end

  def fail_message(failure)
    return nil if failure.nil?
    failure.message.gsub!(/KoanArena::UniqueRun[\d]+::/, '')
    if failure.message.include? "FILL ME IN"
      "  Please meditate on the following.".preify
    elsif failure.message.include? "undefined local"
      failure.message.split("for #<").first.preify
    else
      "  The answers which you seek:\n  #{failure.message.gsub("\n"," ")}".preify
    end
  end
end
