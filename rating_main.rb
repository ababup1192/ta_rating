# -*- coding: utf-8 -*-

require "tk"
require "tkextlib/tkimg"

require "./model/execute_management.rb"
require "./model/file_management.rb"
require "./model/point_management.rb"
require "./model/setting.rb"
require "./view/setting_dialog.rb"
require "./view/input_dialog.rb"

class MainWindow
  def initialize
    @setting = Setting.new
    @mailing_list = []
    @file = nil
    @floppy_image = TkPhotoImage.new('file' => "./data/floppy.jpg")
    @check_image = TkPhotoImage.new('file' => "./data/check.jpg")
    @input_image = TkPhotoImage.new('file' => "./data/input.jpg")
    @exit_image = TkPhotoImage.new('file' => "./data/exit.jpg")
    view
  end
  def view
    root = TkRoot.new{
      title "採点ツール"
      geometry "1000x550"
    }

    file_menu = TkMenu.new(root)
    file_menu.add('command',
      'label'     => "採点開始",
      'command'   => proc{SettingDialog.new(self).view},
      'underline' => 0)
    file_menu.add('command',
      'label'     => "終了",
      'command'   => proc{root.destroy},
      'underline' => 0)
    menu_bar = TkMenu.new
    menu_bar.add('cascade','menu'  => file_menu,'label' => "File")
    root.menu(menu_bar)

    button_frame = TkFrame.new(root).pack
    TkButton.new(button_frame, 'image' => @floppy_image,'command' =>
     proc{ @file.write_result(@mailing_list) if !@file.nil? }).pack('padx' => 10, 'pady' => 10,'side' => 'left')
    TkButton.new(button_frame, 'image' => @check_image,'command' => proc{ SettingDialog.new(self).view }).
    pack('padx' => 10 ,'pady' => 10,'side' => 'left')
    TkButton.new(button_frame, 'image' => @input_image,'command' =>
     proc{ InputDialog.new(self).view }).pack('padx' => 10, 'pady' => 10,'side' => 'left')
    TkButton.new(button_frame, 'image' => @exit_image,'command' => proc{ root.destroy }).
    pack('padx' => 10, 'pady' => 10,'side' => 'left')
    label_frame = TkFrame.new(root).pack('fill' => 'x', 'pady' => 10)
    TkLabel.new(label_frame, 'text' => "学籍番号/成績").pack('side' => 'left', 'padx' => 100)
    TkLabel.new(label_frame, 'text' => "実行結果").pack('side' => 'left', 'padx' => 100)
    TkLabel.new(label_frame, 'text' => "ソースコード").pack('side' => 'left', 'padx' => 160)
    list_frame = TkFrame.new(root).pack('fill' => 'x' , 'padx' => 40)
    @list = TkListbox.new(list_frame,'width' => 20, 'height' => 20).pack('side' => 'left')
    TkScrollbar.new(list_frame)
    @exec_text = TkText.new(list_frame,'width' => 35,'height' => 22,'borderwidth' => 1,
      'font' => TkFont.new('Inconsolata 12')).pack('side' => "left",  'padx'=> "50")
    @source_text = TkText.new(list_frame,'width' => 35,'height' => 22,'borderwidth' => 1,
      'font' => TkFont.new('Inconsolata 12')).pack('side' => "left",  'padx' => "30")
    @list.bind('ButtonRelease-1', proc{list_click})
    @list.bind('KeyRelease',proc{list_click})
    @list.bind('Return', proc{@score.focus})
    rating_frame = TkFrame.new(root).pack('fill' => 'x', 'padx' => 20)
    @score_label = TkLabel.new(rating_frame, 'text' => "[学籍番号]").pack('side' => "left" ,'padx' => 10,'pady' => 20)
    @score = TkEntry.new(rating_frame,'width' => 3,'state' => "disabled").pack('side' => "left",'padx' => 10,'pady' => 20)
    @score.bind('Return',proc{
      begin
        @mailing_list = @point.set_point(@score_label.text,@score.value)
        list_insert
        @list.selection_set(@list_index)
        @list.focus
        @list.activate(@list_index)
      rescue
      end
      })
    Tk.mainloop
  end
  def list_insert
    @list.clear
    @mailing_list.each do |key,value|
      @list.insert 'end',"#{key} => #{value}"
    end
  end
  def list_click
    if @list.size != 0
      @list_index = @list.curselection
      list_value = @list.get(@list.curselection)
      key = list_value.split(" => ")[0]
      source_file = "#{@file.rating_dir}/#{key}.#{@file.file_extension}"
      open_source(source_file)
      exec_source(source_file,"#{@file.rating_dir}/")
      @score_label.text = list_value.split(" => ")[0]
      @score.value = list_value.split(" => ")[1]
    end
  end
  def open_source(file_path)
    @source_text.clear
    begin
      timeout(0.5){
        File::open(file_path) {|f|
          f.each {|line| @source_text.insert('end',line)}
        }
      }
    rescue Timeout::Error
      @source_text.insert('end',"ファイルサイズが大きすぎるため開くことが出来ません。")
    rescue
      @source_text.insert('end',"#{file_path}は、存在しません。")
    end
  end
  def exec_source(file_path,directory_path)
    @em = nil if !@em.nil?
    @em = ExecuteManagement.new(file_path,directory_path)
    @em.exec(self,@setting.compile_command,@setting.exec_command,@setting.test_data)
  end
  def rating_setting
    @file = FileManagement.new(@setting.rating_directory,@setting.file_extension,@setting.delimiter,@setting.result)
    arr = @file.get_mailing_list(@setting.mailing_list_path)
    @score.state = "normal" if !arr.empty?
    @point = PointManagement.new(arr)
    hash = @file.read_result
    if !hash.empty?
      @mailing_list = hash
      @point.point_hash = hash
      @setting.delimiter = @file.delimiter
      list_insert
    else
      @mailing_list = @point.reset_points
      list_insert
    end
  end
  attr_accessor :setting,:mailing_list,:exec_text
end

MainWindow.new
