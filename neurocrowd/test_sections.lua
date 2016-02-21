------
-- sectionsのテスト

local luaunit = require('luaunit')
local utf8 = require('lua-utf8')
local sections = require('sections')
local Section = sections.Section
local Author = sections.Author
local Range = sections.Range


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

---- 階層構造を渡り歩くイテレータのテスト
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


---- テストスイート：Author
TestAuthor = {}

---- 作者名とTwitterアカウントの抽出テスト
function TestAuthor:testAddSentence()
    local section = Author('▼作者')
    section.addSentence('　朧月（twitter：@tnx-hazymoon）')
    luaunit.assertEquals(section.name, '朧月')
    luaunit.assertEquals(section.twitter, '@tnx-hazymoon')
end

---- 通常の本文の取得テスト
function TestAuthor:testIterateSentences()
    local section = Author('▼作者')
    section.addSentence('　朧月（twitter：@tnx-hazymoon）')
    section.addSentence('本文１')
    section.addSentence('本文２')
    section.addSentence('本文３')
    local result = {}
    for sentence in section.iterateSentences() do
        table.insert(result, sentence)
    end
    luaunit.assertEquals(result, {'本文１', '本文２', '本文３'})
end


---- テストスイート：Range
TestRange = {}

---- 「　<数値（全角）>人」のパターンの時のテスト
function TestRange:testAddSentence()
    local section = Range('▼プレイヤー人数')
    section.addSentence('　９９人')
    luaunit.assertEquals(section.min, 99)
    luaunit.assertEquals(section.max, 99)
end

---- 「　<最少数（全角）>～<最大数（全角）>人」のパターンの時のテスト
function TestRange:testAddSentenceRangeCase()
    local section = Range('▼プレイヤー人数')
    section.addSentence('　１～９９人')
    luaunit.assertEquals(section.min, 1)
    luaunit.assertEquals(section.max, 99)
end

---- 「　<数値（半角）>人」のパターンの時のテスト
function TestRange:testAddSentenceHalf()
    local section = Range('▼プレイヤー人数')
    section.addSentence('　99人')
    luaunit.assertEquals(section.min, 99)
    luaunit.assertEquals(section.max, 99)
end

---- 「　<最少数（半角）>～<最大数（半角）>人」のパターンの時のテスト
function TestRange:testAddSentenceRangeCaseHalf()
    local section = Range('▼プレイヤー人数')
    section.addSentence('　1～99人')
    luaunit.assertEquals(section.min, 1)
    luaunit.assertEquals(section.max, 99)
end


---- 人数を０から始めたときのテスト（このときは抽出しない）
function TestRange:testAddSentenceIllegalCase()
    local section = Range('▼プレイヤー人数')
    section.addSentence('　０９人')
    luaunit.assertEquals(section.min, nil)
    luaunit.assertEquals(section.max, nil)
end

---- 通常の本文取得のテスト
function TestRange:testIterateSentences()
    local section = Range('▼プレイヤー人数')
    section.addSentence('　９９人')
    section.addSentence('本文１')
    section.addSentence('本文２')
    section.addSentence('本文３')
    local result = {}
    for sentence in section.iterateSentences() do
        table.insert(result, sentence)
    end
    luaunit.assertEquals(result, {'本文１', '本文２', '本文３'})
end

os.exit(luaunit.LuaUnit.run())
