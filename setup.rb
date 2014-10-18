require './src/espresso'
require './src/volley'
require './src/yes_or_no'

ANDROID_STUDIO_ROOT = Dir.home + '/AndroidStudioProjects/'

project_name = ARGV[0]
if !project_name
  puts '* Error *'
  puts '引数にAndroidProject名を指定してください'
  exit(-1)
end

project_path = ANDROID_STUDIO_ROOT + project_name
if !File.exist?(project_path)
  puts '* Error *'
  puts 'プロジェクトが存在しません'
  exit(-1)
end

use_espresso = yes_or_no('Using espresso？')
use_volley = yes_or_no('Using volley?')


# Espresso (とmockito) のセットアップ
setup_espresso(project_path) if use_espresso

# Volley のセットアップ
setup_volley(project_path) if use_volley

puts 'すべての準備が完了しました！！'
