------
-- Neuro-CrowDのセクションを表すオブジェクト群
-- @module sections
-- @author hazymoon(tnx.hazymoon@gmail.com)
-- @license MIT
-- @copyright hazymoon, 2016

local utf8 = require('lua-utf8')
local uuid = require('uuid')

local function levelIs(line)
    local mark = utf8.match(line, "^([■◆●▼]+).*$")
    if line == 'root' then
        return 0
    elseif mark == '■' then
        return 1
    elseif mark == '◆' then
        return 2
    elseif mark == '●' then
        return 3
    elseif mark == '▼' then
        return 4
    else
        return -1
    end
end

---- セクションオブジェクト
-- @param line セクションの元となる行
-- @param aParent 親セクション
-- @section Section
local function Section(line, aParent)
    local self = {}

    local level = levelIs(line)
    local sectionName = utf8.match(line, '^[■◆●▼]+(.*)$')
    local parent = aParent
    local children = {}
    local sentences = {}
    self.id = uuid()

    --- 子セクションの追加
    -- @param child 子セクション
    function self.addChild(child)
        table.insert(children, child)
    end

    --- セクション内文章の追加
    -- @param aLine 追加する文章
    function self.append(aLine)
        assert(type(aLine) == "string")
        table.insert(sentences, aLine)
    end

    ---- 階層レベルを整数で返す
    function self.levelIs()
        return level
    end

    ---- セクション名を返す(セクション名が'dummy'の場合は空文字列を返す)
    function self.name()
        return sectionName ~= 'dummy' and sectionName or ''
    end

    function self.getParent()
        return parent
    end

    ---- 子の有無
    function self.hasChild()
        print('current(69): ' .. self.name())
        print('children: ' .. #children)
        if #children > 0 then
            return true
        else
            return false
        end
    end

    ---- セクション同士の階層の比較
    -- @param target 比較対象のセクション
    -- @return 負数:自セクションが下階層、0:同階層、正数:自セクションが上階層
    function self.compareTo(target)
        return target.levelIs() - level
    end

    ---- 子のイテレータ取得
    -- @return 子を先頭から数え上げるイテレータ
    function self.iterateChildren()
        return coroutine.wrap(function ()
            local i = 1
            while true do
                coroutine.yield(children[i])
                i = i + 1
                if i > #children then
                    break
                end
            end
            return nil
        end)
    end

    ---- 子の逆順イテレータ取得
    -- @return 子を後ろから数え上げるイテレータ
    function self.reverseIterateChildren()
        return coroutine.wrap(function()
            local i = #children
            while true do
                coroutine.yield(children[i])
                i = i - 1
                if i < 1 then
                    break
                end
            end
            return nil
        end)
    end

    function self.walk()
        return coroutine.wrap(function()
            local current = self
            local stack = {}
            while true do
                -- print(current.name())
                if stack[current.id] == nil then
                    stack[current.id] = current
                    coroutine.yield(current)
                end
                if not current.hasChild then
                    current = current.getParent()
                else
                    local not_in_stack = false
                    for child in current.iterateChildren() do
                        if stack[child.id] == nil then
                            not_in_stack = true
                            current = child
                            break
                        end
                    end
                    if not not_in_stack then
                        current = current.getParent()
                    end
                end
                if current == self.getParent() then
                    break
                end
            end
        end)
    end

    if parent ~= nil then
        parent.addChild(self)
    end

    return self
end

return {
    Section = Section,
}