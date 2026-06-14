--[[
    Unit Tests for the Config System (Core/Icons.lua)
    Tests: Save, Load, Delete, flag serialization
]]

package.path = package.path .. ";./?.lua;./?/init.lua"

local lu = require("tests.lib.luaunit")
require("tests.lib.roblox_mock") -- sets up global file system mocks
local Config = require("tests.modules.config")

TestConfig = {}

function TestConfig:setUp()
    _resetFileSystem()
end

-- Helper to create a mock flag
local function createFlag(value)
    local flag = { Value = value }
    function flag:Get() return self.Value end
    function flag:Set(v) self.Value = v end
    return flag
end

-- Test Save with no flags
function TestConfig:test_save_empty_flags()
    local result = Config:Save({})
    lu.assertTrue(result)
end

-- Test Save with nil flags
function TestConfig:test_save_nil_flags()
    local result = Config:Save(nil)
    lu.assertTrue(result)
end

-- Test Save creates file
function TestConfig:test_save_creates_file()
    local flags = { Speed = createFlag(50) }
    Config:Save(flags)
    local path = Config.Folder .. "/" .. Config.File
    lu.assertTrue(isfile(path))
end

-- Test Save serializes flag values
function TestConfig:test_save_serializes_values()
    local flags = {
        Speed = createFlag(100),
        Enabled = createFlag(true),
    }
    Config:Save(flags)
    local path = Config.Folder .. "/" .. Config.File
    local content = readfile(path)
    lu.assertNotNil(content)
    lu.assertStrContains(content, "Speed")
    lu.assertStrContains(content, "100")
end

-- Test Load with no saved file returns false
function TestConfig:test_load_no_file()
    local result = Config:Load({})
    lu.assertFalse(result)
end

-- Test Save then Load roundtrip
function TestConfig:test_save_load_roundtrip()
    local flags = {
        Speed = createFlag(75),
        Jump = createFlag(200),
    }
    Config:Save(flags)

    -- Reset flag values
    flags.Speed:Set(0)
    flags.Jump:Set(0)

    local ok, count = Config:Load(flags)
    lu.assertTrue(ok)
    lu.assertEquals(count, 2)
    lu.assertEquals(flags.Speed:Get(), 75)
    lu.assertEquals(flags.Jump:Get(), 200)
end

-- Test Load with boolean values
function TestConfig:test_save_load_booleans()
    local flags = {
        Enabled = createFlag(true),
        Disabled = createFlag(false),
    }
    Config:Save(flags)

    flags.Enabled:Set(false)
    flags.Disabled:Set(true)

    Config:Load(flags)
    lu.assertEquals(flags.Enabled:Get(), true)
    lu.assertEquals(flags.Disabled:Get(), false)
end

-- Test Load with string values
function TestConfig:test_save_load_strings()
    local flags = {
        Mode = createFlag("CFrame"),
    }
    Config:Save(flags)
    flags.Mode:Set("")
    Config:Load(flags)
    lu.assertEquals(flags.Mode:Get(), "CFrame")
end

-- Test Load only updates flags that exist in saved data
function TestConfig:test_load_partial()
    local flags = {
        A = createFlag(10),
        B = createFlag(20),
        C = createFlag(30),
    }
    -- Save only A and B
    Config:Save({ A = createFlag(10), B = createFlag(20) })

    flags.A:Set(0)
    flags.B:Set(0)
    flags.C:Set(99)

    local ok, count = Config:Load(flags)
    lu.assertTrue(ok)
    lu.assertEquals(count, 2)
    lu.assertEquals(flags.C:Get(), 99) -- unchanged
end

-- Test Delete removes the file
function TestConfig:test_delete()
    Config:Save({ X = createFlag(1) })
    local path = Config.Folder .. "/" .. Config.File
    lu.assertTrue(isfile(path))

    local result = Config:Delete()
    lu.assertTrue(result)
    lu.assertFalse(isfile(path))
end

-- Test Delete when no file exists
function TestConfig:test_delete_no_file()
    local result = Config:Delete()
    lu.assertFalse(result)
end

-- Test Load after Delete returns false
function TestConfig:test_load_after_delete()
    Config:Save({ X = createFlag(5) })
    Config:Delete()
    local result = Config:Load({ X = createFlag(0) })
    lu.assertFalse(result)
end

-- Test Save skips non-table and non-Get flags
function TestConfig:test_save_skips_invalid_flags()
    local flags = {
        Valid = createFlag(42),
        InvalidStr = "not a table",
        InvalidNoGet = { Value = 10 }, -- no Get method
    }
    Config:Save(flags)
    local path = Config.Folder .. "/" .. Config.File
    local content = readfile(path)
    lu.assertStrContains(content, "42")
    -- InvalidStr and InvalidNoGet should not appear as serialized values
end

-- Test Load with flags that have no Set method (should skip gracefully)
function TestConfig:test_load_skips_no_set_method()
    Config:Save({ A = createFlag(100) })
    local flags = { A = { Get = function(self) return 0 end } } -- no Set
    local ok, count = Config:Load(flags)
    lu.assertTrue(ok)
    lu.assertEquals(count, 0) -- didn't set anything
end

-- Test Config folder/file path configuration
function TestConfig:test_default_paths()
    lu.assertEquals(Config.Folder, "Hyper_M4X/Configs")
    lu.assertEquals(Config.File, "settings.json")
end

os.exit(lu.LuaUnit.run())
