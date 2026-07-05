local Utils={}

function Utils.formatNumber(n)
 n=tonumber(n) or 0
 local a=math.abs(n)
 if a>=1000000000000 then return string.format("%.1fT",n/1000000000000) end
 if a>=1000000000 then return string.format("%.1fB",n/1000000000) end
 if a>=1000000 then return string.format("%.1fM",n/1000000) end
 if a>=1000 then return string.format("%.1fK",n/1000) end
 return tostring(math.floor(n))
end

function Utils.truncate(text,width)
 text=tostring(text or "")
 if #text<=width then return text end
 if width<=3 then return text:sub(1,width) end
 return text:sub(1,width-3).."..."
end

function Utils.padRight(text,width)
 text=tostring(text or "")
 if #text>=width then return text end
 return text..string.rep(" ",width-#text)
end

function Utils.padLeft(text,width)
 text=tostring(text or "")
 if #text>=width then return text end
 return string.rep(" ",width-#text)..text
end

function Utils.sortByAmount(items)
 table.sort(items,function(a,b)
  return (a.amount or 0)>(b.amount or 0)
 end)
end

function Utils.time()
 return textutils.formatTime(os.time(),true)
end

function Utils.bar(value,max,width)
 value=tonumber(value) or 0
 max=tonumber(max) or 1
 if max<=0 then max=1 end
 local filled=math.floor((value/max)*width)
 if filled<0 then filled=0 end
 if filled>width then filled=width end
 return string.rep("#",filled)..string.rep("-",width-filled)
end

return Utils
