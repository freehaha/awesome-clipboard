-- Copyright (C) 2012 freehaha@gmail.com
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom
-- the Software is furnished to do so, subject to the following
-- conditions:
--
-- The above copyright notice and this permission notice shall
-- be included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
--
local awful = awful

clipboard_path = os.getenv("HOME") .. "/.sel"

-- sub string function for utf8 strings copied from:
-- http://wowprogramming.com/snippets/UTF-8_aware_stringsub_7

-- UTF-8 Reference:
-- 0xxxxxxx - 1 byte UTF-8 codepoint (ASCII character)
-- 110yyyxx - First byte of a 2 byte UTF-8 codepoint
-- 1110yyyy - First byte of a 3 byte UTF-8 codepoint
-- 11110zzz - First byte of a 4 byte UTF-8 codepoint
-- 10xxxxxx - Inner byte of a multi-byte UTF-8 codepoint

local function chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

-- This function can return a substring of a UTF-8 string, properly handling
-- UTF-8 codepoints.  Rather than taking a start index and optionally an end
-- index, it takes the string, the starting character, and the number of
-- characters to select from the string.

local function utf8sub(str, startChar, numChars)
  local startIndex = 1
  while startChar > 1 do
      local char = string.byte(str, startIndex)
      startIndex = startIndex + chsize(char)
      startChar = startChar - 1
  end

  local currentIndex = startIndex

  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    currentIndex = currentIndex + chsize(char)
    numChars = numChars -1
  end
  return str:sub(startIndex, currentIndex - 1)
end

function clipboard_menu()
	entries = {}
	i = 1
	for line in io.lines(clipboard_path) do
		local idx = i
		entries[i] = {
			utf8sub(line, 0, 25) .. "...",
			function()
				cmd = "sed -n '".. idx .. "," .. idx .."p' " .. clipboard_path .. " | perl -pe 's/#NL/\\n/g' | xclip -d :0 -selection primary"
				awful.util.spawn_with_shell(cmd)
				naughty.notify({
					text = string.gsub(line, '(#NL)', "\n"),
					timeout = 3
				})
			end
		}
		i = i + 1
	end
	awful.menu.new({
		items = entries,
		width = 300,
	}):show({keygrabber= true})
end

function clear_clipboard()
	local file = io.open(clipboard_path, "w")
	file:flush()
	file:close()
end

function copy_to_clipboard()
	local sel = selection()
	local file = io.open(clipboard_path, "a")
	sel = string.gsub(sel, '(\n)', '#NL')
	naughty.notify({
		text = sel,
		timeout = 3
	})
	file:write(sel)
	file:write("\n")
	file:flush()
	file:close()
end

