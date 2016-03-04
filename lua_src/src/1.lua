

print(_VERSION)

local a = 'alo\n123"'
print(a)
     a = "alo\n123\""
     print(a)
     a = '\97lo\10\04923"'
     print(a)
     a = [[alo
     123"]]
     print(a)
     a = [=[
     alo
     123"]=]
     print(a)


local cc = "afdffda"
print(#cc,string.len(cc))

a = {}
local x = 20
for i= 1,10 do
	local y = 0
	a[i] = function ( ... )
		y = y + 1
		return x + i + y
	end

end

for k,value in ipairs(a) do
	print(k,value())
end



