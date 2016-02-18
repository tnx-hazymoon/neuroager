------
-- sectionsのテスト

local luaunit = require('luaunit')
local utf8 = require('lua-utf8')
local sections = require('sections')
local level = sections.Level

TestLevel = {}

----
-- 階層レベルオブジェクトの初期化のテスト(root階層の時)
function TestLevel:test_initialize_root()
    local obj_level0 = level('root')
    luaunit.assertEquals(obj_level0.is(), 0)
end

----
-- 階層レベルオブジェクトの初期化のテスト(第1階層の時)
function TestLevel:test_initialize_level1()
    local obj_level1 = level('■')
    luaunit.assertEquals(obj_level1.is(), 1)
end

----
-- 階層レベルオブジェクトの初期化のテスト(第2階層の時)
function TestLevel:test_initialize_level2()
    local obj_level2 = level('◆')
    luaunit.assertEquals(obj_level2.is(), 2)
end

------
-- 階層レベルオブジェクトの初期化のテスト(第3階層の時)
function TestLevel:test_initialize_level3()
    local obj_level3 = level('●')
    luaunit.assertEquals(obj_level3.is(), 3)
end

------
-- 階層レベルオブジェクトの初期化のテスト(第4階層の時)
function TestLevel:test_initialize_level4()
    local obj_level4 = level('▼')
    luaunit.assertEquals(obj_level4.is(), 4)
end

------
-- 階層レベルオブジェクトの初期化のテスト(不正な値で生成しようとしたとき)
function TestLevel:test_initialize_invalid()
    local markInvalid = level('')
    luaunit.assertEquals(markInvalid.is(), -1)
end

------
-- 階層レベルオブジェクトの比較のテスト、階層が低いとき
function TestLevel:test_compareTo_lower_case()
    local me = level('▼')
    local other = level('●')
    luaunit.assertEquals(me.compareTo(other), -1)
end

------
-- 階層レベルオブジェクトの比較テスト、同レベル階層のとき
function TestLevel:test_compareTo_same_case()
    local me = level('▼')
    local other = level('▼')
    luaunit.assertEquals(me.compareTo(other), 0)
end

------
-- 階層レベルオブジェクトの比較テスト、階層が高いとき
function TestLevel:test_compareTo_higher_case()
    local me = level('●')
    local other = level('▼')
end

os.exit(luaunit.LuaUnit.run())
