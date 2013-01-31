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

require 'rubygems'
require 'singleton'
require './espada_settings'
require './default_settings'
require './espada_utils'
require './gui/text_edit2'

espada = {}

class EApplication
  include Singleton

  attr_accessor :app,
                :settings,
                :container,
                :main_win,
                :text_buffers

  def initialize
    @app = Qt::Application.new ARGV
    @text_buffers = []
    update_settings
    create_container
    create_main_window
    create_main_text_buffer
    set_layout
  end

  def set_layout
    @main_win.set_central_widget @container
  end

  def create_main_text_buffer
    text_edit = TextEdit.new
    text_edit.set_plain_text read_file(Settings.default_contents_path)
    text_edit.set_line_wrap_column_or_width Settings.wrap_column
    text_edit.set_line_wrap_mode Settings.wrap_mode

    @container.add text_edit
    @text_buffers << text_edit
  end

  def create_main_window
    win = MainWindow.new
    win.set_window_title "Espada Text Playground"
    win.set_font Settings.normal_text_font
    win.resize Settings.size[:width], Settings.size[:height]
    win.move Settings.position[:x], Settings.position[:y]
    win.show

    @main_win = win
  end

  def create_container
    # The container carries a layout of the main window
    @container = MainContainer.new
  end

  def exec
    @app.exec
  end

  def update_settings
    # Get runtime settings
    EspadaSettings[:double_click_timeout] =
      EspadaSettings[:double_click_timeout] || $qApp.doubleClickInterval

    Settings.update EspadaSettings
    @settings = Settings

    puts "=> Settings: "
    Settings.print
  end
end


app = EApplication.instance
app.exec