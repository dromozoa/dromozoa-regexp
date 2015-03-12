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

local function add_edge(mat, vid, eid)
  local row = mat[vid]
  if row then
    if type(row) == "table" then
      row[#row + 1] = vid
    else
      mat[vid] = { row, eid }
    end
  else
    mat[vid] = eid
  end
end

local function each_edge(ctx, eid)
  for i = eid, ctx._id do
    local e = ctx._map[i]
    if e then
      return i + 1, e
    end
  end
  return nil
end

local function each_neighbor_table(ctx, i)
  local eid = ctx.row[i]
  if eid then
    return i + 1, ctx.map[eid]
  else
    return nil
  end
end

local function each_neighbor_value(ctx, i)
  if i == 1 then
    return i + 1, ctx
  else
    return nil
  end
end

local function each_neighbor_empty()
  return nil
end

return function ()
  local self = {
    _map = {};
    _id = 0;
    _uv = {};
    _vu = {};
  }

  function self:add_edge(u, v, c)
    local id = self._id + 1
    local e = { u, v, c }
    self._map[id] = e
    self._id = id
    add_edge(self._uv, u, id)
    add_edge(self._vu, v, id)
  end

  function self:each_edge()
    return each_edge, self, 1
  end

  function self:each_u_neighbor(u)
    return self:each_neighbor(self._uv[u])
  end

  function self:each_v_neighbor(v)
    return self:each_neighbor(self._vu[v])
  end

  function self:each_neighbor(row)
    if row then
      if type(row) == "table" then
        return each_neighbor_table, { row = row; map = self._map }, 1
      else
        return each_neighbor_value, self._map[row], 1
      end
    else
      return each_neighbor_empty
    end
  end

  return self
end
