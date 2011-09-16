-- w1.lua 
--

module(..., package.seeall)

function fact (n)
	if n == 0 then
		return 1
	else
		return n * fact(n-1)
	end
end

run = function()
result = fact(9)
WorkPad1:setText(result)
print (result)
end