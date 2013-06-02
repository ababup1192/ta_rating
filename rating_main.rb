# -*- coding: utf-8 -*-

require "tk"
require "./model/execute_management.rb"
require "./model/file_management.rb"
require "./model/point_management.rb"
require "./model/start_setting.rb"
require "./view/start_dialog.rb"

class RatingMain
  def initialize
    MainWindow.new
  end
end

class MainWindow
  def initialize
    @start_setting = StartSetting.new
    #ウィンドウのサイズ
    root = TkRoot.new{
      title "採点ツール"
      geometry "950x480"
    }
    file_menu = TkMenu.new(root)

    file_menu.add('command',
      'label'     => "採点開始",
      'command'   => proc{StartDialog.new},
      'underline' => 0)
    file_menu.add('command',
      'label'     => "終了",
      'command'   => proc{root.destroy},
      'underline' => 0)
    menu_bar = TkMenu.new
    menu_bar.add('cascade','menu'  => file_menu,'label' => "File")

    root.menu(menu_bar)
    TkButton.new(root, 'text' => "採点開始", 'command' => proc{ StartDialog.new(self).view }).pack
    Tk.mainloop
  end
  attr_accessor :start_setting
end

RatingMain.new
