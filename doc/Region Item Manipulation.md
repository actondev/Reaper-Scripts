# Region Item Manipulation

## Examples
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