--[[
    code from http://lua-users.org/wiki/ObjectOrientationTutorial

    example usage:

    Gui.Element = Class.create()

    local el = Gui.Element({x =0, y =0})

    el.init contains the first passed argument

    you can change the constructor like this
    (to have an immutable copy of the passed data)
    function Gui.Element.__construct(data)
        self.data = Table.deepcopy(data)
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
    childClass.__index = childClass
    setmetatable(childClass, {
        __index = baseClass, -- this is what makes the inheritance work
        __call = function (cls, ...)
          local self = setmetatable({}, cls)
          self.__construct(self,...)
          return self
        end,
      })

      return childClass
end

return Class