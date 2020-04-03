--[[
    example usage:

    Gui.Element = Class.create()

    local el = Gui.Element({x =0, y =0})

    el.init contains the first passed argument

    you can change the constructor like
    function Gui.Element.__construct(firstArg)
        -- ..
    end
]]
local Class = {}

function Class.create()
    local theClass = {}
    theClass.__index = theClass
    setmetatable(theClass, {
        __call = function (cls, ...)
          local self = setmetatable({}, cls)
          self:__construct(...)
          return self
        end,
      })

      -- default constructor
      function theClass:__construct(init)
        -- storing the initial values in the init
        self.init = init
      end

      return theClass
end

function Class.extend(baseClass)
    local childClass = {}
    childClass._index = childClass
    setmetatable(childClass, {
        __index = baseClass, -- this is what makes the inheritance work
        __call = function (cls, ...)
          local self = setmetatable({}, cls)
          self:__construct(...)
          return self
        end,
      })

      return childClass
end

return Class