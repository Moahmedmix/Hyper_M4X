--[[
    Unit Tests for the Logger System (Main.lua)
    Tests: Log levels, history management, timestamps, summary counting
]]

package.path = package.path .. ";./?.lua;./?/init.lua"

local lu = require("tests.lib.luaunit")
local Logger = require("tests.modules.logger")

TestLogger = {}

function TestLogger:setUp()
    Logger:Reset()
end

-- Test basic log entry creation
function TestLogger:test_log_creates_entry()
    local entry = Logger:Log("INFO", "i", "Hello World")
    lu.assertNotNil(entry)
    lu.assertEquals(entry.Level, "INFO")
    lu.assertEquals(entry.Icon, "i")
    lu.assertEquals(entry.Message, "Hello World")
end

-- Test that log entries have timestamps
function TestLogger:test_log_has_timestamp()
    local entry = Logger:Log("INFO", "i", "test")
    lu.assertNotNil(entry.Timestamp)
    lu.assertIsString(entry.Timestamp)
    -- Timestamp should be a decimal number like "0.001"
    lu.assertNotNil(tonumber(entry.Timestamp))
end

-- Test that log entries have formatted time
function TestLogger:test_log_has_formatted_time()
    local entry = Logger:Log("INFO", "i", "test")
    lu.assertNotNil(entry.Time)
    lu.assertIsString(entry.Time)
    -- Time format should be HH:MM:SS
    lu.assertNotNil(entry.Time:match("%d%d:%d%d:%d%d"))
end

-- Test that log entries have epoch time
function TestLogger:test_log_has_epoch()
    local entry = Logger:Log("INFO", "i", "test")
    lu.assertNotNil(entry.Epoch)
    lu.assertIsNumber(entry.Epoch)
    lu.assertTrue(entry.Epoch > 0)
end

-- Test Info shorthand
function TestLogger:test_info()
    local entry = Logger:Info("info message")
    lu.assertEquals(entry.Level, "INFO")
    lu.assertEquals(entry.Icon, "i")
    lu.assertEquals(entry.Message, "info message")
end

-- Test Good shorthand
function TestLogger:test_good()
    local entry = Logger:Good("success message")
    lu.assertEquals(entry.Level, "OK")
    lu.assertEquals(entry.Icon, "+")
    lu.assertEquals(entry.Message, "success message")
end

-- Test Warn shorthand
function TestLogger:test_warn()
    local entry = Logger:Warn("warning message")
    lu.assertEquals(entry.Level, "WARN")
    lu.assertEquals(entry.Icon, "!")
    lu.assertEquals(entry.Message, "warning message")
end

-- Test Error shorthand
function TestLogger:test_error()
    local entry = Logger:Error("error message")
    lu.assertEquals(entry.Level, "ERROR")
    lu.assertEquals(entry.Icon, "x")
    lu.assertEquals(entry.Message, "error message")
end

-- Test Skip shorthand
function TestLogger:test_skip()
    local entry = Logger:Skip("skip message")
    lu.assertEquals(entry.Level, "SKIP")
    lu.assertEquals(entry.Icon, ">")
    lu.assertEquals(entry.Message, "skip message")
end

-- Test Dead shorthand
function TestLogger:test_dead()
    local entry = Logger:Dead("dead message")
    lu.assertEquals(entry.Level, "DEAD")
    lu.assertEquals(entry.Icon, "X")
    lu.assertEquals(entry.Message, "dead message")
end

-- Test history tracking
function TestLogger:test_history_tracking()
    Logger:Info("first")
    Logger:Warn("second")
    Logger:Error("third")
    lu.assertEquals(#Logger.History, 3)
    lu.assertEquals(Logger.History[1].Message, "first")
    lu.assertEquals(Logger.History[2].Message, "second")
    lu.assertEquals(Logger.History[3].Message, "third")
end

-- Test history max limit enforcement
function TestLogger:test_history_max_limit()
    Logger.MaxHistory = 5
    for i = 1, 10 do
        Logger:Info("message " .. i)
    end
    lu.assertEquals(#Logger.History, 5)
    -- Should keep the latest entries
    lu.assertEquals(Logger.History[1].Message, "message 6")
    lu.assertEquals(Logger.History[5].Message, "message 10")
    Logger.MaxHistory = 500 -- restore
end

-- Test history rotation removes oldest
function TestLogger:test_history_rotation()
    Logger.MaxHistory = 3
    Logger:Info("A")
    Logger:Info("B")
    Logger:Info("C")
    Logger:Info("D")
    lu.assertEquals(#Logger.History, 3)
    lu.assertEquals(Logger.History[1].Message, "B")
    lu.assertEquals(Logger.History[2].Message, "C")
    lu.assertEquals(Logger.History[3].Message, "D")
    Logger.MaxHistory = 500
end

-- Test PrintSummary counts correctly
function TestLogger:test_print_summary_counts()
    Logger:Info("info 1")
    Logger:Info("info 2")
    Logger:Good("ok 1")
    Logger:Good("ok 2")
    Logger:Good("ok 3")
    Logger:Error("err 1")
    Logger:Dead("dead 1")
    Logger:Skip("skip 1")
    Logger:Skip("skip 2")

    local counts = Logger:PrintSummary()
    lu.assertEquals(counts.Info, 2)
    lu.assertEquals(counts.Success, 3)
    lu.assertEquals(counts.Errors, 2) -- ERROR + DEAD
    lu.assertEquals(counts.Skips, 2)
end

-- Test PrintSummary with empty history
function TestLogger:test_print_summary_empty()
    local counts = Logger:PrintSummary()
    lu.assertEquals(counts.Info, 0)
    lu.assertEquals(counts.Success, 0)
    lu.assertEquals(counts.Errors, 0)
    lu.assertEquals(counts.Skips, 0)
end

-- Test GetTimestamp returns increasing values
function TestLogger:test_timestamp_increases()
    local t1 = Logger:GetTimestamp()
    -- small busy-wait
    local x = 0; for i = 1, 100000 do x = x + i end
    local t2 = Logger:GetTimestamp()
    lu.assertTrue(tonumber(t2) >= tonumber(t1))
end

-- Test Reset clears history
function TestLogger:test_reset_clears_history()
    Logger:Info("test")
    Logger:Info("test2")
    lu.assertEquals(#Logger.History, 2)
    Logger:Reset()
    lu.assertEquals(#Logger.History, 0)
end

os.exit(lu.LuaUnit.run())
