# 必要に応じて変更する。
KEY_SIZES = [1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.75, 6.25] # 使えるキーキャップのサイズのリスト。
TARGET_WIDTH = 10.75 # 横幅の指定。
MAX_KEYS = 10  # 使うキーキャップの最大数。

# 必要に応じて変更する2。使えるキーキャップに制約があるならここで設定変更。
def valid_combination?(combo)
  # たとえば 1.25 U のキーキャップが 6 個までしか使えない、という制約はこう書く↓
  return false if combo.count(1.25) > 6
  return false if combo.count(1.5) > 1
  return false if combo.count(1.75) > 0 # 1.75 U のキーキャップは使わない
  return false if combo.count(2.0) > 1
  return false if combo.count(2.25) > 2
  return false if combo.count(2.75) > 1
  return false if combo.count(6.25) > 1

  combo.sum.round(2) == TARGET_WIDTH
end

def get_max_count_for_size(size)
  case size
  when 1.0
    MAX_KEYS  # 1.0 には特別な制約はない
  when 1.25
    6
  when 1.5
    1
  when 1.75
    0  # 1.75 U のキーキャップは使わない
  when 2.0
    1
  when 2.25
    2
  when 2.75
    1
  when 6.25
    1
  else
    0  # 定義されていないサイズは使わない
  end
end

def backtrack(current_combo, current_sum, results)
  if current_sum.round(2) == TARGET_WIDTH
    results << current_combo.sort
    return
  end

  return if current_sum > TARGET_WIDTH || current_combo.length >= MAX_KEYS

  KEY_SIZES.each do |size|
    max_count = get_max_count_for_size(size)
    current_count = current_combo.count(size)

    # 制約に違反する場合はスキップ
    next if current_count >= max_count

    # 新しい組み合わせを試す
    new_combo = current_combo + [size]
    new_sum = current_sum + size

    # 合計が目標値を超える場合はスキップ
    next if new_sum > TARGET_WIDTH

    backtrack(new_combo, new_sum, results)
  end
end

def generate_combinations
  results = []
  backtrack([], 0.0, results)
  results.uniq
end

combinations = generate_combinations.sort

combinations.each_with_index do |combo, i|
  key_labels = []
  size_counts = Hash.new(0)

  # キーキャップのサイズに応じてラベルを指定している。
  combo.each do |size|
    case size
    when 1.0
      size_counts[1.0] += 1
      if size_counts[1.0] % 3 == 1
        key_labels << "Q"
      elsif size_counts[1.0] % 3 == 2
        key_labels << "A"
      else
        key_labels << "Z"
      end
    when 1.25
      key_labels << "Mod \n 1.25U"
    when 1.5
      size_counts[1.5] += 1
      if size_counts[1.5] == 1
        key_labels << "Tab \n 1.5U"
      else
        key_labels << "|,\\ \n 1.5U"
      end
    when 1.75
      size_counts[1.75] += 1
      if size_counts[1.75] == 1
        key_labels << "Caps \n 1.75U"
      else
        key_labels << "Shift \n 1.75U"
      end
    when 2.0
      key_labels << "Backspace \n 2U"
    when 2.25
      size_counts[2.25] += 1
      if size_counts[2.25] == 1
        key_labels << "Shift \n 2.25U"
      else
        key_labels << "Enter \n 2.25U"
      end
    when 2.75
      key_labels << "Shift \n 2.75U"
    when 6.25
      key_labels << "Space \n 6.25U"
    else
      key_labels << "Spec? \n #{size}U"
    end
  end

  # KLE 用に整形
  key_objects = combo.map.with_index do |size, index|
    if size == 1.0
      key_labels[index]
    else
      [{w: size},key_labels[index]]
    end
  end

  # KLE にそのままペーストできるものが出力される。
  puts "#{key_objects.flatten.inspect},"
end

puts "\nTotal valid combinations: #{combinations.size}"
