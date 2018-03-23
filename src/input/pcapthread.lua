-- Copyright (c) 2018, OARC, Inc.
-- All rights reserved.
--
-- This file is part of dnsjit.
--
-- dnsjit is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dnsjit is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dnsjit.  If not, see <http://www.gnu.org/licenses/>.

-- dnsjit.input.pcapthread
-- Read input from an interface or PCAP file
--   local input = require("dnsjit.input.pcapthread").new()
--   input:open_offline("file.pcap")
--   input:receiver(filter_or_output)
--   input:run()
--
-- Input module for reading input from interfaces and PCAP files.
module(...,package.seeall)

local ch = require("dnsjit.core.chelpers")
require("dnsjit.input.pcapthread_h")
local ffi = require("ffi")
local C = ffi.C

local t_name = "input_pcapthread_t"
local input_pcapthread_t = ffi.typeof(t_name)
local Pcapthread = {}

-- Create a new Pcapthread input.
function Pcapthread.new()
    local self = {
        _receiver = nil,
        obj = input_pcapthread_t(),
    }
    C.input_pcapthread_init(self.obj)
    ffi.gc(self.obj, C.input_pcapthread_destroy)
    return setmetatable(self, { __index = Pcapthread })
end

-- Return the Log object to control logging of this instance or module.
function Pcapthread:log()
    if self == nil then
        return C.input_pcapthread_log()
    end
    return self.obj._log
end

-- Set the receiver to pass queries to.
function Pcapthread:receiver(o)
    self.obj._log:debug("receiver()")
    self.obj.recv, self.obj.ctx = o:receive()
    self._receiver = o
end

-- Only pass DNS queries, the DNS header will be parsed and QR must be 0.
function Pcapthread:only_queries(bool)
    if bool == nil then
        return ch.i2b(self.obj.only_queries)
    end
    local b = ch.b2i(bool)
    if b == nil then
        return 1
    end
    self.obj.only_queries = b
end

-- Return the snaphot length, see
-- .BR pcap_snapshot (3pcap)
-- for more information.
function Pcapthread:snapshot()
    return C.pcap_thread_snapshot(self.obj.pt)
end

-- Set the number of bytes to try and capture, use
-- .BR snaphot ()
-- too see how many bytes are actually captured.
-- If
-- .I len
-- is not specified then return the number of bytes that was previously
-- set by this function.
function Pcapthread:snaplen(len)
    if len == nil then
        return C.pcap_thread_snaplen(self.obj.pt)
    end
    return ch.z2n(C.pcap_thread_set_snaplen(self.obj.pt, len))
end

-- Enable (true) or disable (false) promiscuous mode, if
-- .I bool
-- is not specified then return if promiscuous mode is on (true) or off (false).
-- See
-- .BR pcap (3pcap)
-- for more information.
function Pcapthread:promiscuous(bool)
    if bool == nil then
        return ch.i2b(C.pcap_thread_promiscuous(self.obj.pt))
    end
    local b = ch.b2i(bool)
    if b == nil then
        return 1
    end
    return ch.z2n(C.pcap_thread_set_promiscuous(self.obj.pt, b))
end

-- Enable (true) or disable (false) monitor mode, if
-- .I bool
-- is not specified then return if monitor mode is on (true) or off (false).
-- See
-- .BR pcap (3pcap)
-- for more information.
function Pcapthread:monitor(bool)
    if bool == nil then
        return ch.i2b(C.pcap_thread_monitor(self.obj.pt))
    end
    local b = ch.b2i(bool)
    if b == nil then
        return 1
    end
    return ch.z2n(C.pcap_thread_set_monitor(self.obj.pt, b))
end

-- Set the timeout in milliseconds, if
-- .I ms
-- is not specified then return the current timeout.
-- See
-- .BR pcap_set_timeout (3pcap)
-- for more information.
function Pcapthread:timeout(ms)
    if ms == nil then
        return C.pcap_thread_timeout(self.obj.pt)
    end
    return ch.z2n(C.pcap_thread_set_timeout(self.obj.pt, ms))
end

-- Set the buffer size, if
-- .I size
-- is not specified then return the current buffer size.
-- See
-- .BR pcap_set_buffer_size (3pcap)
-- for more information.
function Pcapthread:buffer_size(size)
    if size == nil then
        return C.pcap_thread_buffer_size(self.obj.pt)
    end
    return ch.z2n(C.pcap_thread_set_buffer_size(self.obj.pt, size))
end

