def yes_or_no(txt)
  while true
    print txt + ' [y|n]: '
    response = STDIN.gets
    case response
      when /^[yY]/
        return true
      when /^[nN]/
        return false
    end
  end
end
