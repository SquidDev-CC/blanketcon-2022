local function clear(self)
    for i = 1, self.width * self.height do self[i] = "0" end
end

local function create(width, height)
    local self = { width = width, height = height }
    clear(self)
    return self
end

local function point(self, x, y, colour)
    assert(x >= 0 and x < self.width)
    assert(y >= 0 and y < self.height)
    assert(colour)
    self[1 + x + y * self.width] = colour
end

local function draw(self, term, start_x, start_y)
    local width, height, blit, char = self.width, self.height, term.blit, string.char

    for y = 0, height - 1, 3 do
        term.setCursorPos(start_x, (y / 3) + start_y)

        for x = 0, width - 1, 2 do
            local totals = {}
            local unique = {}
            for y1 = y, y + 2 do
                for x1 = x, x + 1 do
                    local col = self[(width * y1) + x1 + 1]
                    if col == nil then print((width * y1) + x1 + 1) end
                    local count = totals[col]
                    if count then
                        totals[col] = count + 1
                    else
                        unique[#unique + 1] = col
                        totals[col] = 1
                    end
                end
            end

            if #unique == 1 then
                blit(" ", "0", unique[1])
            else
                table.sort(unique, function(a, b) return totals[a] > totals[b] end)
                local bg = unique[1]
                local fg = unique[2]
                local last
                if self[(width * (y + 2)) + x + 2] == fg then
                    last = fg
                else
                    last = bg
                end
                local code, match_col = 128

                if self[(width * (y + 0)) + x + 0 + 1] == fg then
                    match_col = fg
                else
                    match_col = bg
                end
                if match_col ~= last then code = code + 1 end

                if self[(width * (y + 0)) + x + 1 + 1] == fg then
                    match_col = fg
                else
                    match_col = bg
                end
                if match_col ~= last then code = code + 2 end

                if self[(width * (y + 1)) + x + 0 + 1] == fg then
                    match_col = fg
                else
                    match_col = bg
                end
                if match_col ~= last then code = code + 4 end

                if self[(width * (y + 1)) + x + 1 + 1] == fg then
                    match_col = fg
                else
                    match_col = bg
                end
                if match_col ~= last then code = code + 8 end

                if self[(width * (y + 2)) + x + 0 + 1] == fg then
                    match_col = fg
                else
                    match_col = bg
                end
                if match_col ~= last then code = code + 16 end

                local c = char(code)
                if last == bg then
                    blit(c, fg, bg)
                else
                    blit(c, bg, fg)
                end
            end
        end
    end
end

return { clear = clear, create = create, draw = draw, point = point }
