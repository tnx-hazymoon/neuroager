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
    function self.addSentence(aLine)
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
        return #children > 0 and true or false
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
            for i = 1, #children do
                coroutine.yield(children[i])
            end
            return nil
        end)
    end

    ---- 子の逆順イテレータ取得
    -- @return 子を後ろから数え上げるイテレータ
    function self.reverseIterateChildren()
        return coroutine.wrap(function()
            for i = #children, 1, -1 do
                coroutine.yield(children[i])
            end
            return nil
        end)
    end

    ---- 本文のイテレータ取得
    -- @return 本文を1行ずつ取得するイテレータ
    function self.iterateSentences()
        return coroutine.wrap(function()
            for i = 1, #sentences do
                coroutine.yield(sentences[i])
            end
            return nil
        end)
    end

    ---- 自分自身を起点として子階層の構造を渡り歩くイテレータの取得
    -- @return 自分自身を起点とする子階層の構造を渡り歩くイテレータ
    function self.walk()
        local function moveToChildIfNotInStack(current, stack)
            for child in current.iterateChildren() do
                if stack[child.id] == nil then
                    return child
                end
            end
            return current.getParent()
        end
        return coroutine.wrap(function()
            local current = self
            local stack = {}
            while current ~= self.getParent() do
                if stack[current.id] == nil then
                    stack[current.id] = current
                    coroutine.yield(current)
                end
                if not current.hasChild then
                    current = current.getParent()
                else
                    current = moveToChildIfNotInStack(current, stack)
                end
            end
        end)
    end

    if parent ~= nil then
        parent.addChild(self)
    end

    return self
end

---- 作者オブジェクト
-- Sectionを継承
-- @param line セクション行
-- @param parent 親セクション
local function Author(line, parent)

    -- inheritance
    local self = Section(line, parent)
    
    ---- 本文の追加
    -- lineが「　<名前>（twitter:<@Twitterアカウント>）」の形式の時、作者名とTwitterアカウントを抽出
    -- それ以外はSection.addSentenceと同じく本文を追加します
    -- @param line 追加する本文
    local parent_addSentence = self.addSentence
    function self.addSentence(line)
        local matched = utf8.find(line, '^　*.*（twitter：@.*）$')
        if matched == nil then
            parent_addSentence(line)
        else
            self.name = utf8.match(line, '　*([^（]+)')
            self.twitter = utf8.match(line, '（twitter：(@.*)）')
        end
    end

    return self
end

return {
    Section = Section,
    Author = Author,
}