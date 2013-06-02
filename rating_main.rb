# -*- coding: utf-8 -*-

require "tk"
require "./model/execute_management.rb"
require "./model/file_management.rb"
require "./model/point_management.rb"

class RatingMain
  def initialize
  end
end

RatingMain.new

#ウィンドウのサイズ
root = TkRoot.new{
  title "Rating Tool"
  geometry "950x480"
}
file_menu = TkMenu.new(root)
menu_click = Proc.new {
  exit
}
file_menu.add('command',
  'label'     => "採点開始",
  'command'   => menu_click,
  'underline' => 0)
file_menu.add('command',
  'label'     => "終了",
  'command'   => menu_click,
  'underline' => 0)
menu_bar = TkMenu.new
menu_bar.add('cascade',
 'menu'  => file_menu,
 'label' => "File")

root.menu(menu_bar)

Tk.mainloop


