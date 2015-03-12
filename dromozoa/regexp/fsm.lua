-- Copyright (C) 2015 Tomoyuki Fujimori <moyu@dromozoa.com>
--
-- This file is part of dromozoa-regexp.
--
-- dromozoa-regexp is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- dromozoa-regexp is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with dromozoa-regexp.  If not, see <http://www.gnu.org/licenses/>.

local graph = require "dromozoa.regexp.fsm.graph"
local write_graphviz = require "dromozoa.regexp.fsm.write_graphviz"

return function ()
  local self = {
    _graph = graph();
    _start = {};
    _accept = {};
  }

  function self:add_edge(u, v, c)
    self._graph:add_edge(u, v, c)
  end

  function self:each_edge()
    return self._graph:each_edge()
  end

  function self:each_u_neighbor(u)
    return self._graph:each_u_neighbor(u)
  end

  function self:each_v_neighbor(v)
    return self._graph:each_v_neighbor(v)
  end

  function self:add_start(u)
    self._start[u] = true
  end

  function self:each_start()
    return pairs(self._start)
  end

  function self:add_accept(v)
    self._accept[v] = true
  end

  function self:each_accept()
    return pairs(self._accept)
  end

  function self:write_graphviz(out)
    write_graphviz(self, out)
  end

  return self
end
