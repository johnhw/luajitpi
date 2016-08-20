
sym_table = {}
for line in string.gmatch(fmap_string, '[^\r\n]+') do
    row = {}
    
    for col in string.gmatch(line, "%S+") do
      table.insert(row, col)
    end    
	
    sym_table[row[2]] = tonumber(row[1], 16)    
end
