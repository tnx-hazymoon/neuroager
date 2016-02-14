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
	local parent = aParent
	local children = {}

	--- 子セクションの追加
	-- @param aSection 子セクション
	function self.appendChild(aSection)
		table.insert(children, aSection)
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

	function self.printFacts()
		for k, v in pairs(facts) do
			print(v)
		end
	end

	function self.childrenAre()
		return pairs(children)
	end

	if parent ~= nil then
		parent.appendChild(self)
	end

	return self
end

return {
	Level = Level,
	Section = Section,
}