# mech-card-game-mvp

A minimum-viable-product "find the fun" implementation of a simultaneous-turn grid-based tactics game.

- DONE:
  - Dynamically-rendered, interactable, data-driven cards
    - Each card is user-defined in a custom card resource
      - Card resource variables define card text, card type, and impact on player variables
      - Card resource variables can be used to instantiate player-interactable buttons, and configure their impact on player variables
    - Default card appearance is configured in a prefab Canvas scene
    - Each unique card renders automatically using the combination of their card resource + the default card prefab
    - Custom decklists can be loaded from .json files
  - Mouse-interactable, configurably-animated card locations
    - Cards can be added to / removed from / rearranged within card locations
    - Predefined card locations include: Hand, Draw pile, Discard pile, Play area, Play queue
    - Cards in hand can be interacted with using the mouse
    - Cards animate between their target locations, and rearrange dynamically on arrival
    - Cards can be highlighted for easier viewing
  - Simple UI for displaying player variables
  - Turn management
- TODO:
  - Develop a grid-based tactics game
    - ...
    - oops! made all these tools and systems, forgot to make a game!
