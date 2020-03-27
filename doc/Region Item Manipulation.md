# Region Item Manipulation
  > @aod.manipulate.v1
  >
  > draft, subject to change

  You can embed item manipulation rules inside an item notes by
  - prepending the `@aod.manipulate.v1` before your json rules

  For example, the item notes could look like this

  ``` json
  @aod.manipulate.v1
  {"take":".*delete",
  "track":".*",
  "op":"delete"}
  ```

  The `track` and the `take` are regex patterns that are used to match a track's name and the active take name accordingly.
  If they are not present, they default to `".*"`. The `op` key is **required** and defines the `operation` to be done.

  Valid operations in `@aod.manipulate.v1`
  - `delete`
    deletes the item
  - `mute`
    TODO should toggle mute
    mutes item. does **NOT** toggle mute state
  - `reverse`
    **TOGGLES** reverse state
  - `set_pitch`
    requires the extra `value` field with the desired pitch
  - `action`
    performs a reaper action by a given id (under the `value` field). id can be either a number (native action) or a string (an `SWS` action for example). Also `value` can either contain one single action, or can be an `array` of action ids

## Temp - TODO actions
  - `adjust_pitch` (relative +1 or -1)
    require the extra field `value`
  - `set_pitch`
    require the extra field `value`
  - `adjust_volume`
  - `repeat`
    ?? and `value` times??

## Json rules examples
  ``` json
  {"take":"take%-delete", "track":".+", "op" :"delete"}
  ```
  - matches the exact "take-delete" take name ('%' is the escape character)
  - across any track
  - and deletes the matching items

  Multiple rules
  ``` json
   [{"take": ".*delete", "track": ".*", "op":"delete"},
    {"take": ".*mute", "track": ".*", "op":"mute"},
    {"take": ".*reverse", "track": ".*", "op":"reverse"}
   ]
   ```

   Running reaper actions
   ``` json
   [{"take": "snare", "op": "action", "value": [40776, 40794]},
    {"take": "hat2", "op": "action", "value": 40794}]
   ```
   - `40776` : `Grid: Set to 1/16`
   - `40794` : `Item edit: Move items/envelope points right by grid size`