-- Enable (true) or disable (false) immediate mode, if
-- .I bool
-- is not specified then return if immediate mode is on (true) or off (false).
-- May have no effect depending on libpcap version.
-- See
-- .BR pcap_set_immediate_mode (3pcap)
-- for more information.
function Pcapthread:immediate_mode()
    if bool == nil then
        return ch.i2b(C.pcap_thread_immediate_mode(self.obj.pt))
    end
    local b = ch.b2i(bool)
    if b == nil then
        return 1
    end
    return ch.z2n(C.pcap_thread_set_immediate_mode(self.obj.pt, b))
end

-- Set the PCAP packet filter to use, if
-- .I pf
-- is not specified then return the current packet filter in use.
-- See
-- .BR pcap-filter (3pcap)
-- for more information.
function Pcapthread:filter(pf)
    if pf == nil then
        return ffi.string(C.pcap_thread_filter(self.obj.pt))
    elseif pf == false then
        return ch.z2n(C.pcap_thread_clear_filter(self.obj.pt))
    end
    return ch.z2n(C.pcap_thread_set_filter(self.obj.pt, pf, string.len(pf)))
end

-- Return the error number return from libpcap while parsing the packet filter.
function Pcapthread:filter_errno()
    return C.pcap_thread_filter_errno(self.obj.pt)
end

-- Enable (true) or disable (false) packet filter optimizing, if
-- .I bool
-- is not specified then return if packet filter optimizing is on (true) or off (false).
-- See
-- .BR pcap_compile (3pcap)
-- for more information.
function Pcapthread:filter_optimize(bool)
    if bool == nil then
        return ch.i2b(C.pcap_thread_filter_optimize(self.obj.pt))
    end
    local b = ch.b2i(bool)
    if b == nil then
        return 1
    end
    return ch.z2n(C.pcap_thread_set_filter_optimize(self.obj.pt, b))
end

-- Set the network mask to give when compiling the packet filter, if
-- .I netmask
-- is not specified then return the current network mask.
-- See
-- .BR pcap_compile (3pcap)
-- for more information.
function Pcapthread:filter_netmask(netmask)
    if netmask == nil then
        return C.pcap_thread_filter_netmask(self.obj.pt)
    end
    return ch.z2n(C.pcap_thread_set_filter_netmask(self.obj.pt, netmask))
end

-- Open an interface device for capturing, can be given multiple times to
-- open additional interfaces.
function Pcapthread:open(device)
    return ch.z2n(C.input_pcapthread_open(self.obj, device))
end

-- Open a PCAP file for processing, can be given multiple times to
-- open additional files.
function Pcapthread:open_offline(file)
    return ch.z2n(C.input_pcapthread_open_offline(self.obj, file))
end

-- Start processing packet from opened devices and PCAP files.
function Pcapthread:run()
    return ch.z2n(C.input_pcapthread_run(self.obj))
end

-- Process one packet from the opened devices and PCAP files, the opened
-- sources are processed as a round robin list.
function Pcapthread:next()
    return ch.z2n(C.input_pcapthread_next(self.obj))
end

-- Return the last error as a string that came from libpcap functions
-- that takes an error buffer.
-- See for example
-- .BR pcap_open_offline (3pcap).
function Pcapthread:errbuf()
    return ffi.string(C.input_pcapthread_errbuf(self.obj))
end

-- Return the error
-- .I err
-- as a string or if not specified the last error.
function Pcapthread:strerr(err)
    if err == nil then
        return ffi.string(C.input_pcapthread_strerr(self.obj.err))
    end
    return ffi.string(C.input_pcapthread_strerr(err))
end

-- Return the seconds and nanoseconds (as a list) of the start time for
-- .BR Pcapthread:run() .
function Pcapthread:start_time()
    return tonumber(self.obj.ts.sec), tonumber(self.obj.ts.nsec)
end

-- Return the seconds and nanoseconds (as a list) of the stop time for
-- .BR Pcapthread:run() .
function Pcapthread:end_time()
    return tonumber(self.obj.te.sec), tonumber(self.obj.te.nsec)
end

-- Return the number of packets seen.
function Pcapthread:packets()
    return tonumber(self.obj.pkts)
end

-- Return the number of packets dropped.
function Pcapthread:dropped()
    return tonumber(self.obj.drop)
end

-- Return the number of packets ignored as a result of only processing queries.
-- See
-- .BR Pcapthread:only_queries() .
function Pcapthread:ignored()
    return tonumber(self.obj.ignore)
end

-- Return the number of queries seen, see
-- .BR Pcapthread:only_queries() .
function Pcapthread:queries()
    return tonumber(self.obj.queries)
end

return Pcapthread