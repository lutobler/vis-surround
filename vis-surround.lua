-- all possible surroundings
local surroundings = {
    { '{', '}' },
    { '[', ']' },
    { '(', ')' },
    { '<', '>' },
    '"',
    '\''
}

local function left(a)
    for _,i in pairs(surroundings) do
        if type(i) == 'table' then
            if i[1] == a then
                return a
            elseif i[2] == a then
                return i[1]
            end
        else
            if i == a then
                return a
            end
        end
    end
end

local function right(a)
    for _,i in pairs(surroundings) do
        if type(i) == 'table' then
            if i[1] == a then
                return i[2]
            elseif i[2] == a then
                return a
            end
        else
            if i == a then
                return a
            end
        end
    end
end

local function flatten(t)
    local r = {}
    local function f(t)
        for _,v in ipairs(t) do
            if type(v) == 'table' then
                f(v)
            else
                table.insert(r, v)
            end
        end
    end
    f(t)
    return r
end

local function mappings(s)
    local m = {}
    local flat = flatten(s)
    for _,i in pairs(s) do
        if type(i) == 'table' then
            for _,j in pairs(flat) do
                if j ~= i[1] and j ~= i[2] then
                    table.insert(m, i[1]..j)
                    table.insert(m, i[2]..j)
                end
            end
        else
            for _,j in pairs(flat) do
                if j ~= i then
                    table.insert(m, i..j)
                end
            end
        end
    end
    return m
end

-- escape all magic characters with a '%'
local function esc(str)
    if not str then return "" end
    return (str:gsub('%%', '%%%%')
        :gsub('^%^', '%%^')
        :gsub('%$$', '%%$')
        :gsub('%(', '%%(')
        :gsub('%)', '%%)')
        :gsub('%.', '%%.')
        :gsub('%[', '%%[')
        :gsub('%]', '%%]')
        :gsub('%*', '%%*')
        :gsub('%+', '%%+')
        :gsub('%-', '%%-')
        :gsub('%?', '%%?'))
end

local function find_surrounding(file, pos, left, right)
    local left_data = file:content(0, pos)
    local right_data = file:content(pos+1, file.size)
    local left_idx = left_data:match('^.*()' .. esc(left))
    local right_idx = right_data:match('^[^' .. esc(right) .. ']*()')
    if left_idx and right_idx then
        return (left_idx - 1), (pos + right_idx)
    else
        return nil
    end
end

local function change_surrounding(i)
    local old, new = i:sub(1,1), i:sub(2,2)
    local left_old, right_old = left(old), right(old)
    local left_new, right_new = left(new), right(new)

    return function()
        local win = vis.win
        local file = win.file
        local pos = win.selection.pos

        local l, r = find_surrounding(file, pos, left_old, right_old)
        if not l or not r then return end

        win.file:delete(l, 1)
        win.file:insert(l, left_new)
        win.file:delete(r, 1)
        win.file:insert(r, right_new)
        win.selection.pos = pos
    end
end

local function delete_surrounding(i)
    local left = left(i)
    local right = right(i)

    return function()
        local win = vis.win
        local file = win.file
        local pos = win.selection.pos

        local l, r = find_surrounding(file, pos, left, right)
        if not l or not r then return end

        win.file:delete(l, 1)
        win.file:delete(r-1, 1)
        win.selection.pos = pos-1
    end
end

for _,i in pairs(mappings(surroundings)) do
    vis:map(vis.modes.NORMAL, "cs"..i, change_surrounding(i))
end

for _,i in pairs(flatten(surroundings)) do
    vis:map(vis.modes.NORMAL, "ds"..i, delete_surrounding(i))
end
