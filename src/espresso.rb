require 'fileutils'
require './src/const'

TEST_LIBS = 'espresso_mockito_libs'
TESTRUNNER = 'com.google.android.apps.common.testing.testrunner.GoogleInstrumentationTestRunner'

def setup_espresso(project_path)
  jar_arr = []
  Dir.chdir(TEST_LIBS)
  puts "jarファイルを#{project_path}/app/libsにコピー"
  system("mkdir #{project_path}/app/libs") unless File.exist?("#{project_path}/app/libs")
  Dir.glob(JAR_PATTERN) do |f|
    FileUtils.cp(f, project_path + '/app/libs')
    jar_arr.push(f)
  end

  # ------------------------------------------------------
  # build.gradle編集
  Dir.chdir(project_path + '/app')
  if !File.exist?(BUILD_GRADLE)
    puts '* Error *'
    puts 'build.gradleが存在しません'
    exit(-1)
  end

  puts 'build.gradleに書き込み中...'
  tmpfile = File.open('_' + BUILD_GRADLE, 'w')

  File.foreach(BUILD_GRADLE) do |line|
    tmpfile.puts(line.chomp)
    if /defaultConfig/ =~ line.chomp
      tmpfile.puts('        testInstrumentationRunner "' + TESTRUNNER + '"')
    else
      if /dependencies/ =~ line.chomp
        jar_arr.each do |jar|
          tmpfile.puts("    androidTestCompile files('libs/#{jar}')")
        end
      end
    end
  end
  tmpfile.close

  File.delete(BUILD_GRADLE)
  File.rename('_' + BUILD_GRADLE, BUILD_GRADLE)

  puts 'build.gradleに書き込み完了'


  # ------------------------------------------------------
  # AndroidManifest.xml編集
  Dir.chdir('src/main')
  if !File.exist?(MANIFEST)
    puts '* Error *'
    puts MANIFEST + 'が存在しません'
    exit(-1)
  end

  puts(MANIFEST + 'に書き込み中...')
  tmpfile = File.open('_' + MANIFEST, 'w')
  package = 'com.example.projectname'

  File.foreach(MANIFEST) do |line|
    if /package/ =~ line.chomp
      package = line.chomp.match(%r{package="(.+?)"})[1]
    end
    if /<\/application>/ =~ line.chomp
      tmpfile.puts('        <uses-library android:name="android.test.runner" />')
      tmpfile.puts(line.chomp)
      tmpfile.puts('    <instrumentation')
      tmpfile.puts('        android:name="' + TESTRUNNER + '"')
      tmpfile.puts('        android:targetPackage="' + package + '" />')
    else
      tmpfile.puts(line.chomp)
    end
  end
  tmpfile.close

  File.delete(MANIFEST)
  File.rename('_' + MANIFEST, MANIFEST)
  puts(MANIFEST + 'に書き込み完了')

  puts 'Espresso(with mockito)の準備ができました！'

end



