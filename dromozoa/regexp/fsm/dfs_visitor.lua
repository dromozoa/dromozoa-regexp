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

return function ()
  local self = {}

  function self:initialize_vertex(g, v)
  end

  function self:start_vertex(g, v)
  end

  function self:discover_vertex(g, v)
  end

  function self:examine_edge(g, e, u, v)
  end

  function self:tree_edge(g, e, u, v)
  end

  function self:back_edge(g, e, u, v)
  end

  function self:forward_or_cross_edge(g, e, u, v)
  end

  function self:finish_edge(g, e, u, v)
  end

  function self:finish_vertex(g, v)
  end

  return self
end
