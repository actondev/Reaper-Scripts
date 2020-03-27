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
  "action":"delete"}
  ```

  The `track` and the `take` are regex patterns that are used to match a track's name and the active take name accordingly.
  If they are not present, they default to `".*"`. The `action` key is **required**

  Valid actions in `@aod.manipulate.v1`
  - `delete`
    deletes the item
  - `mute`
    mutes item. does **NOT** toggle mute state
  - `reverse`
    **TOGGLES** reverse state

## Json rules examples
  `{"take":"take%-delete", "track":".+", "action":"delete"}`
  - matches the exact "take-delete" take name ('%' is the escape character)
  - across any track
  - and deletes the matching items

  Multiple rules
  ``` json
   [{"take": ".*delete", "track": ".*", "action":"delete"},
    {"take": ".*mute", "track": ".*", "action":"mute"},
    {"take": ".*reverse", "track": ".*", "action":"reverse"}
   ]
   ```