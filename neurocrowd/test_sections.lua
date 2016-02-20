------
-- sectionsのテスト

local luaunit = require('luaunit')
local utf8 = require('lua-utf8')
local sections = require('sections')
local Section = sections.Section

---- テストスイート：Section
TestSection = {}

---- インスタンス生成
function TestSection:testNew()
    local section = Section('■セクション')
    luaunit.assertEquals(section.levelIs(), 1)
end

---- 同階層の比較
function TestSection:testCompareToEquals()
    local section1 = Section('■セクション1')
    local section2 = Section('■セクション2')
    luaunit.assertEquals(section1.compareTo(section2), 0)
end

---- 階層比較（自分が上位）
function TestSection:testCopareToHigher()
    local section1 = Section('■セクション1')
    local section2 = Section('◆セクション2')
    luaunit.assertEquals(section1.compareTo(section2), 1)
end

---- 階層比較（自分が下位）
function TestSection:testCompareToLower()
    local section1 = Section('◆セクション1')
    local section2 = Section('■セクション2')
    luaunit.assertEquals(section1.compareTo(section2), -1)    
end

---- 子のイテレータのテスト
function TestSection:testIterateChildren()
    local parent = Section('■親')
    local child1 = Section('◆子１', parent)
    local child2 = Section('◆子２', parent)
    local child3 = Section('◆子３', parent)
    local result = {}
    for child in parent.iterateChildren() do
        table.insert(result, child)
    end
    luaunit.assertEquals(result, {child1, child2, child3})
end

os.exit(luaunit.LuaUnit.run())
