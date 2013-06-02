# -*- coding: utf-8 -*-

require "tkextlib/tkimg"

class StartDialog
  def initialize(context)
    @context = context
    @start_setting = context.start_setting
    @mailing_path = ""
  end
  def view
    window = TkToplevel.new{
      title "初期設定"
      geometry "600x300"
    }
    TkLabel.new(window, 'text' => "メーリングリスト").pack
    mail_image = TkPhotoImage.new('file' => "./data/mail_list.jpg")
    TkButton.new(window, 'image' => mail_image, 'command' => mailing_list).pack
    @mail_file_label = TkLabel.new(window, 'text' => "[ファイル名]").pack
    TkLabel.new(window, 'text' => "採点対象ディレクトリ").pack
    folder_image = TkPhotoImage.new('file' => "./data/folder.jpg")
    TkButton.new(window, 'image' => folder_image, 'command' => rating_directory ).pack
    @rating_directory_label = TkLabel.new(window, 'text' => "[ディレクトリ名]").pack
    TkLabel.new(window, 'text' => '採点ファイル名').pack
    delimiter_text = TkEntry.new(window).pack
    TkButton.new(window, 'text' => "キャンセル", 'command' => proc{ window.destroy;p mailing_list }).pack
  end
  def mailing_list
    proc{
      path = Tk.getOpenFile
      if !path.empty?
        @mailing_path = File::dirname(path)
        file = path.split("/")[-1]
        @mail_file_label.text =  "[#{file}]"
      end
    }
  end
  def rating_directory
    proc{
      path = Tk.chooseDirectory('initialdir' => @mailing_path)
      if !path.empty?
        @rating_directory_label.text =  "[#{path}]"
      end
    }
  end

  attr_accessor :context,:start_setting,:mail_file_label,:rating_directory_label
end
