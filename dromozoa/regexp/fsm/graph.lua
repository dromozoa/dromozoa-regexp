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

local coroutine_yield = coroutine.yield
local coroutine_wrap = coroutine.wrap
local table_remove = table.remove

local function add_edge(mat, vid, eid)
  local row = mat[vid]
  if row then
    if type(row) == "table" then
      row[#row + 1] = eid
    else
      mat[vid] = { row, eid }
    end
  else
    mat[vid] = eid
  end
end

local function remove_edge(mat, vid, eid)
  local row = mat[vid]
  if row then
    if type(row) == "table" then
      local n = #row
      if n == 2 then
        if row[1] == eid then
          mat[vid] = row[2]
          return
        elseif row[2] == eid then
          mat[vid] = row[1]
          return
        end
      else
        for i = 1, n do
          if row[i] == eid then
            table.remove(row, i)
            return
          end
        end
      end
    else
      if row == eid then
        mat[vid] = nil
        return
      end
    end
  end
  error("could not remove_edge")
end

local function each_edge(ctx, eid)
  -- should return valid eid as i
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

local function each_neighbor(map, row)
  if row then
    if type(row) == "table" then
      return each_neighbor_table, { row = row; map = map }, 1
    else
      return each_neighbor_value, map[row], 1
    end
  else
    return each_neighbor_empty
  end
end

local function each_u_reachable(ctx, u)
  local color = ctx[3]
  if not color[u] then
    color[u] = true
    coroutine_yield(u)
    local predicate = ctx[2]
    for i, e in ctx[1]:each_u_neighbor(u) do
      if predicate(e[4]) then
        each_u_reachable(ctx, e[3])
      end
    end
  end
end

local function each_v_reachable(ctx, v)
  local color = ctx[3]
  if not color[v] then
    color[v] = true
    coroutine_yield(v)
    local predicate = ctx[2]
    for i, e in ctx[1]:each_v_neighbor(v) do
      if predicate(e[4]) then
        each_u_reachable(ctx, e[2])
      end
    end
  end
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
    local e = { id, u, v, c }
    self._map[id] = e
    self._id = id
    add_edge(self._uv, u, id)
    add_edge(self._vu, v, id)
    return e
  end

  function self:remove_edge(e)
    local id = e[1]
    self._map[id] = nil
    remove_edge(self._uv, e[2], id)
    remove_edge(self._vu, e[3], id)
    if next(self._map) == nil then
      self._id = 0
    elseif self._id == id then
      self._id = id - 1
    end
  end

  function self:each_edge()
    return each_edge, self, 1
  end

  function self:each_u_neighbor(u)
    return each_neighbor(self._map, self._uv[u])
  end

  function self:each_v_neighbor(v)
    return each_neighbor(self._map, self._vu[v])
  end

  function self:each_u_reachable(u, predicate)
    return coroutine_wrap(each_u_reachable), { self, predicate, {} }, u
  end

  return self
end