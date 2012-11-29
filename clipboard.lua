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

function clipboard_menu()
	entries = {}
	i = 1
	for line in io.lines(clipboard_path) do
		local idx = i
		entries[i] = {
			string.sub(line, 0, 25) .. "...",
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

