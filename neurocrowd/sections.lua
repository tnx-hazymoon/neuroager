------
-- Neuro-CrowDのセクションを表すオブジェクト群
-- @module sections
-- @author hazymoon(tnx.hazymoon@gmail.com)
-- @license MIT
-- @copyright hazymoon, 2016

local utf8 = require('lua-utf8')

------
-- 階層レベルオブジェクト
-- @param aMark 階層レベルマーク（root、■、◆、●、▼のいずれか）
-- @section Level
local function Level(aMark)
    local self = {}
    local mark = aMark
    
    ------
    -- 階層レベルの取得
    -- @return 階層レベル（0～4）、不正な場合は-1を返す
    function self.is()
        if mark == 'root' then
            return 0
        elseif mark == '■' then
            return  1
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

    ----
    -- 階層レベルの比較
    -- @param other 他セクションの階層レベルオブジェクト
    -- @return -1:otherの方が上の階層、0:同レベル、1:otherの方が下の階層
    function self.compareTo(other)
        local result = other.is() - self.is()
        if result == 0 then
            return 0
        elseif result < 0 then
            return -1
        else
            return 1
        end
    end

    return self
end

---- 親子関係オブジェクト
-- @param aParent 親
-- @return 親子関係オブジェクト
local function Relation(aParent)
    local self = {}
    local parent = aParent
    local children = {}

    ---- 子の追加
    -- @param child 追加する子
    function self.addChild(child)
        table.insert(children, child)
    end

    ---- 親の取得
    -- @return 親
    function self.parentIs()
        -- functionを親としてインスタンスを作ったのち、このメソッドで返すと別インスタンスになる
        return parent
    end

    ---- 子のイテレータ取得
    -- @return 子を数え上げるイテレータ
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
        end)
    end

    return self
end

---- セクションオブジェクト
-- @param line セクションの元となる行
-- @param aParent 親セクション
-- @section Section
local function Section(line, aParent)
    local self = {}

    -- fields
    local levelMark = utf8.match(line, "^([■◆●▼]+).*$")
    local level = Level(levelMark)
    local sectionName = utf8.match(line, "^[■◆●▼](.*)$")
    local facts = {}
    local relation = Relation(aParent)

    --- 子セクションの追加
    -- @param aSection 子セクション
    function self.addChildren(aSection)
        relation.addChildren(aSection)
    end

    --- セクションレベルの取得
    -- @return セクションレベル
    function self.levelIs()
        return level.is()
    end

    --- セクション名の取得
    -- @return セクション名
    function self.toString()
        return levelMark .. sectionName 
    end

    --- セクション内文章の追加
    -- @param aLine 追加する文章
    function self.append(aLine)
        assert(type(aLine) == "string")
        table.insert(facts, aLine)
    end

    ---- セクション同士の階層の比較
    -- @param target 比較対象のセクション
    -- @return -1:自セクションが下階層、0:同階層、1:自セクションが上階層
    function self.compareTo(target)
        local result = target.levelIs() - self.levelIs()
        if result < 0 then
            return -1
        elseif result == 0 then
            return 0
        else
            return 1
        end
    end

    ---- 子を数え上げる
    -- @return 子を数え上げるイテレータ
    function self.iterateChildren()
        return relation.iterateChildren()
    end

    aParent.addChildren(self)

    return self
end

return {
    Level = Level,
    Relation = Relation,
    Section = Section,
}