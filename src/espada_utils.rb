# encoding: UTF-8

#
# This file is a part of Espada project.
#
# Copyright (C) 2013 Nguyễn Hà Dương <cmpitgATgmaildotcom>
#
# Espada is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Espada is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Espada.  If not, see <http://www.gnu.org/licenses/>.
#

require 'fileutils'

require 'gui/gui_constants'

require 'espada_string_utils'
require 'espada_datetime_utils'

def expand_path(path)
  File.expand_path path
end

def mkdir(path)
  FileUtils.mkpath path
end

def create_dir(path)
  mkdir path
end

def current_executing_dir(path)
  File.expand_path File.dirname(path)
end

def espada_path
  if defined? ESPADA_PATH then ESPADA_PATH else "" end
end

# Read file without failing, no exception is thrown

def read_file(path)
  begin
    contents = File.read path
  rescue Exception => e
    contents = ""
  end
  contents
end

def eval_text(text)
  text = text[0..-2] while text[-1] == 10 || text[-1] == 13
  text.strip!

  # Exec if the first character is `!`
  return [`#{text.but_first}`, :shell] if text.first == "!"[0]

  command_type = :ruby
  result = begin
    text.split("\u07ed").each do |line|
      # The scope of `eval` is always global
      eval(line.chomp, TOPLEVEL_BINDING) if line
    end
  rescue Exception => e
    puts e
    command_type = :shell
    `#{text}`
  end

  [result, command_type]
end

def message(text)
  puts ">> #{text}"
end

def save_file_with_text(path, text)
  File.open(path, 'w') { |file| file.write text }
  message "Saved to #{path}"
end

def save_as(path)
  buffer = current_buffer
  return nil if not buffer
  path = path || current_buffer.path
  save_file_with_text path, buffer.to_plain_text
  current_buffer.path = path
  current_buffer.saved = true
end

def save(*args)
  if args.length == 0
    save_file_with_text current_buffer.path, current_buffer.to_plain_text
  else
    save_file_with_text args[0], current_buffer.to_plain_text
  end
  current_buffer.saved = true
end

def mouse_event_to_sym(event)
  case event.button
  when Mouse[:LeftButton]
    :LeftButton
  when Mouse[:RightButton]
    :RightButton
  when Mouse[:MiddleButton]
    :MiddleButton
  end
end

def current_buffer
  if App && App.current_buffer then App.current_buffer else nil end
end

def shell_buffer
  if App && App.shell_buffer then App.shell_buffer else nil end
end
