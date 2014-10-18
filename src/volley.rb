require 'fileutils'
require './src/const'

def setup_volley(project_path)
  Dir.chdir(project_path)
  puts 'Volleyをサブモジュール化します...'
  success = system('git submodule add https://android.googlesource.com/platform/frameworks/volley modules/volley')
  if !success
    puts '* Error *'
    puts 'Volleyサブモジュール化に失敗'
    exit(-1)
  end
  puts 'Volleyのサブモジュール化完了'

  # settings.gradleを編集
  File.open(SETTINGS_GRADLE, 'a') do |file|
    file.puts("include ':modules:volley'")
  end

  # app/build.gradleでモジュール読み込み
  puts 'app/build.gradleを編集します...'
  compileSdkVersion = ''
  buildToolsVersion = ''
  Dir.chdir(project_path + '/app')
  tmpfile = File.open('_' + BUILD_GRADLE, 'w')
  File.foreach(BUILD_GRADLE) do |line|
    tmpfile.puts(line.chomp)
    if /dependencies/ =~ line.chomp
      tmpfile.puts("    compile project(':modules:volley')")
    end
    if /compileSdkVersion/ =~ line.chomp
      compileSdkVersion = line.chomp
    elsif /buildToolsVersion/ =~ line.chomp
      buildToolsVersion = line.chomp
    end
  end
  File.delete(BUILD_GRADLE)
  File.rename('_' + BUILD_GRADLE, BUILD_GRADLE)
  puts 'app/build.gradle編集完了'


  # compileSdkVersionなど変更
  puts 'Volleyのbuild.gradleを編集します...'
  Dir.chdir(project_path + '/modules/volley')
  tmpfile = File.open('_' + BUILD_GRADLE, 'w')
  File.foreach(BUILD_GRADLE) do |line|
    if /compileSdkVersion/ =~ line.chomp
      tmpfile.puts(compileSdkVersion)
    elsif /buildToolsVersion/ =~ line.chomp
      tmpfile.puts(buildToolsVersion)
    else
      tmpfile.puts(line.chomp)
    end
  end
  File.delete(BUILD_GRADLE)
  File.rename('_' + BUILD_GRADLE, BUILD_GRADLE)
  puts 'Volleyのbuild.gradle編集完了'
end
