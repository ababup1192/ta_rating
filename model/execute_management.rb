require "open3"
require "timeout"
require "thread"

class ExecuteManagement
  def initialize(file_path)
    @file_path = file_path
    @compile_result = ""
    @exec_result = ""
  end
  def generate_thread(command,file_name,c_flag)
    err_flag = false
    command = command.gsub(/\$file_name/,file_name)

    thread = Thread.new{
      Open3.popen3(command) do |stdin, stdout, stderr|
        stdout.each do |line|
          if c_flag
            @compile_result += line
          else
            @exec_result += line
          end
        end
        stderr.each do |line|
          err_flag = true
          if c_flag
            @compile_result += line
          else
            @exec_result += line
          end
        end
      end
      raise "Error" if err_flag
    }
  end
  def exec_thread(thread)
    timeout(3){
      loop do
        Thread.pass
        if !thread.alive?
          thread.join
          break
        end
      end
    }
  end
  def exec(compile_thread,exec_thread)
    begin
      exec_thread(compile_thread)
    rescue Timeout::Error
     @compile_result.insert(0,"Timeout\n")
     puts @compile_result
   rescue RuntimeError
    @compile_result.insert(0,"Compile Error\n\n")
    puts @compile_result
  rescue
    puts "command not found"
  else
    @compile_result.insert(0,"Success!\n\n")
    puts @compile_result
    exec_next(exec_thread)
  end
end
def exec_next(exec_thread)
  begin
    exec_thread(exec_thread)
  rescue Timeout::Error
   @exec_result.insert(0,"Timeout\n")
   puts @exec_result
 rescue RuntimeError
  @exec_result.insert(0,"Compile Error\n\n")
  puts @exec_result
rescue
  puts "command not found"
else
  @exec_result.insert(0,"Success!\n\n")
  puts @exec_result
end
end

attr_accessor :file_path,:compile_result,:exec_result
end

#em = ExecuteManagement.new("test")
#compile_thread = em.generate_thread("echo aaa","file_management.rb",true)
#exec_thread = em.generate_thread("echo bbb","",false)
#em.exec(compile_thread,exec_thread)

