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

---- 子の逆順イテレータのテスト
function TestSection:testReverseIterateChildren()
    local parent = Section('■親')
    local child1 = Section('◆子１', parent)
    local child2 = Section('◆子２', parent)
    local child3 = Section('◆子３', parent)
    local result = {}
    for child in parent.reverseIterateChildren() do
        table.insert(result, child)
    end
    luaunit.assertEquals(result, {child3, child2, child1})
end

function TestSection:testWalk()
    local parent = Section('■親')
    local child1 = Section('◆子１', parent)
    local child2 = Section('◆子２', parent)
    local child3 = Section('◆子３', parent)
    local grand_child1 = Section('◆孫１', child1)
    local grand_child2 = Section('◆孫２', child1)
    local grand_child3 = Section('◆孫３', child2)
    local grand_child4 = Section('◆孫４', child2)
    local grand_child5 = Section('◆孫５', child3)
    local grand_child6 = Section('◆孫６', child3)
    local great_grand_child1 = Section('●曾孫１', grand_child1)
    local great_grand_child2 = Section('●曾孫２', grand_child3)
    local great_grand_child3 = Section('●曾孫３', grand_child6)

    local result = {}
    for node in parent.walk() do
        table.insert(result, node)
    end
    luaunit.assertEquals(result, {parent, child1, grand_child1, great_grand_child1,
                         grand_child2, child2, grand_child3, great_grand_child2,
                         grand_child4, child3, grand_child5, grand_child6, great_grand_child3})
end

os.exit(luaunit.LuaUnit.run())
