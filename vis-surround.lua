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
            if i == a then return a end
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
            if i == a then return a end
        end
    end
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

local function change_surrounding(keys)
    if #keys < 2 then
        return -1
    end
    local old, new = keys:sub(1,1), keys:sub(2,2)
    local left_old, right_old = left(old), right(old)
    local left_new, right_new = left(new), right(new)
    if not (left_old and right_old and left_new and left_right) then
        return 2
    end
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
    return 2
end

local function delete_surrounding(keys)
    if #keys < 1 then
        return -1
    end
    local left = left(keys)
    local right = right(keys)
    if not (left and right) then return 1 end
    local win = vis.win
    local file = win.file
    local pos = win.selection.pos

    local l, r = find_surrounding(file, pos, left, right)
    if not l or not r then return end

    win.file:delete(l, 1)
    win.file:delete(r-1, 1)
    win.selection.pos = pos-1
    return 1
end

vis:map(vis.modes.NORMAL, "cs", change_surrounding, "Change surroundings")
vis:map(vis.modes.NORMAL, "ds", delete_surrounding, "Delete surroundings")

